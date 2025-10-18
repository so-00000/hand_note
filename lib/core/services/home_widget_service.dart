import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../model/memo_with_status_model.dart';

/// 🏠 HomeWidgetService
/// Flutter ⇄ Androidホームウィジェット間のデータ送受信を管理
/// - メモとステータス両方をネイティブ側へ送信
/// - CRUD後にウィジェットを再描画
class HomeWidgetService {
  static const String _mwsListKey = 'mws_list';
  static const int _maxDisplayCount = 10;
  static const String _providerNm = 'home_widget.MemoWidgetProvider';

  /// 🔹 メモ＋ステータスを同期
  static Future<void> syncAllData({
    required List<MemoWithStatus> mwsList,
    String action = 'update',
  }) async {

    if (kDebugMode) {
      print('ログ：[HomeWidgetService] syncAllData($action): '
          '${mwsList.length} memos');
    }

    await _saveMwsList(mwsList);
    await _update();

    if (kDebugMode) {
      print('ログ：[HomeWidgetService] Widget updated after $action');
    }
  }

  /// 🔹 メモ一覧を書き込み（SharedPreferences）
  static Future<void> _saveMwsList(List<MemoWithStatus> mwsList) async {

    // 最大表示件数のセット
    final limited = mwsList.take(_maxDisplayCount).toList();

    // モデルクラス⇒（Map⇒）JSONに変換
    final jsonMwsList = limited.map((m) => m.toMap()).toList();

    // SPへ書き込み
    await HomeWidget.saveWidgetData(
        _mwsListKey,
        jsonEncode(jsonMwsList)
    );

    // ログ出力
    logSPData("SP書き込み直後");
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
    await HomeWidget.saveWidgetData(_mwsListKey, '');
    await _update();
    if (kDebugMode) print('ログ：[HomeWidgetService] Cleared widget data');
  }


  /// ログ出力
  static Future<void> logSPData(String tag) async {
    final stored = await HomeWidget.getWidgetData(_mwsListKey);
    if (kDebugMode) {
      print('ログ：$tag → $stored');
    }
  }
}