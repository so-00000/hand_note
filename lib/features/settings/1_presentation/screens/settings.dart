import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/app_info_section.dart';
import '../widgets/display_mode_selector.dart';
import '../widgets/status_list_section.dart';


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
      context.read<SettingsViewModel>().loadStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SettingsSection(
                title: 'Display:',
                child: DisplayModeSelector(),
              ),
              _SettingsSection(
                title: 'Status:',
                child: StatusListSection(),
              ),
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
/// - 他画面で再利用しないため private class として定義
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
