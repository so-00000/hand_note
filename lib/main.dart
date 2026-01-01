import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';

import 'core/screens/main_tab_screen.dart';
import 'core/services/home_widget_service.dart';
import 'core/services/memo_launch_handler.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_notifier.dart';

import 'features/memo_mgmt/2_view_model/create_memo_view_model.dart';
import 'features/memo_mgmt/2_view_model/show_memo_list_view_model.dart';
import 'features/setting_mgmt/2_view_model/settings_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  debugPrint('📤 Saving memo_list to AppGroup');

  await HomeWidget.setAppGroupId('group.com.ttperry.handnote');

  // ✅ Cold Start（ホームウィジェット経由で起動）
  final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  if (uri != null && uri.queryParameters['MEMO_ID'] != null) {
    final memoId = int.tryParse(uri.queryParameters['MEMO_ID']!);
    if (memoId != null) {
      MemoLaunchHandler.setMemoId(memoId);
      print('🧭 Cold Start MEMO_ID=$memoId');
    }
  }

  // ✅ （ホームウィジェット → アプリ）初回同期（Cold Start対応）
    // await HomeWidgetService.syncAppFromHomeWidget();

  // ✅ アプリ起動
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => CreateMemoVM()),
        ChangeNotifierProvider(create: (_) => ShowMemoListVM()),
        ChangeNotifierProvider(create: (_) => SettingsVM()),
      ],
      child: const MyApp(),
    ),
  );
}

/// =================================
/// 🏠 アプリ本体
/// =================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// ✅ ライフサイクル監視を追加（WidgetsBindingObserver）
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // 🔹 ライフサイクル監視を登録
    WidgetsBinding.instance.addObserver(this);

    // ✅ Warm Start（ホームウィジェットをタップして復帰）
    HomeWidget.widgetClicked.listen((Uri? uri) async {
      // 🔸 同期実行（非同期で十分）
      unawaited(HomeWidgetService.syncAppFromHomeWidget());

      if (uri != null && uri.queryParameters['MEMO_ID'] != null) {
        final memoId = int.tryParse(uri.queryParameters['MEMO_ID']!);
        if (memoId != null) {
          print('🔥 Warm Start MEMO_ID=$memoId');
          MemoLaunchHandler.setMemoId(memoId);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainTabScreen(initialTabIndex: 1),
              ),
                  (route) => false,
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // 🔹 ライフサイクル監視を解除
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ アプリがフォアグラウンドに戻った時（手動復帰含む）
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('📲 App resumed → 同期実行');

      // 1️⃣ 同期を待ってからリロード
      await HomeWidgetService.syncAppFromHomeWidget();

      // 2️⃣ 一覧再読込（最新DB内容でUI更新）
      final vm = Provider.of<ShowMemoListVM>(
        navigatorKey.currentContext!,
        listen: false,
      );
      await vm.loadMemos(); // ←ここもawaitして安全に
    }
  }



  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Hand Note',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeNotifier.themeMode,
      home: const MainTabScreen(initialTabIndex: 0),
    );
  }
}
