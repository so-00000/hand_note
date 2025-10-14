import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/screens/main_tab_screen.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_notifier.dart';

import 'features/memo/1_presentation/viewmodels/create_memo_view_model.dart';
import 'features/memo/1_presentation/viewmodels/memo_list_view_model.dart';
import 'features/settings/1_presentation/viewmodels/settings_view_model.dart';

void main() {
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
