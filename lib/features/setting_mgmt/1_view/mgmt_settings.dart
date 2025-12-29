import 'package:flutter/material.dart';
import 'package:hand_note/features/setting_mgmt/1_view/widgets/app_info_section.dart';
import 'package:hand_note/features/setting_mgmt/1_view/widgets/display_mode_selector.dart';
import 'package:hand_note/features/setting_mgmt/1_view/widgets/status_list_section.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/styles/insets.dart';
import '../2_view_model/settings_view_model.dart';


/// ⚙️ 設定画面（ローカルDB版 / sqflite）
///
/// - 各セクションはこの画面専用の `_SettingsSection` でラップ
/// - タイトル＋コンテンツをセットで扱い、見た目を統一
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SettingsVM>().loadStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(

          // 表示領域のセット
          padding: const EdgeInsets.all(Insets.safePadding),

          // 表示内容のセット
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              // 表示モードセクション
              _SettingsSection(
                title: 'Display:',
                child: DisplayModeSelector(),
              ),

              // ステータスセクション
              _SettingsSection(
                title: 'Status:',
                child: StatusListSection(),
              ),

              // App情報セクション
              _SettingsSection(
                title: 'Info:',
                child: AppInfoSection(),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

/// 📦 設定画面専用セクションラッパー
/// - タイトルと中身をまとめて1ブロック化
///
class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
