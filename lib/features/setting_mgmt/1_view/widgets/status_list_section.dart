import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/status_codes.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../2_view_model/settings_view_model.dart';
import 'status_card.dart';

/// 🎨 ステータス一覧セクション
/// - 現在登録されているステータスを一覧表示
/// - スワイプで削除 / ＋ボタンで追加
class StatusListSection extends StatelessWidget {
  const StatusListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<SettingsVM>();

    return Column(
      children: [
        for (final s in vm.statusList)
          Dismissible(
            key: Key(s.statusId.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: theme.colorScheme.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: Icon(Icons.delete, color: theme.colorScheme.onPrimary),
            ),
            confirmDismiss: (_) async {
              if (isFixedStatus(s.statusColor)) {
                _showSnack(context, '固定ステータスは削除できません');
                return false;
              }
              return true;
            },
            onDismissed: (_) async {
              await vm.deleteStatus(s.statusId ?? 0, s.statusColor);
              _showSnack(context, '「${s.statusNm}」を削除しました');
            },
            child: StatusCard(
              name: s.statusNm,
              color: getStatusColor(s.statusColor),
            ),
          ),

        // ステータス追加ボタン
        StatusCard(
          name: '+',
          color: theme.colorScheme.surfaceContainer,
          isAddButton: true,
          onTap: () => _showAddStatusDialog(context, vm),
        ),
      ],
    );
  }

  /// スナックバー表示
  void _showSnack(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// ステータス追加ダイアログ
  Future<void> _showAddStatusDialog(
      BuildContext context, SettingsVM vm) async {
    final theme = Theme.of(context);
    String newName = '';
    String? selectedColorCode;

    // カスタムステータス数を制限
    final customCount =
        vm.statusList.where((s) => !isFixedStatus(s.statusColor)).length;
    if (customCount >= 4) {
      _showSnack(context, '追加できるステータスは最大4件までです');
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
                        borderSide:
                        BorderSide(color: theme.colorScheme.onSurface),
                      ),
                    ),
                    onChanged: (val) => newName = val.trim(),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: kStatusColorPalette.map((colorMap) {
                      final code = colorMap['code'] as String;
                      final color = (colorMap['color'] ?? Colors.grey) as Color;
                      final isSelected = selectedColorCode == code;

                      return GestureDetector(
                        onTap: () =>
                            setInnerState(() => selectedColorCode = code),
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
                    final success =
                    await vm.addStatus(newName, selectedColorCode!);
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (success) {
                        _showSnack(context, '「$newName」を追加しました');
                      } else {
                        _showSnack(context, 'ステータス追加に失敗しました');
                      }
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
}
