import 'package:flutter/material.dart';
import '../../../../../core/constants/status_color_mapper.dart';
import '../../../2_view_model/settings_view_model.dart';
import 'package:provider/provider.dart';

class StatusAddModal extends StatefulWidget {
  const StatusAddModal({super.key});

  @override
  State<StatusAddModal> createState() => _StatusAddModalState();
}

class _StatusAddModalState extends State<StatusAddModal> {
  String newName = '';
  String? selectedColorCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<SettingsVM>();

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Text(
          '新しいステータスを追加',
          style: theme.textTheme.titleLarge
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'ステータス名を入力',
              hintStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                // fontSize: 18,
                // fontWeight: FontWeight.normal,
              ),
            ),
            onChanged: (val) => newName = val.trim(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: StatusColorPalette.map((colorMap) {
              final code = colorMap['code'] as String;
              final color = (colorMap['color'] ?? Colors.grey) as Color;
              final isSelected = selectedColorCode == code;

              return GestureDetector(
                onTap: () => setState(() => selectedColorCode = code),
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
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              color: theme.colorScheme.surfaceContainer,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (newName.isEmpty || selectedColorCode == null) return;
            final success = await vm.addStatus(newName, selectedColorCode!);
            if (context.mounted) {
              Navigator.pop(context, success);
            }
          },
          child: Text(
            '追加',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              color: theme.colorScheme.surfaceContainer,
            ),
          ),
        ),
      ],
    );
  }
}
