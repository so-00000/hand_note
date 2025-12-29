import 'package:flutter/material.dart';
import 'package:hand_note/features/setting_mgmt/3_model/display_mode.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/ui/styles/box_decorations.dart';
import '../../2_view_model/settings_view_model.dart';

/// 🌓 表示モード切替セクション
/// - Light / Dark / Auto のテーマモードを切り替える
/// - ViewModel と ThemeNotifier を連携
class DisplayModeSelector extends StatelessWidget {
  const DisplayModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<SettingsVM>();
    final themeNotifier = context.watch<ThemeNotifier>();


    return Container(
      width: double.infinity,
      decoration: boxDecoration(theme),
      padding: const EdgeInsets.symmetric(horizontal: 6),

      child: SegmentedButton<DisplayMode>(

        /// チェックマークの非表示
        showSelectedIcon: false,

        /// 表示モードの選択肢のセット
        segments: displayModeSegments,

        selected: {vm.displayMode},

        /// 選択時の処理
        onSelectionChanged: (value) {
          final mode = value.first;
          vm.updateDisplayMode(mode);

          themeNotifier.setTheme(mode.toThemeMode());
        },

        style: displayModeButtonStyle(theme),

      ),
    );
  }
}






/// ========================
/// 表示モードの選択肢定義
/// ========================

const List<ButtonSegment<DisplayMode>> displayModeSegments = [

  /// lightモード
  ButtonSegment(
    value: DisplayMode.light,
    label: Icon(Icons.wb_sunny_outlined),
  ),

  /// darkモード
  ButtonSegment(
    value: DisplayMode.dark,
    label: Icon(Icons.nightlight_round),
  ),

  /// システム準拠
  ButtonSegment(
    value: DisplayMode.auto,
    label: Text(
      'auto',
      style: TextStyle(fontSize: 16),
    ),
  ),
];



/// ========================
/// Style
/// ========================

/// 表示モードのボタン

ButtonStyle displayModeButtonStyle(ThemeData theme) {
  final selectedColor = Colors.white;
  final unselectedColor = theme.colorScheme.surfaceContainer;

  return ButtonStyle(
    side: WidgetStateProperty.all(BorderSide.none),
    backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
          ? selectedColor
          : unselectedColor,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
          ? theme.colorScheme.surfaceContainer
          : Colors.white,
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
