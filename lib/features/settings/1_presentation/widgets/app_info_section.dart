import 'package:flutter/material.dart';

/// ℹ️ アプリ情報セクション
/// - エディション・バージョン情報を表示
/// - 今後「課金誘導」や「設定リンク」等を追加する拡張にも対応可能
class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
              Text(
                'Edition : Free',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'ver 1.0.0 © hand_note',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.circle,
                color: theme.colorScheme.primary,
                size: 8,
              ),
              const SizedBox(width: 6),
              Text(
                'Buy Now',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
