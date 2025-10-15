import 'package:flutter/cupertino.dart';
import '../../../core/services/home_widget_service.dart';
import '../3_domain/entities/memo.dart';
import '../4_data/dao/memo_dao.dart';
import '../4_data/dao/memo_status_dao.dart';

/// 💼 MemoService
/// アプリ全体のメモ操作を一元管理（DAO層との橋渡し）
///
/// - DAO層：SQLite直接操作
/// - Service層：アプリロジック・トグルや更新日時処理
/// - Flutter → ホームウィジェット同期も担当
class MemoService {
  final MemoDao _memoDao = MemoDao();
  final MemoStatusDao _memoStatusDao = MemoStatusDao();

  /// ==========================================
  /// 🟢 メモ新規登録
  /// ==========================================
  Future<int> insertMemo(Memo memo) async {
    try {
      debugPrint('🔹 [insertMemo] 登録開始: ${memo.toMap()}');

      final id = await _memoDao.insert(memo);

      // Flutter → Kotlin 同期（メモ＋ステータス両方）
      await _syncAllData(action: 'insert');

      debugPrint('✅ [insertMemo] 登録成功: id=$id');
      return id;
    } catch (e, stackTrace) {
      debugPrint('❌ [insertMemo] 登録失敗: $e');
      debugPrint('📄 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// ==========================================
  /// 📋 メモ一覧取得（JOIN済み）
  /// ==========================================
  Future<List<Memo>> fetchAllMemos() async {
    return await _memoDao.fetchAll();
  }

  /// ==========================================
  /// ✏️ 内容更新
  /// ==========================================
  Future<void> updateMemo(Memo memo) async {
    final updatedMemo = memo.copyWith(updatedAt: DateTime.now());
    await _memoDao.update(updatedMemo);

    // 同期
    await _syncAllData(action: 'update');
  }

  /// ==========================================
  /// 🗑 メモ削除
  /// ==========================================
  Future<int> deleteMemo(int id) async {
    final result = await _memoDao.delete(id);

    // 同期
    await _syncAllData(action: 'delete');
    return result;
  }

  /// ==========================================
  /// 🎨 ステータス更新
  /// ==========================================
  Future<void> updateStatus(Memo memo, int newStatusId) async {
    final updated = memo.copyWith(statusId: newStatusId);
    await _memoDao.update(updated);

    // 同期
    await _syncAllData(action: 'status_update');
  }

  /// ==========================================
  /// 🔄 Flutter → ホームウィジェット 同期
  /// ==========================================
  Future<void> _syncAllData({String action = 'update'}) async {
    try {
      final memoList = await _memoDao.fetchAll(); // JOIN済みメモ
      final statusList = await _memoStatusDao.fetchAll(); // 全ステータス

      await HomeWidgetService.syncAllData(
        memoList: memoList.map((m) => {
          'id': m.id,
          'content': m.content,
          'updatedAt': m.updatedAt?.toIso8601String() ?? m.createdAt.toIso8601String(),
          'statusId': m.statusId,
          'statusName': m.statusName,
          'statusColor': m.statusColor,
        }).toList(),
        action: action,
      );

      debugPrint('✅ [MemoService] syncAllData completed ($action)');
    } catch (e) {
      debugPrint('⚠️ [MemoService] syncAllData failed: $e');
    }
  }
}
