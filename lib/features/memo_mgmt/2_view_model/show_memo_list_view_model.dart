import 'package:flutter/material.dart';
import '../../../core/model/memo_model.dart';
import '../../../core/model/memo_with_status_model.dart';
import '../../../core/model/status_model.dart';
import '../../../core/utils/memo_mapper.dart';
import '../../../core/utils/snackbar_util.dart';

import '../3_model/repository/memo_mgmt_repository.dart';

class ShowMemoListVM extends ChangeNotifier {

  final MemoMgmtRepository _memoRepo = MemoMgmtRepository();

  List<MemoWithStatus> _memoWithStatus = [];
  bool _isLoading = true;
  //
  // // getter
  List<MemoWithStatus> get memoWithStatus => _memoWithStatus;
  bool get isLoading => _isLoading;



  ///
  /// メモ本文・全体関連
  ///



  /// メモの一覧取得
  Future<void> loadMemos() async {
    _isLoading = true;
    notifyListeners();

    // データ取得
    _memoWithStatus = await _memoRepo.fetchAllMemos();

    _isLoading = false;
    notifyListeners();
  }

  /// 検索（ローカル絞り込み）
  Future<void> searchMemos(String query) async {
    if (query.isEmpty) {
      await loadMemos();
      return;
    }

    // 取得処理の呼び出し（全件取得）
    final all = await _memoRepo.fetchAllMemos();

    // データの絞り込み
    _memoWithStatus = all
        .where((m) => m.content!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    notifyListeners();
  }


  /// メモ本文の更新
  Future<void> updateMemoContent(MemoWithStatus mws, String newContent) async {

    final memo = MemoMapper.toMemo(mws);

    // メモ本文のセット
    final updatedMemo = memo.copyWith(
      content: newContent,
    );

    // 更新処理の呼び出し
    await _memoRepo.updateMemo(updatedMemo);

    // 一覧の読み込み
    await loadMemos();
  }

  /// メモステータスの更新
  Future<void> updateMemoStatus(MemoWithStatus mws, int newStatusId) async {

    final memo = MemoMapper.toMemo(mws);

    // メモ本文のセット
    final updatedMemo = memo.copyWith(
      statusId: newStatusId,
    );

    // 更新処理の呼び出し
    await _memoRepo.updateMemo(updatedMemo);

    // 一覧の読み込み
    await loadMemos();
  }

  /// メモ削除
  Future<void> deleteMemo(BuildContext context, MemoWithStatus mws) async {

    final memo = MemoMapper.toMemo(mws);

    await _memoRepo.deleteMemo(memo.id!);

    /// Undo処理定義（削除取り消し）
    Future<void> undoDelete(Memo memo) async {
      await _memoRepo.insertMemo(memo);
      await loadMemos();
    }

    // snack barの呼び出し　※Undo押下で取り消し
    SnackBarUtil.successWithUndo(
      context,
      'メモを削除しました！',
          () async {
        await undoDelete(memo);
      },
    );

    await loadMemos(); // ← 修正ポイント②：削除後もリスト更新
  }


  /// 完了⇄未完了切り替え
  Future<void> toggleMemoStatus(MemoWithStatus mws) async {

    final memo = MemoMapper.toMemo(mws);

    await _memoRepo.toggleStatus(memo);
    await loadMemos();
  }

  /// ステータス一覧の表示
  Future<List<Status>> fetchStatuses() => _memoRepo.fetchAllStatuses();


  /// 入力完了時（編集終了時）の処理
  Future<void> saveIfChanged(MemoWithStatus mws, String newText) async {

    final trimmed = newText.trim();
    if (trimmed.isNotEmpty && trimmed != mws.content) {
      await updateMemoContent(mws, trimmed);
    }
  }

}
