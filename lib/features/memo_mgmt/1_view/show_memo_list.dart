import 'package:flutter/material.dart';
import 'package:hand_note/core/services/memo_launch_handler.dart';
import 'package:hand_note/core/ui/styles/insets.dart';
import 'package:hand_note/features/memo_mgmt/1_view/widgets/component/memo_card.dart';
import 'package:hand_note/features/memo_mgmt/1_view/widgets/component/memo_search_bar.dart';
import 'package:hand_note/features/memo_mgmt/1_view/widgets/component/modal_status_list.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/status_color_mapper.dart';
import '../../../core/3_model/model/status_model.dart';
import '../2_view_model/show_memo_list_view_model.dart';

/// ========================
/// Class
/// ========================

class ShowMemoList extends StatefulWidget {


  /// コンストラクタ
  const ShowMemoList({super.key});

  /// Stateインスタンスの生成
  @override
  State<ShowMemoList> createState() => _ShowMemoListState();
}



/// ========================
/// State
/// ========================

class _ShowMemoListState extends State<ShowMemoList> {

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _init();
    });
  }

  Future<void> _init() async {

    /// メモ・ステータスの全データを取得
    final vm = context.read<ShowMemoListVM>();
    await vm.loadMemos();
    await vm.loadStatuses();

    ///
    /// ホームウィジェット経由で起動した場合
    ///

    // 編集中のメモIDを取得
    final memoId = MemoLaunchHandler.memoIdToOpen;
    if (memoId == null) return;

    print('📍 ホームウィジェット➡ShowMemoList起動 MEMO_ID=$memoId');

    final index = vm.memo.indexWhere((m) => m.memoId == memoId);
    if (index != -1) {
      vm.setEditingMemo(memoId);

      // ビルド完了後にスクロール
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      final position = (index * 80.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      await _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      print('⚠️ MEMO_ID=$memoId のメモが見つかりません');
    }

    MemoLaunchHandler.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }



  /// ========================
  /// UIビルド
  /// ========================
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShowMemoListVM>();
    final theme = Theme.of(context);


    return Scaffold(
      body: SafeArea(
        child: Padding(

          // 表示領域のセット
          padding: const EdgeInsets.all(Insets.safePadding),

          // 表示内容のセット
          child: Column(
            children: [

              /// 検索バー
              MemoSearchBar(
                controller: _searchController,
                onSearch: (query) => vm.searchMemos(query),
              ),

              const SizedBox(height: 12),

              /// メモ一覧
              Expanded(
                child: Stack(
                  children: [

                    // メモ一覧をビルド
                    _buildMemoList(context, vm, theme, _scrollController),

                    // モーダルをリスト下端に配置
                    if (vm.showingStatuses != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: StatusListModal(
                            key: const ValueKey('status_modal'),
                            statuses: vm.showingStatuses!,
                            onSelected: (status) async {
                              await vm.updateMemoStatus(
                                vm.targetMemo!,
                                status.statusId!,
                              );
                              vm.hideStatusListModal();
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/// ========================
/// private Widget
/// ========================

/// メモ一覧エリア
Widget _buildMemoList(
    BuildContext context,
    ShowMemoListVM vm,
    ThemeData theme,
    ScrollController scrollController
    ){
  // 読み込み中の場合
  if (vm.isLoading) {
    return Center(
      child: CircularProgressIndicator(color: theme.colorScheme.primary),
    );
  }

  // メモ0件の場合
  if (vm.memo.isEmpty) {
    return Center(
      child: Text(
        'まだメモがありません',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  // UIビルド
  return RefreshIndicator(
    onRefresh: vm.loadMemos,
    color: theme.colorScheme.primary,

    // メモ一覧（カードのリスト）
    child: ListView.builder(
      controller: scrollController,
      itemCount: vm.memo.length,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),

      // メモ単体（カード1枚）
      itemBuilder: (context, index) {
        final memo = vm.memo[index];

        // ステータスの取得
        final status = vm.fetchStatusByIdSync(memo.statusId);
        final statusColor = getStatusColor(status.statusColor);

        // ホームウィジェットから遷移してきた編集中のメモ（メモIDとターゲットメモIDが一致する）に、フラグをたてる
        final bool isInitiallyEditing =
            vm.targetMemo?.memoId == memo.memoId;

        return MemoCard(
          memo: memo,
          status: status,
          statusColor: statusColor,
          isInitiallyEditing: isInitiallyEditing,

          ///
          /// UIイベント
          ///

          // スワイプ：メモ削除
          onDelete: () {
            vm.deleteMemo(context, memo);
          },

          // ステータス円タップ：ステータス切り替え（未完 ⇔ 完了）
          onToggleStatus: () {
            vm.toggleMemoStatus(memo);
          },

          // ステータス円長押し：ステータス一覧表示
          onRequestStatusList: () async {
            final statuses = await vm.fetchStatuses();
            vm.showStatusListModal(memo, statuses);
          },

          // ステータス名タップ：ステータス順送り
          onTapStatusName: () {
            vm.cycleStatusBySortNo(memo);
          },

          // テキスト編集：メモ本文更新
          onUpdateContent: (text) {
            vm.updateMemoContent(memo, text);
          },
        );

      },
    ),
  );
}
