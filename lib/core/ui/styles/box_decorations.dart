import 'package:flutter/material.dart';

BoxDecoration boxDecoration(ThemeData theme) {
  return BoxDecoration(
    color: theme.colorScheme.surfaceContainer,
    borderRadius: BorderRadius.circular(16),
  );
}