import 'package:flutter/material.dart';
import 'package:hand_note/widgets/status_item.dart';
import 'package:provider/provider.dart';
import '../constants/status_color_mapper.dart';
import '../constants/status_codes.dart';
import '../services/status_service.dart';
import '../theme/theme_notifier.dart';
import '../models/memo_status.dart';

/// ⚙️ 設定画面（ローカルDB版 / sqflite）
class SettingsDark extends StatefulWidget {
  const SettingsDark({super.key});

  @override
  State<SettingsDark> createState() => _SettingsDarkState();
}

class _SettingsDarkState extends State<SettingsDark> {
  String _displayMode = 'auto'; // light / dark / auto
  List<MemoStatus> _statusList = [];
  final StatusService _statusService = StatusService();

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeMode = Provider.of<ThemeNotifier>(context).themeMode;
    setState(() {
      switch (themeMode) {
        case ThemeMode.light:
          _displayMode = 'light';
          break;
        case ThemeMode.dark:
          _displayMode = 'dark';
          break;
        default:
          _displayMode = 'auto';
      }
    });
  }

  // ===== ステータス読込（sqflite） =====
  Future<void> _loadStatuses() async {
    final statuses = await _statusService.fetchAllStatuses();
    setState(() {
      _statusList = statuses;
    });
  }

  // ===== ステータス追加 =====
  Future<void> _addStatusDialog() async {
    String newName = '';
    String? selectedColorCode;
    final theme = Theme.of(context);

    // カスタムステータス数を制限
    final customCount =
        _statusList.where((s) => !isFixedStatus(s.colorCode)).length;
    if (customCount >= 4) {
      _showSnack('追加できるステータスは最大4件までです');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text('新しいステータスを追加', style: theme.textTheme.titleLarge),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'ステータス名を入力',
                      hintStyle: theme.textTheme.bodyMedium,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.onSurface),
                      ),
                    ),
                    onChanged: (val) => newName = val.trim(),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: kStatusColorPalette.map((colorMap) {
                      final code = colorMap['code'];
                      final color = (colorMap['color'] ?? Colors.grey) as Color;
                      final isSelected = selectedColorCode == code;

                      return GestureDetector(
                        onTap: () => setInnerState(() => selectedColorCode = code),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 3,
                            )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'キャンセル',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (newName.isEmpty || selectedColorCode == null) return;
                    try {
                      await _statusService.addCustomStatus(newName, selectedColorCode!);
                      if (context.mounted) {
                        Navigator.pop(context);
                        await _loadStatuses();
                        _showSnack('「$newName」を追加しました');
                      }
                    } catch (e) {
                      _showSnack('ステータス追加に失敗しました');
                    }
                  },
                  child: Text('追加', style: theme.textTheme.bodyLarge),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===== ステータス削除 =====
  Future<void> _deleteStatus(int id, String name, String colorCode) async {
    if (isFixedStatus(colorCode)) {
      _showSnack('固定ステータスは削除できません');
      return;
    }

    await _statusService.deleteStatus(id);
    await _loadStatuses();
    _showSnack('「$name」を削除しました');
  }

  void _showSnack(String message) {
    final theme = Theme.of(context);
    final textColor =
        theme.snackBarTheme.contentTextStyle?.color ?? theme.colorScheme.onPrimary;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    final selectedColor = theme.colorScheme.onSurface;
    final unselectedColor = theme.colorScheme.surface;

    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// === Display Mode ===
              Text(
                'Display:',
                style: theme.textTheme.titleLarge
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 'light',
                        label: Icon(
                          Icons.wb_sunny_outlined,
                          color: _displayMode == 'light'
                              ? theme.colorScheme.surface
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      ButtonSegment(
                        value: 'dark',
                        label: Icon(
                          Icons.nightlight_round,
                          color: _displayMode == 'dark'
                              ? theme.colorScheme.surface
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      ButtonSegment(
                        value: 'auto',
                        label: Text(
                          'auto',
                          style: TextStyle(
                            color: _displayMode == 'auto'
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                    selected: {_displayMode},
                    onSelectionChanged: (value) {
                      final mode = value.first;
                      setState(() => _displayMode = mode);
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
              ),

              const SizedBox(height: 32),

              /// === Status ===
              Text(
                'Status:',
                style: theme.textTheme.titleLarge
              ),
              const SizedBox(height: 12),

              Column(
                children: [

                  for (final s in _statusList)

                    Dismissible(
                      key: Key(s.id.toString()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        if (isFixedStatus(s.colorCode)) {
                          _showSnack('固定ステータスは削除できません');
                          return false;
                        }
                        return true;
                      },
                      background: Container(
                        color: theme.colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: Icon(Icons.delete,
                            color: theme.colorScheme.onPrimary),
                      ),
                      onDismissed: (_) => _deleteStatus(
                        s.id ?? 0,
                        s.name,
                        s.colorCode,
                      ),

                      // ステータスカードの呼び出し
                      child: StatusCard(
                        name: s.name,
                        color: getStatusColor(s.colorCode)
                      ),
                    ),

                    // ステータス追加カード
                    StatusCard(
                      name: '+',
                      color: theme.colorScheme.surfaceContainer,
                      isAddButton: true,
                      onTap: _addStatusDialog,
                    ),

                ],
              ),

              const SizedBox(height: 32),

              // === Info ===
              Text(
                'Info:',
                style: theme.textTheme.titleLarge
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edition : Free',
                            style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500)),
                        Text(
                          'ver 1.0.0 © hand_note',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle,
                            color: theme.colorScheme.primary, size: 8),
                        const SizedBox(width: 6),
                        Text('Buy Now',
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
