import 'dart:async';

import 'package:flutter/material.dart';
import '../../features/memo_mgmt/1_view/create_memo.dart';
import '../../features/memo_mgmt/1_view/show_memo_list.dart';
import '../../features/setting_mgmt/1_view/mgmt_settings.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/header_bar.dart';
import '../services/memo_launch_handler.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _selectedIndex;
  final List<Widget> _screens = const [CreateMemo(), ShowMemoList(), Settings()];
  late final StreamSubscription<int> _memoIdSubscription;

  @override
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;

    switch (MemoLaunchHandler.memoIdToOpen) {
      case null:
      // 何もしない
        break;

      case 0:
        _selectedIndex = 0;
        print('🧭 Cold Start → ホームタブに切替');
        break;

      default:
        _selectedIndex = 1;
        print('🧭 Cold Start → 一覧タブに切替');
        break;
    }
  }


  @override
  void dispose() {
    _memoIdSubscription.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderBar(),
            Expanded(child: _screens[_selectedIndex]),
            BottomTabBar(
              currentIndex: _selectedIndex,
              onTabSelected: _onTabTapped,
            ),
          ],
        ),
      ),
    );
  }
}
