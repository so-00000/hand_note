import 'package:flutter/material.dart';

///メイン（各カード用）
BoxDecoration boxDecoration(ThemeData theme) {
  return BoxDecoration(
    color: theme.colorScheme.surfaceContainer,
    borderRadius: BorderRadius.circular(16),
  );
}

/// テキストボックス用
BoxDecoration textBoxDecoration(ThemeData theme) {
  return BoxDecoration(
    color: theme.colorScheme.surfaceContainer,
    borderRadius: BorderRadius.circular(8),
  );
}