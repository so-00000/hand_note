import 'package:flutter/material.dart';

import '../../../../../core/ui/styles/box_decorations.dart';

/// ℹ️ アプリ情報セクション
/// - エディション・バージョン情報を表示
/// - 今後「課金誘導」や「設定リンク」等を追加する拡張にも対応可能



/// ========================
/// Class
/// ========================

class AppInfoSection extends StatelessWidget {

  ///
  /// コンストラクタ
  ///

  const AppInfoSection({super.key});



  /// ========================
  /// UIビルド
  /// ========================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: boxDecoration(theme),
      padding: const EdgeInsets.all(16),

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

              // /// リンクアイコン
              // Icon(
              //   Icons.circle,
              //   color: theme.colorScheme.primary,
              //   size: 8,
              // ),
              // const SizedBox(width: 6),

              /// リンクテキスト
              Text(
                '☻ Thank you !',
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
