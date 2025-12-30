import 'package:flutter/material.dart';
import 'package:hand_note/features/setting_mgmt/1_view/widgets/component/app_info_section.dart';
import 'package:hand_note/features/setting_mgmt/1_view/widgets/component/display_mode_section.dart';
import 'package:hand_note/features/setting_mgmt/1_view/widgets/component/status_list_section.dart';
import 'package:provider/provider.dart';
import '../../../../core/ui/styles/insets.dart';
import '../../2_view_model/settings_view_model.dart';



/// ========================
/// Class
/// ========================

class Settings extends StatefulWidget {

  ///
  /// フィールド
  ///



  /// コンストラクタ
  const Settings({super.key});

  /// Stateインスタンスの生成
  @override
  State<Settings> createState() => _SettingsState();
}



/// ========================
/// State
/// ========================

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SettingsVM>().loadStatuses();
    });
  }



  /// ========================
  /// UIビルド
  /// ========================
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
                child: DisplayModeSection(),
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


/// ========================
/// private Widget
/// ========================


/// セクションラッパー
/// - タイトルと中身をまとめて1ブロック化
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

      // セクション間の余白
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
