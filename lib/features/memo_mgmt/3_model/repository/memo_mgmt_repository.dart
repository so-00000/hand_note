import 'package:flutter/cupertino.dart';
import '../../../../core/dao/memo_dao.dart';
import '../../../../core/dao/status_dao.dart';
import '../../../../core/model/memo_model.dart';
import '../../../../core/model/status_model.dart';
import '../../../../main.dart';

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

      // ホームウィジェットの同期
      await syncHomeWidget();

      return id;

    } catch (e, stackTrace) {
      // 例外発生時の詳細ログ
      debugPrint('❌ [insertMemo] 登録失敗: $e');
      debugPrint('📄 StackTrace: $stackTrace');
      rethrow; // ← 上位層でハンドリングできるよう再スロー
    }
  }

  ///
  /// READ
  ///

  /// メモデータ全件取得
  Future<List<Memo>> fetchAllMemos() async {
    try {

      // 取得処理の呼び出し
      final result = await _memoDao.fetchAll();

      // ログ出力
      debugPrint('📄 [MemoMgmtRepository] fetchAllMemos: ${result.length}件取得');
      for (final memo in result) {
        debugPrint('  - id=${memo.id}, content="${memo.content}", statusId=${memo.statusId}, updatedAt=${memo.updatedAt}');
      }

      return result;
    } catch (e, st) {
      debugPrint('❌ [MemoMgmtRepository] fetchAllMemos 取得失敗: $e');
      debugPrint(st.toString());
      rethrow;
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

    // ホームウィジェットの同期
    await syncHomeWidget();
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

    // ホームウィジェットの同期
    await syncHomeWidget();
  }

  /// 削除
  Future<int> deleteMemo(int id) async {

    // ホームウィジェットの同期
    await syncHomeWidget();

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

  // 1件取得（ステータスIDで検索）
  Future<Status> fetchStatusById(int statusId) async {
    return await _statusDao.fetchById(statusId);
  }
}
