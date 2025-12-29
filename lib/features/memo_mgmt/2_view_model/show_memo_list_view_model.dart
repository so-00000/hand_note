import 'package:flutter/material.dart';
import '../../../core/model/memo_model.dart';
import '../../../core/model/status_model.dart';
import '../../../core/services/home_widget_service.dart';
import '../../../core/services/memo_launch_handler.dart';
import '../../../core/utils/snackbar_util.dart';
import '../3_model/repository/memo_mgmt_repository.dart';

class ShowMemoListVM extends ChangeNotifier {
  final MemoMgmtRepository _memoRepo = MemoMgmtRepository();


  List<Memo> _memo = [];
  bool _isLoading = true;
  int? _editingMemoId;


  // ===== Getter =====
  List<Memo> get memo => _memo;
  bool get isLoading => _isLoading;
  int? get editingMemoId => _editingMemoId;

  // ===== メモ一覧取得 =====
  Future<void> loadMemos() async {
    _isLoading = true;
    notifyListeners();

    // データ取得
    _memo = await _memoRepo.fetchAllMemos();

    // ✅ ホームウィジェットから起動されたメモがあれば編集対象に設定
    final targetId = MemoLaunchHandler.memoIdToOpen;
    // if (targetId != null) {
    //   _editingMemoId = targetId;
    //   MemoLaunchHandler.clear();
    //   print('📝 編集対象メモIDを設定: $_editingMemoId');
    // }

    _isLoading = false;
    notifyListeners();
  }

  // ===== 検索（ローカル絞り込み） =====
  Future<void> searchMemos(String query) async {
    if (query.isEmpty) {
      await loadMemos();
      return;
    }

    final all = await _memoRepo.fetchAllMemos();
    _memo = all
        .where((m) => m.content!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  // ===== メモ本文更新 =====
  Future<void> updateMemoContent(Memo memo, String newContent) async {
    final updatedMemo = memo.copyWith(content: newContent);
    await _memoRepo.updateMemo(updatedMemo);
    await loadMemos();

    // ホームウィジェットにデータ同期
    await HomeWidgetService.syncHomeWidgetFromApp();
  }

  // ===== ステータス更新 =====
  Future<void> updateMemoStatus(Memo memo, int newStatusId) async {
    final updatedMemo = memo.copyWith(statusId: newStatusId);
    await _memoRepo.updateMemo(updatedMemo);
    await loadMemos();

    // ホームウィジェットにデータ同期
    await HomeWidgetService.syncHomeWidgetFromApp();
  }

  // ===== メモ削除 =====
  Future<void> deleteMemo(BuildContext context, Memo memo) async {
    await _memoRepo.deleteMemo(memo.memoId!);

    Future<void> undoDelete(Memo memo) async {
      await _memoRepo.insertMemo(memo);
      await loadMemos();

      // ホームウィジェットにデータ同期
      await HomeWidgetService.syncHomeWidgetFromApp();
    }

    SnackBarUtil.successWithUndo(
      context,
      'メモを削除しました！',
          () async => await undoDelete(memo),
    );

    await loadMemos();
  }

  // ===== ステータス切替（完了⇄未完了） =====
  Future<void> toggleMemoStatus(Memo memo) async {
    await _memoRepo.toggleStatus(memo);
    await loadMemos();

    // ホームウィジェットにデータ同期
    await HomeWidgetService.syncHomeWidgetFromApp();
  }

  // ===== ステータス切替（順送り） =====
  Future<void> cycleStatusBySortNo(Memo memo) async {
    // 全ステータスを sortNo 昇順で取得
    final statuses = await fetchStatuses();
    if (statuses.isEmpty) return;

    // 現在のステータス位置を探す
    final currentIndex = statuses.indexWhere((s) => s.statusId == memo.statusId);
    if (currentIndex == -1) return;

    // 次のインデックス（末尾なら先頭に戻る）
    final nextIndex = (currentIndex + 1) % statuses.length;
    final nextStatus = statuses[nextIndex];

    // メモのステータスを更新
    await updateMemoStatus(memo, nextStatus.statusId!);
  }

  // ===== ステータス取得 =====

  Future<List<Status>> fetchStatuses() => _memoRepo.fetchAllStatuses();

  Future<Status> fetchStatusById(int statusId) =>
      _memoRepo.fetchStatusById(statusId);

  // ===== 編集状態制御 =====
  void startEditing(int memoId) {
    _editingMemoId = memoId;
    notifyListeners();
  }

  void stopEditing() {
    _editingMemoId = null;
    notifyListeners();
  }

  final Map<int, Status> _statusMap = {};


  /// ① 非同期：SQLiteアクセス
  Future<void> loadStatuses() async {
    final list = await _memoRepo.fetchAllStatuses();
    for (final s in list) {
      _statusMap[s.statusId!] = s;
    }
    notifyListeners();
  }

  /// ② 同期：メモリ参照のみ
  Status fetchStatusByIdSync(int statusId) {
    return _statusMap[statusId]!;
  }


  // ===== 編集完了（内容変更時のみ保存） =====
  Future<void> saveIfChanged(Memo memo, String newText) async {
    final trimmed = newText.trim();
    if (trimmed.isNotEmpty && trimmed != memo.content) {
      await updateMemoContent(memo, trimmed);

      // ホームウィジェットにデータ同期
      await HomeWidgetService.syncHomeWidgetFromApp();
    }
  }

  void setEditingMemo(int memoId) {
    _editingMemoId = memoId;
    notifyListeners();
  }

// ===== UI制御（モーダル表示） =====

// 🧭 現在ステータス変更対象となっているメモ
  Memo? targetMemo;

// 🪄 ステータス一覧表示中のリスト（nullなら非表示）
  List<Status>? showingStatuses;

  Future<void> showStatusListModal(Memo memo, List<Status> list) async {
    targetMemo = memo;
    showingStatuses = list;
    notifyListeners();
  }

  Future<void> hideStatusListModal() async {
    targetMemo = null;
    showingStatuses = null;
    notifyListeners();
  }

}
