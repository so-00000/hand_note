import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// 🏠 HomeWidgetService
/// Flutter ⇄ Androidホームウィジェット間のデータ送受信を管理
/// - メモとステータス両方をネイティブ側へ送信
/// - CRUD後にウィジェットを再描画
class HomeWidgetService {
  static const String _memoListKey = 'memo_list';
  static const String _statusListKey = 'status_list';
  static const int _maxDisplayCount = 10;
  static const String _providerName = 'widget.MemoWidgetProvider';

  /// 🔹 メモ＋ステータスを同期
  static Future<void> syncAllData({
    required List<Map<String, dynamic>> memoList,
    String action = 'update',
  }) async {
    if (kDebugMode) {
      print('ログ：[HomeWidgetService] syncAllData($action): '
          '${memoList.length} memos');
    }

    await _saveMemoList(memoList);
    await _update();

    if (kDebugMode) {
      print('ログ：[HomeWidgetService] Widget updated after $action');
    }
  }


  /// 🔹 メモ一覧を保存
  static Future<void> _saveMemoList(List<Map<String, dynamic>> memoList) async {
    final limited = memoList.take(_maxDisplayCount).toList();

    // 🟣 Flutter→Kotlinに送るデータ項目を拡張
    final simplified = limited.map((m) => {
      'id': m['id'] ?? '',
      'content': m['content'] ?? '',
      'updatedAt': m['updatedAt']?.toString() ?? '',
      'statusId': m['statusId'] ?? '',
      'statusName': m['statusName'] ?? '',
      'statusColor': m['statusColor'] ?? '02', // fallback: 未完了カラー
    }).toList();

    await HomeWidget.saveWidgetData(_memoListKey, jsonEncode(simplified));

    if (kDebugMode) {
      print('ログ：[HomeWidgetService] memo_list written: ${jsonEncode(simplified)}');
    }
  }

  /// 🔹 ステータス一覧を保存
  static Future<void> _saveStatusList(List<Map<String, dynamic>> statusList) async {
    final simplified = statusList.map((s) => {
      'id': s['id'] ?? '',
      'name': s['name'] ?? '',
      'color': s['color'] ?? '',
    }).toList();

    await HomeWidget.saveWidgetData(_statusListKey, jsonEncode(simplified));

    if (kDebugMode) {
      print('ログ：[HomeWidgetService] status_list written: ${jsonEncode(simplified)}');
    }
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
    await HomeWidget.updateWidget(name: _providerName);
  }

  /// 🔹 全データリセット
  static Future<void> clearWidgetData() async {
    await HomeWidget.saveWidgetData(_memoListKey, '');
    await HomeWidget.saveWidgetData(_statusListKey, '');
    await _update();
    if (kDebugMode) print('ログ：[HomeWidgetService] Cleared widget data');
  }
}
