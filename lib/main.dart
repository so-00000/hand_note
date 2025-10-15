import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/screens/main_tab_screen.dart';
import 'core/services/home_widget_service.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_notifier.dart';

import 'features/memo/1_presentation/viewmodels/create_memo_view_model.dart';
import 'features/memo/1_presentation/viewmodels/memo_list_view_model.dart';
import 'features/memo/2_application/memo_service.dart';
import 'features/settings/1_presentation/viewmodels/settings_view_model.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // ← 非同期処理の前に必要

  // 🧩 アプリ起動時にウィジェット同期
  await _syncHomeWidgetOnLaunch();

  runApp(
    MultiProvider(
      providers: [
        // テーマ切り替え用
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),

        // 新規作成画面
        ChangeNotifierProvider(create: (_) => CreateMemoViewModel()),

        // 一覧画面
        ChangeNotifierProvider(create: (_) => MemoListViewModel()),

        // 設定画面
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 🏠 アプリ起動時にホームウィジェットへメモ＋ステータス一覧を送信
Future<void> _syncHomeWidgetOnLaunch() async {
  try {
    final memoService = MemoService();
    final memoList = await memoService.fetchAllMemos();

    print('ログ：App launch: syncing HomeWidget '
        '(${memoList.length} memos'
    );

    await HomeWidgetService.syncAllData(
      memoList: memoList.map((m) => {
        'id': m.id,
        'content': m.content,
        'updatedAt': m.updatedAt?.toIso8601String() ?? m.createdAt.toIso8601String(),
        'statusId': m.statusId,
        'statusName': m.statusName,
        'statusColor': m.statusColor,
      }).toList(),
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
