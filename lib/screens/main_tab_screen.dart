import 'package:flutter/material.dart';
import 'package:hand_note/widgets/bottom_tab_bar.dart';
import '../widgets/header_bar.dart';
import 'create_task_dark.dart';
import 'tasks_list_dark.dart';
import 'settings_dark.dart';

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
    CreateTaskDark(),
    TasksListDark(),
    SettingsDark(),
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

            // ヘッダー呼び出し
            const HeaderBar(),


            Expanded(child: _screens[_selectedIndex]),

            // 下部タブ呼び出し
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
