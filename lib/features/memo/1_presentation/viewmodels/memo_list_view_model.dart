import 'package:flutter/material.dart';
import '../../2_application/memo_service.dart';
import '../../2_application/status_service.dart';
import '../../3_domain/entities/memo.dart';
import '../../3_domain/entities/memo_status.dart';
import '../../../../core/utils/snackbar_util.dart';

class MemoListViewModel extends ChangeNotifier {
  final MemoService _memoService = MemoService();
  final StatusService _statusService = StatusService();

  List<Memo> _memos = [];
  bool _isLoading = true;

  // getter
  List<Memo> get memos => _memos;
  bool get isLoading => _isLoading;



  ///
  /// メモ本文・全体関連
  ///



  /// メモの一覧取得
  Future<void> loadMemos() async {
    _isLoading = true;
    notifyListeners();

    // データ取得
    _memos = await _memoService.fetchAllMemos();

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
    final all = await _memoService.fetchAllMemos();

    // データの絞り込み
    _memos = all
        .where((m) => m.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    notifyListeners();
  }

  /// メモ本文の更新
  Future<void> updateMemoContent(Memo memo, String newContent) async {
    // メモ本文のセット
    final updatedMemo = memo.copyWith(
      content: newContent,
    );

    // 更新処理の呼び出し
    await _memoService.updateMemo(updatedMemo);

    // 一覧の読み込み
    await loadMemos();
  }

  /// メモ削除
  Future<void> deleteMemo(BuildContext context, Memo memo) async {
    await _memoService.deleteMemo(memo.id!);

    /// Undo処理定義（削除取り消し）
    Future<void> undoDelete(Memo memo) async {
      await _memoService.insertMemo(memo);
      await loadMemos(); // ← 修正ポイント①：fetchAllMemos()でなくloadMemos()で状態反映
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



  ///
  /// ステータス関連
  ///


  /// 完了⇄未完了切り替え
  Future<void> toggleStatus(Memo memo) async {
    await _statusService.toggleStatus(memo);
    await loadMemos();
  }

  /// ステータス更新
  Future<void> updateStatus(
      Memo memo,
      int newStatusId
      ) async {
    await _memoService.updateStatus(
      memo,
      newStatusId
    );

    // メモリスト再取得
    await loadMemos();

    // UI通知
    notifyListeners();
  }

  /// ステータス一覧の表示
  Future<List<MemoStatus>> fetchStatuses() => _statusService.fetchAllStatuses();


  /// 入力完了時（編集終了時）の処理
  Future<void> saveIfChanged(Memo memo, String newText) async {
    final trimmed = newText.trim();
    if (trimmed.isNotEmpty && trimmed != memo.content) {
      await updateMemoContent(memo, trimmed);
    }
  }

}
