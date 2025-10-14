import 'package:flutter/material.dart';
import '../../features/memo/1_presentation/screens/create_memo.dart';
import '../../features/memo/1_presentation/screens/memo_list.dart';
import '../../features/settings/1_presentation/screens/settings.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/header_bar.dart';

/// 全体を管理するメイン画面

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  // 各タブに対応する画面
  final List<Widget> _screens = const [
    CreateMemo(),
    MemoList(),
    Settings(),
  ];

  // タブ押下時にbodyを差し替え
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            // ヘッダー
            const HeaderBar(),
            Expanded(child: _screens[_selectedIndex]),
            BottomTabBar(
              currentIndex: _selectedIndex,
              onTabSelected: _onTabTapped
            ),
          ],
        ),
      ),
    );
  }
}
