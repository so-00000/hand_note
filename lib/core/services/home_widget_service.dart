import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../constants/status_color_mapper.dart';
import '../model/memo_model.dart';
import '../model/status_model.dart';
import '../utils/date_formatter.dart';

/// 🏠 HomeWidgetService
/// Flutter ⇄ Androidホームウィジェット間のデータ送受信を管理
/// - Memo と Status を分離管理
/// - Flutter → ネイティブ間の同期
/// - CRUD後にウィジェット再描画
class HomeWidgetService {
  static const String _memoListKey = 'memo_list';
  static const String _statusListKey = 'status_list';
  static const int _maxDisplayCount = 10;
  static const String _providerNm = 'home_widget.MemoWidgetProvider';

  /// 🔹 メモ＋ステータスを同期
  static Future<void> syncAllData({
    required List<Memo> memoList,
    required List<Status> statusList,
    String action = 'update',
  }) async {
    if (kDebugMode) {
      print('ログ：[HomeWidgetService] syncAllData($action): '
          '${memoList.length} memos / ${statusList.length} statuses');
    }

    // メモデータ書き込み
    await _saveMemoList(memoList);

    // ステータスデータ書き込み
    await _saveStatusList(statusList);

    // ログ出力
    HomeWidgetService.logSPData("SP書き込み直後");

    // ウィジェット更新
    await _update();

    if (kDebugMode) {
      print('ログ：[HomeWidgetService] Widget updated after $action');
    }
  }

  /// 🔹 メモ一覧を書き込み（SharedPreferences）
  static Future<void> _saveMemoList(List<Memo> memos) async {
    final limited = memos.take(_maxDisplayCount).toList();

    final jsonList = limited
        .map((m) => {
      'id': m.id ?? '',
      'content': m.content ?? '',
      'updatedAt': formatDateTime(m.updatedAt),
      'statusId': m.statusId ?? '',
      'prevStatusId': m.statusId ?? '',
    }).toList();

    await HomeWidget.saveWidgetData(_memoListKey, jsonEncode(jsonList));
  }

  /// 🔹 ステータス一覧を書き込み
  static Future<void> _saveStatusList(List<Status> statuses) async {
    final jsonList = statuses.map((s) {

      // Flutter内：statusColor (ex. 1, 2)
      // ホームウィジェット：カラーコード (ex. #xxxxxx)

      final hexColor = getColorCd(s.statusColor);

      return {
        'statusId': s.statusId ?? '',
        'statusNm': s.statusNm,
        'statusColor': hexColor,
      };
    }).toList();

    await HomeWidget.saveWidgetData(_statusListKey, jsonEncode(jsonList));
  }

  /// 🔹 データ取得（ネイティブ → Flutter）
  static Future<dynamic> getData(String key) async {
    final raw = await HomeWidget.getWidgetData(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  /// 🔹 ウィジェット再描画
  static Future<void> _update() async {
    await HomeWidget.updateWidget(name: _providerNm);
  }

  /// 🔹 全データリセット
  static Future<void> clearWidgetData() async {
    await HomeWidget.saveWidgetData(_memoListKey, '');
    await HomeWidget.saveWidgetData(_statusListKey, '');
    await _update();
    if (kDebugMode) print('ログ：[HomeWidgetService] Cleared widget data');
  }

  /// 🔹 SharedPreferencesの内容を確認（デバッグ用）
  static Future<void> logSPData(String tag) async {
    final memoRaw = await HomeWidget.getWidgetData(_memoListKey);
    final statusRaw = await HomeWidget.getWidgetData(_statusListKey);

    if (kDebugMode) {
      print('===== ログ：$tag =====');
      print('ログ：MEMO → $memoRaw');
      print('ログ：STATUS → $statusRaw');
      print('================');
    }
  }
}
