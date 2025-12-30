import 'package:flutter/material.dart';

enum DisplayMode {
  light,
  dark,
  auto,
}

/// 表示モード関連の変換ロジック
extension DisplayModeExtension on DisplayMode {
  /// ThemeMode へ変換
  ThemeMode toThemeMode() {
    switch (this) {
      case DisplayMode.light:
        return ThemeMode.light;
      case DisplayMode.dark:
        return ThemeMode.dark;
      case DisplayMode.auto:
        return ThemeMode.system;
    }
  }
}
