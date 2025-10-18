import 'package:flutter/material.dart';
import 'package:hand_note/features/memo_mgmt/1_view/widgets/memo_card.dart';
import 'package:hand_note/features/memo_mgmt/1_view/widgets/memo_search_bar.dart';
import 'package:provider/provider.dart';
import '../2_view_model/show_memo_list_view_model.dart';

/// 🗂 メモ一覧画面
/// - 検索バー + メモリスト
/// - スワイプ削除 / 編集 / ステータス変更に対応
class ShowMemoList extends StatefulWidget {
  const ShowMemoList({super.key});

  @override
  State<ShowMemoList> createState() => _ShowMemoListState();
}

class _ShowMemoListState extends State<ShowMemoList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 🌀 初回レンダリング後にメモ一覧をロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShowMemoListVM>().loadMemos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      BuildContext context, ShowMemoListVM vm, ThemeData theme) {
    // ローディング中
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    // 登録データが0件のとき
    if (vm.memoWithStatus.isEmpty) {
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
        itemCount: vm.memoWithStatus.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // 各メモ行を描画
        itemBuilder: (context, index) {
          final memoWithStatus = vm.memoWithStatus[index];
          return MemoCard(memoWithStatus: memoWithStatus);
        },
      ),
    );
  }
}
