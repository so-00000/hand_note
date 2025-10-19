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
import 'features/memo_mgmt/3_model/repository/memo_mgmt_repository.dart';
import 'features/setting_mgmt/2_view_model/settings_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Cold Start（完全終了状態からの起動）
  final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  if (uri != null && uri.queryParameters['MEMO_ID'] != null) {
    final memoId = int.tryParse(uri.queryParameters['MEMO_ID']!);
    if (memoId != null) {
      MemoLaunchHandler.setMemoId(memoId);
      print('🧭 Cold Start MEMO_ID=$memoId');
    }
  }

  // ✅ ホームウィジェットとの同期
  await syncHomeWidget();

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

/// ✅ ホームウィジェットへのデータ送信
Future<void> syncHomeWidget() async {
  try {
    final repo = MemoMgmtRepository();
    final memoList = await repo.fetchAllMemos();
    final statusList = await repo.fetchAllStatuses();

    await HomeWidgetService.syncAllData(
      memoList: memoList,
      statusList: statusList,
      action: 'launch',
    );

    print('✅ HomeWidget synced successfully');
  } catch (e, st) {
    print('❌ Failed to sync HomeWidget: $e');
    print(st);
  }
}

/// =================================
/// 🏠 アプリ本体
/// =================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // ✅ Warm Start（バックグラウンドからの復帰）対応
    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null && uri.queryParameters['MEMO_ID'] != null) {
        final memoId = int.tryParse(uri.queryParameters['MEMO_ID']!);
        if (memoId != null) {
          print('🔥 Warm Start MEMO_ID=$memoId');
          MemoLaunchHandler.setMemoId(memoId);

          // Flutterツリーが描画済みならNavigatorで画面を開く
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainTabScreen(initialTabIndex: 1),
              ),
                  (route) => false, // スタックをリセットして切り替え
            );
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // 🔑 Warm Start遷移に必須
      title: 'Hand Note',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeNotifier.themeMode,
      home: const MainTabScreen(initialTabIndex: 0),
    );
  }
}
