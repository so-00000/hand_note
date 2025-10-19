import 'package:flutter/material.dart';
import 'package:hand_note/core/services/memo_launch_handler.dart';
import 'package:hand_note/features/memo_mgmt/1_view/widgets/memo_card.dart';
import 'package:hand_note/features/memo_mgmt/1_view/widgets/memo_search_bar.dart';
import 'package:provider/provider.dart';
import '../2_view_model/show_memo_list_view_model.dart';

class ShowMemoList extends StatefulWidget {
  const ShowMemoList({super.key});

  @override
  State<ShowMemoList> createState() => _ShowMemoListState();
}

class _ShowMemoListState extends State<ShowMemoList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final vm = context.read<ShowMemoListVM>();
    await vm.loadMemos();

    // ✅ ウィジェット経由で起動した場合の処理
    final memoId = MemoLaunchHandler.memoIdToOpen;
    if (memoId == null) return;

    print('📍 ShowMemoList 起動 MEMO_ID=$memoId');

    final index = vm.memo.indexWhere((m) => m.memoId == memoId || m.memoId == memoId);
    if (index != -1) {
      vm.setEditingMemo(memoId);

      // 🔁 ビルド完了後にスクロール
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

      print('✅ 自動スクロール完了 → 編集対象ID=$memoId');
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShowMemoListVM>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemoSearchBar(
              controller: _searchController,
              onSearch: (query) => vm.searchMemos(query),
            ),
            Expanded(
              child: _buildMemoList(context, vm, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoList(
      BuildContext context, ShowMemoListVM vm, ThemeData theme) {
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (vm.memo.isEmpty) {
      return Center(
        child: Text(
          'まだメモがありません',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadMemos,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: vm.memo.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final memo = vm.memo[index];
          return MemoCard(memo: memo);
        },
      ),
    );
  }
}
