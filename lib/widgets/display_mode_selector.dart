import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_notifier.dart';
import '../features/settings/1_presentation/viewmodels/settings_view_model.dart';

/// 🌓 表示モード切替セクション
/// - Light / Dark / Auto のテーマモードを切り替える
/// - ViewModel と ThemeNotifier を連携
class DisplayModeSelector extends StatelessWidget {
  const DisplayModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<SettingsViewModel>();
    final themeNotifier = context.watch<ThemeNotifier>();

    final selectedColor = theme.colorScheme.onSurface;
    final unselectedColor = theme.colorScheme.surface;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: 'light',
              label: Icon(Icons.wb_sunny_outlined),
            ),
            ButtonSegment(
              value: 'dark',
              label: Icon(Icons.nightlight_round),
            ),
            ButtonSegment(
              value: 'auto',
              label: Text('auto'),
            ),
          ],
          selected: {vm.displayMode},
          onSelectionChanged: (value) {
            final mode = value.first;
            vm.updateDisplayMode(mode);

            switch (mode) {
              case 'light':
                themeNotifier.setTheme(ThemeMode.light);
                break;
              case 'dark':
                themeNotifier.setTheme(ThemeMode.dark);
                break;
              default:
                themeNotifier.setTheme(ThemeMode.system);
            }
          },
          style: ButtonStyle(
            side: WidgetStateProperty.all(BorderSide.none),
            backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                  ? selectedColor
                  : unselectedColor,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
