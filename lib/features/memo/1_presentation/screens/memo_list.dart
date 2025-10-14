import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/memo_list_view_model.dart';
import '../widgets/memo_card.dart';
import '../widgets/memo_search_bar.dart';

/// 🗂 メモ一覧画面
/// - 検索バー + メモリスト
/// - スワイプ削除 / 編集 / ステータス変更に対応
class MemoList extends StatefulWidget {
  const MemoList({super.key});

  @override
  State<MemoList> createState() => _MemoListState();
}

class _MemoListState extends State<MemoList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 🌀 初回レンダリング後にメモ一覧をロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoListViewModel>().loadMemos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemoListViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 検索バー
            MemoSearchBar(
              controller: _searchController,
              onSearch: (query) => vm.searchMemos(query),
            ),

            // 📜 メモリスト
            Expanded(
              child: _buildMemoList(context, vm, theme),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧩 メモリスト表示部分
  Widget _buildMemoList(
      BuildContext context, MemoListViewModel vm, ThemeData theme) {
    // ローディング中
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    // 登録データが0件のとき
    if (vm.memos.isEmpty) {
      return Center(
        child: Text(
          'まだメモがありません',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 登録データが1件以上ある場合
    return RefreshIndicator(
      // 下スワイプで再読み込み
      onRefresh: vm.loadMemos,
      color: theme.colorScheme.primary,

      child: ListView.builder(
        itemCount: vm.memos.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // 各メモ行を描画
        itemBuilder: (context, index) {
          final memo = vm.memos[index];
          return MemoCard(memo: memo);
        },
      ),
    );
  }
}
