import 'package:flutter/foundation.dart';
import '../../../core/entities/memo_entity.dart';
import '../../../core/repositories/memo_repository.dart';
import '../../../core/repositories/status_repository.dart';
import '../../../core/services/home_widget_service.dart';
import '../../../core/dto/memo_with_status.dart';

/// ===============================================
/// 💼 MemoService
/// ===============================================
///
/// アプリ全体のメモ操作を一元管理（Repository層との橋渡し）
///
/// - Repository層：JOIN済み・Entity操作をカプセル化
/// - Service層：アプリロジック・トグル・Widget同期を担当
///
class MemoService {
  final MemoRepository _memoRepo = MemoRepository();
  final StatusRepository _statusRepo = StatusRepository();

  // ==============================================
  // 🟢 メモ新規登録
  // ==============================================
  Future<int> insertMemo(MemoEntity memo) async {
    final id = await _memoRepo.insert(memo);

    await _syncAllData(action: 'insert');
    debugPrint('✅ [MemoService] insertMemo success: id=$id');
    return id;
  }

  // ==============================================
  // 📋 メモ一覧取得（JOIN済み）
  // ==============================================
  Future<List<MemoWithStatus>> fetchAllMemos() async {
    return await _memoRepo.fetchAllWithStatus();
  }

  // ==============================================
  // ✏️ 内容更新
  // ==============================================
  Future<void> updateMemo(MemoEntity memo) async {
    final updated = memo.copyWith(updatedAt: DateTime.now());
    await _memoRepo.update(updated);

    await _syncAllData(action: 'update');
    debugPrint('✅ [MemoService] updateMemo success');
  }

  // ==============================================
  // 🗑 メモ削除
  // ==============================================
  Future<int> deleteMemo(int memoId) async {
    final result = await _memoRepo.delete(memoId);

    await _syncAllData(action: 'delete');
    debugPrint('✅ [MemoService] deleteMemo success');
    return result;
  }

  // ==============================================
  // 🎨 ステータス更新
  // ==============================================
  Future<void> updateStatus(MemoEntity memo, int newStatusId) async {
    // 新ステータス取得
    final newStatus = await _statusRepo.getStatusById(newStatusId);
    if (newStatus == null) return;

    final updated = memo.copyWith(
      statusId: newStatus.statusId,
      updatedAt: DateTime.now(),
    );

    await _memoRepo.update(updated);
    await _syncAllData(action: 'status_update');

    debugPrint('✅ [MemoService] updateStatus success');
  }

  // ==============================================
  // 🔁 トグル（完了 ⇄ 未完了）
  // ==============================================
  Future<void> toggleStatus(MemoEntity memo) async {
    // ID 1 = 完了, ID 2 = 未完了 （固定）
    final newStatusId = (memo.statusId == 1) ? 2 : 1;
    await updateStatus(memo, newStatusId);
  }

  // ==============================================
  // 🔄 Flutter → ホームウィジェット 同期
  // ==============================================
  Future<void> _syncAllData({String action = 'update'}) async {
    final memoList = await _memoRepo.fetchAllWithStatus();
    final memoMaps = memoList.map((m) => m.toMap()).toList();

    await HomeWidgetService.syncAllData(
      memoList: memoMaps,
      action: action,
    );

    debugPrint('✅ [MemoService] syncAllData ($action)');
  }
}
