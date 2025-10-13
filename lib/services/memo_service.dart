import 'package:flutter/cupertino.dart';
import 'package:hand_note/db/dao/memo_status_dao.dart';

import '../db/dao/memo_dao.dart';
import '../models/memo.dart';

/// 💼 MemoService
/// アプリ全体のメモ操作を一元管理（DAO層との橋渡し）
///
/// - DAO層：SQLite直接操作
/// - Service層：アプリロジック・トグルや更新日時処理
class MemoService {
  final MemoDao _memoDao = MemoDao();
  final MemoStatusDao _memoStatusDao = MemoStatusDao();

  /// 新規登録
  Future<int> insertMemo(Memo memo) async {
    try {
      // 実行前ログ
      debugPrint('🔹 [insertMemo] 登録開始: ${memo.toMap()}');

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


  /// 一覧取得（JOIN済み）
  Future<List<Memo>> fetchAllMemos() async {
    return await _memoDao.fetchAll();
  }

  /// 内容更新
  Future<void> updateMemo(Memo memo) async {

    // 更新日時のセット
    final updatedMemo = memo.copyWith(
      updatedAt: DateTime.now(),
    );

    // 更新処理の呼び出し
    await _memoDao.update(updatedMemo);
  }

  /// 削除
  Future<int> deleteMemo(int id) async {
    return await _memoDao.delete(id);
  }



  /// メモテーブルのステータス更新処理
  Future<void> updateStatus(
      Memo memo,
      int newStatusId,
      ) async {

    final updated = memo.copyWith(
      statusId: newStatusId,
    );

    // 更新処理
    await _memoDao.update(updated);
  }
}
