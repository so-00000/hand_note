import 'package:flutter/material.dart';
import 'package:hand_note/core/model/memo_with_status_model.dart';
import 'package:provider/provider.dart';

import 'core/screens/main_tab_screen.dart';
import 'core/services/home_widget_service.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_notifier.dart';

import 'features/memo_mgmt/2_view_model/create_memo_view_model.dart';
import 'features/memo_mgmt/2_view_model/show_memo_list_view_model.dart';
import 'features/memo_mgmt/3_model/repository/memo_mgmt_repository.dart';
import 'features/setting_mgmt/2_view_model/settings_view_model.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // ホームウィジェットの同期
  await _syncHomeWidget();

  runApp(
    MultiProvider(
      providers: [
        // テーマ切り替え用
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),

        // 新規作成画面
        ChangeNotifierProvider(create: (_) => CreateMemoVM()),

        // 一覧画面
        ChangeNotifierProvider(create: (_) => ShowMemoListVM()),

        // 設定画面
        ChangeNotifierProvider(create: (_) => SettingsVM()),
      ],
      child: const MyApp(),
    ),
  );
}

/// ホームウィジェットへメモ＋ステータス一覧を送信
Future<void> _syncHomeWidget() async {
  try {
    final mwsRepo = MemoMgmtRepository();
    final mwsList = await mwsRepo.fetchAllMemos();

    print('ログ：App launch: syncing HomeWidget '
        '(${mwsList.length} memos)'
    );

    await HomeWidgetService.syncAllData(
      mwsList: mwsList,
      action: 'launch',
    );

    print('ログ：HomeWidget synced successfully');
  } catch (e, st) {
    print('ログ：Failed to sync HomeWidget: $e');
    print(st);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final themeMode = themeNotifier.themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hand Note',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      home: const MainTabScreen(),
    );
  }
}
