import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../../features/memo_mgmt/3_model/repository/memo_mgmt_repository.dart';
import '../constants/status_color_mapper.dart';
import '../3_model/model/memo_model.dart';
import '../3_model/model/status_model.dart';
import '../utils/date_formatter.dart';
import '../utils/log_util.dart';

/// 🏠 HomeWidgetService
/// Flutter ⇄ Androidホームウィジェット間のデータ送受信を管理
/// - Memo と Status を分離管理
/// - Flutter → ネイティブ、ネイティブ → Flutter 双方向同期対応
/// - CRUD後にウィジェット再描画
class HomeWidgetService {
  static const String _memoListKey = 'memo_list';
  static const String _statusListKey = 'status_list';
  static const int _maxDisplayCount = 100;
  static const String _providerNm = 'home_widget.MemoWidgetProvider';

  // ============================
  // 🔹 アプリ → ホームウィジェット 同期
  // ============================
  ///
  /// アプリ（Flutter側）の最新データをホームウィジェットへ反映する。
  /// - メモ／ステータス情報をJSON化してSharedPreferencesへ保存
  /// - Kotlinネイティブ側で保持（HomeWidgetPlugin経由）
  /// - 保存後にウィジェットUIを再描画
  ///
  static Future<void> syncHomeWidgetFromApp() async {

    final repo = MemoMgmtRepository();
    final memoList = await repo.fetchAllMemos();
    final statusList = await repo.fetchAllStatuses();

    // 🪵 ログ出力：同期対象の全データ
    logList('MEMO LIST', memoList);
    logList('STATUS LIST', statusList);

    // 🔸 SharedPreferencesへ書き込み（ネイティブ層へ送信）
    await _saveMemoList(memoList);
    await _saveStatusList(statusList);

    // 🔸 ホームウィジェットの再描画要求（ネイティブ側でUI更新）
    await _update();

    // 🪵 SharedPreferencesの中身を確認
    await logSPData("SP書き込み後");
  }

  static Future<void> _saveMemoList(List<Memo> memos) async {
    // 最大表示件数分のみ送信（パフォーマンス最適化）
    final limited = memos.take(_maxDisplayCount).toList();

    // JSON形式に変換
    final jsonList = limited.map((m) => {
      'id': m.memoId ?? '',
      'content': m.content ?? '',
      'createdAt': formatDateTime(m.createdAt),
      'updatedAt': formatDateTime(m.updatedAt),
      'statusId': m.statusId ?? '',
      'prevStatusId': m.statusId ?? '',
    }).toList();

    // 🧭 AndroidネイティブのSharedPreferencesへ保存
    await HomeWidget.saveWidgetData(_memoListKey, jsonEncode(jsonList));
  }

  static Future<void> _saveStatusList(List<Status> statuses) async {
    // JSON形式に変換
    final jsonList = statuses.map((s) {
      final hexColor = getColorCd(s.statusColor);
      return {
        'statusId': s.statusId ?? '',
        'sortNo': s.sortNo ?? '',
        'statusNm': s.statusNm,
        'statusColor': hexColor,
      };
    }).toList();

    // 🧭 AndroidネイティブのSharedPreferencesへ保存
    await HomeWidget.saveWidgetData(_statusListKey, jsonEncode(jsonList));
  }

  static Future<void> _update() async {
    // 📲 ホームウィジェットを即時再描画（AppWidgetProvider更新）
    await HomeWidget.updateWidget(name: _providerNm);
  }

  // ============================
  // 🔹 ホームウィジェット → アプリ 同期
  // ============================
  ///
  /// ホームウィジェット（SharedPreferences）上のデータを取得し、
  /// アプリDB（SQLite）へ反映する。
  /// - 既存レコードがあれば UPDATE、なければ INSERT（全件洗い替え）
  /// - 変更対象は Memo のみ（Status はマスタ固定）
  ///
  static Future<void> syncAppFromWidget() async {
    try {
      // 🧭 SharedPreferences（Androidネイティブ）からデータ取得
      // ※ statusテーブルは、アプリへの同期は不要
      final memoRaw = await HomeWidget.getWidgetData(_memoListKey);

      // JSON → List<dynamic> に変換
      final memoList = memoRaw != null && memoRaw.isNotEmpty
          ? jsonDecode(memoRaw) as List
          : <dynamic>[];

      // 🪵 デバッグログ出力（件数と内容）
      logList('Widget→App MEMO LIST', memoList);

      // 🧩 Repository 経由でDB反映
      final repo = MemoMgmtRepository();

      // データ保存（Memoテーブルのみ）
      for (final item in memoList) {
        // JSON → Memoモデルに変換
        final memo = Memo(
          memoId: int.tryParse(item['id']?.toString() ?? ''),
          content: item['content'] ?? '',
          statusId: int.tryParse(item['statusId']?.toString() ?? '') ?? 2,
          createdAt: DateTime.tryParse(item['createdAt'] ?? ''),
          updatedAt: DateTime.tryParse(item['updatedAt'] ?? ''),
        );

        // INSERT or UPDATE
        await repo.upsertMemo(memo);
      }

      if (kDebugMode) {
        print('✅ [HomeWidgetService] syncAppFromWidget: ${memoList.length}件反映完了');
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('⚠️ [HomeWidgetService] syncAppFromWidget で例外発生: $e');
        print(st);
      }
    }
  }

  // ============================
  // 🔹 共通ユーティリティ
  // ============================


  // static Future<dynamic> getData(String key) async {
  //   final raw = await HomeWidget.getWidgetData(key);
  //   if (raw == null) return null;
  //   try {
  //     return jsonDecode(raw);
  //   } catch (_) {
  //     return raw;
  //   }
  // }

  static Future<void> clearWidgetData() async {
    await HomeWidget.saveWidgetData(_memoListKey, '');
    await HomeWidget.saveWidgetData(_statusListKey, '');
    await _update();
    if (kDebugMode) {
      print('🧹 [HomeWidgetService] Cleared widget data');
    }
  }

  // ログ出力：全SPデータ
  static Future<void> logSPData(String tag) async {
    final memoRaw = await HomeWidget.getWidgetData(_memoListKey);
    final statusRaw = await HomeWidget.getWidgetData(_statusListKey);
    if (kDebugMode) {
      print('===== SharedPreferencesログ：$tag =====');
      print('MEMO → $memoRaw');
      print('STATUS → $statusRaw');
      print('========================================');
    }
  }
}
