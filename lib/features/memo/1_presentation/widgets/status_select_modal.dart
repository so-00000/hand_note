import 'package:flutter/material.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../3_domain/entities/memo_status.dart';

/// 🟣 ステータス選択モーダル
/// - 丸いカラーアイコンを並べてステータス選択
/// - 選択時に onStatusSelected() コールバックを返す
class StatusSelectModal extends StatelessWidget {
  final List<MemoStatus> statuses;

  /// 選択されたステータスを上位へ返す
  final ValueChanged<MemoStatus> onStatusSelected;

  const StatusSelectModal({
    super.key,
    required this.statuses,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: statuses.map((status) {
          final colorCode = status.colorCode ?? '08';
          final color = getStatusColor(colorCode);

          return GestureDetector(
            onTap: () {
              // ✅ ステータス選択コールバック
              onStatusSelected(status);

              // 💡 モーダルを閉じる
              Navigator.pop(context);
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
