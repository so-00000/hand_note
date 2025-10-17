import 'package:flutter/cupertino.dart';
import '../../../../core/dao/memo_dao.dart';
import '../../../../core/dao/status_dao.dart';
import '../../../../core/model/memo_model.dart';
import '../../../../core/model/memo_with_status_model.dart';
import '../../../../core/model/status_model.dart';
import '../../../../core/utils/memo_mapper.dart';

/// MemoMgmtRepository

class MemoMgmtRepository {

  final MemoDao _memoDao = MemoDao();
  final StatusDao _statusDao = StatusDao();

  ///
  /// Memoモデルの操作
  ///

  ///
  /// INSERT
  ///

  //メモデータの新規作成
  Future<int> insertMemo(Memo memo) async {
    try {
      // 実行前ログ
      // debugPrint('🔹 [insertMemo] 登録開始: ${memo.toMap()}');

      // 実行
      final id = await _memoDao.insert(memo);

      // 成功ログ
      debugPrint('✅ [insertMemo] 登録成功: id=$id');
      return id;

    } catch (e, stackTrace) {
      // 例外発生時の詳細ログ
      debugPrint('❌ [insertMemo] 登録失敗: $e');
      debugPrint('📄 StackTrace: $stackTrace');
      rethrow; // ← 上位層でハンドリングできるよう再スロー
    }
  }

  ///
  /// UPDATE
  ///

  // メモデータの更新
  Future<void> updateMemo(Memo memo) async {

    // 更新日時のセット
    final updatedMemo = memo.copyWith(
      updatedAt: DateTime.now(),
    );

    // 更新処理の呼び出し
    await _memoDao.update(updatedMemo);
  }

  /// メモのステータスをトグル（完了 ⇄ 未完了）

  Future<void> toggleStatus(Memo memo) async {

    final newStatusId = (memo.statusId == 1) ? 2 : 1;

    // ステータス情報を取得
    final statusInfo = await _statusDao.fetchById(newStatusId);
    if (statusInfo == null) return;

    // 更新情報のセット
    final updated = memo.copyWith(
      statusId: newStatusId
    );

    await _memoDao.update(updated);
  }

  /// 削除
  Future<int> deleteMemo(int id) async {
    return await _memoDao.delete(id);
  }



  ///
  /// Statusモデルの操作
  ///

  ///
  /// READ
  ///

  // 全ステータス取得（固定＋カスタム含む）
  Future<List<Status>> fetchAllStatuses() async {
    return await _statusDao.fetchAll();
  }


  ///
  /// MemoWithStatusモデルの操作
  ///


  /// 一覧取得（JOIN済み）
  Future<List<MemoWithStatus>> fetchAllMemos() async {
    final memos = await _memoDao.fetchAll();
    final statuses = await _statusDao.fetchAll();

    return memos.map((memo) {
      final status = statuses.firstWhere(
            (s) => s.statusId == memo.statusId,
        orElse: () => const Status(statusNm: '未設定', colorCd: '#999999'),
      );
      return MemoWithStatus(
        id: memo.id,
        content: memo.content,
        statusId: memo.statusId,
        statusNm: status.statusNm,
        colorCd: status.colorCd,
        createdAt: memo.createdAt,
        updatedAt: memo.updatedAt,
      );
    }).toList();
  }
}
