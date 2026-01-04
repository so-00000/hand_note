import 'package:flutter/material.dart';
import 'package:hand_note/core/widgets/footer.dart';
import 'package:hand_note/features/memo_mgmt/1_view/widgets/component/memo_search_bar.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/styles/box_decorations.dart';
import '../../../core/ui/styles/insets.dart';
import '../../../core/widgets/header.dart';
import '../2_view_model/show_memo_list_view_model.dart';



/// ========================
/// Class
/// ========================
class MainPage extends StatefulWidget {

  /// コンストラクタ
  const MainPage({super.key});


  static const _bgColor = Color(0xFFE6E5EF);
  static const _cardColor = Color(0xFF373739);


  /// Stateインスタンスの生成
  @override
  State<MainPage> createState() => _MainPageState();
}



/// ========================
/// State
/// ========================

class _MainPageState extends State<MainPage>{


  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _init();
    });
  }


  Future<void> _init() async {

    ///
    /// ホームウィジェット経由で起動した場合
    ///
    print('📍 実装中');
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: Insets.safePadding),

          // 表示内容のセット
          child: Column(
            children: [

              /// ヘッダー
              Header(),

              const SizedBox(height: 6),

              /// 検索バー
              // MemoSearchBar(
              //   controller: _searchController,
              //   onSearch: (query) => vm.searchMemos(query),
              // ),

              Expanded(
                child: SingleChildScrollView(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildFilterArea(theme),
                      const SizedBox(height: 28),
                      _buildCategoryArea(theme),
                    ],
                  ),
                ),
              ),

              /// フッター
              Footer(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // Header
  // =========================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Icon(Icons.more_horiz, color: Color(0xFF373739)),
        ],
      ),
    );
  }

  // =========================
  // Filter Area
  // =========================

  /// 開発メモ：動的にする
  Widget _buildFilterArea(
      ThemeData theme
      ) {
    return Column(
      children: [
        Row(
          children: [

            Expanded(
              child: _buildFilterCard(
                theme: theme,
                iconBg: const Color(0xFF0C79FE),
                label: '今日',
                count: '1',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterCard(
                theme: theme,
                iconBg: const Color(0xFFF14C3B),
                label: '繰り返し',
                count: '0',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [

            Expanded(
              child: _buildFilterCard(
                theme: theme,
                iconBg: const Color(0xFF0C79FE),
                label: '今日',
                count: '1',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterCard(
                theme: theme,
                iconBg: const Color(0xFFF14C3B),
                label: '繰り返し',
                count: '0',
              ),
            ),
          ],
        ),
        // const SizedBox(height: 15),
      ],
    );
  }

  /// UI：フィルターカード
  Widget _buildFilterCard({
    required ThemeData theme,
    required Color iconBg,
    required String label,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),

      decoration: boxDecoration(theme),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // 1列め
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// アイコン
              CircleAvatar(
                radius: 16,
                backgroundColor: iconBg,
                child: Icon(Icons.circle, size: 12, color: Colors.red),
              ),

              /// メモ数（フィルターごと）
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 2列め
          /// フィルター名
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // =========================
  // Category Area
  // =========================
  Widget _buildCategoryArea(
      ThemeData theme
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'カテゴリ',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 8),

        _buildCategoryItem(theme, '買い物リスト', '1'),
        const SizedBox(height: 8),
        _buildCategoryItem(theme, '削除', '1'),
      ],
    );
  }


  /// UI：カテゴリカード
  Widget _buildCategoryItem(
      ThemeData theme,
      String title,
      String count
      ) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: boxDecoration(theme),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFA032),
                child: Icon(Icons.list, color: Colors.red, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  // // =========================
  // // Footer
  // // =========================
  // Widget _buildFooter() {
  //   return Container(
  //     height: 52,
  //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
  //     decoration: const BoxDecoration(
  //       // color: _bgColor,
  //       border: Border(top: BorderSide(width: 0.3)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         ElevatedButton.icon(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.white,
  //             foregroundColor: const Color(0xFF1E2124),
  //             shape: const StadiumBorder(),
  //           ),
  //           onPressed: () {},
  //           icon: const Icon(Icons.add),
  //           label: const Text(
  //               'メモを作成'),
  //         ),
  //         const Icon(Icons.settings),
  //       ],
  //     ),
  //   );
  // }
}
