import 'package:flutter/material.dart';

/// ステータス項目を表示する共通ウィジェット
/// 例: Done / In Progress / To Do
class StatusCard extends StatelessWidget {
  final String name;         // ステータス名
  final Color color;         // カラー（円部分）
  final VoidCallback? onTap; // タップ時の処理（任意）
  final bool isAddButton;    // 「＋」ボタン用フラグ

  const StatusCard({
    super.key,
    required this.name,
    required this.color,
    this.onTap,
    this.isAddButton = false,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    // ステータス追加用（+）ボタンの場合
    if (isAddButton) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    // 通常ステータス項目
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF373739),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // カラーサークル
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),

            // ステータス名
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
