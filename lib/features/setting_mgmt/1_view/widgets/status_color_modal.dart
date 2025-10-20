import 'package:flutter/material.dart';
import '../../../../core/constants/status_color_mapper.dart';

/// 🎨 ステータスカラー選択モーダル
/// - 色一覧から選択して上位に colorCode（例: '08'）を返す
class StatusColorSelectModal extends StatelessWidget {
  final ValueChanged<String> onColorSelected;

  const StatusColorSelectModal({
    super.key,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 key（'08', '09'...）を一覧化
    final colorCodes = StatusColorMapper.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colorCodes.map((code) {
          final color = getStatusColor(code);
          return GestureDetector(
            onTap: () {
              onColorSelected(code);
              // Navigator.pop(context);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
