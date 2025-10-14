  // app_themes.dart
  import 'package:flutter/material.dart';
  import 'app_colors.dart';

  class AppThemes {
    // 🌙 ダークテーマ
    static final darkTheme = ThemeData(

      // テーマ
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        // 背景
        surface: AppColors.dark.main,
        // カード背景
        surfaceContainer: AppColors.dark.sub,
        primary: AppColors.dark.primary,
        error: AppColors.dark.error,
      ),

      // テキストスタイル
      textTheme: TextTheme(

        // 本文メイン
        bodyLarge: TextStyle(
          color: AppColors.dark.textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        // 本文サブ
        bodySmall: TextStyle(
          color: AppColors.dark.textSub,
          fontSize: 14,
        ),

        // タイトル用
        titleLarge: TextStyle(
          color: AppColors.dark.textTitle,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        // ボタン上用
        labelLarge: TextStyle(
          color: AppColors.light.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dark.sub,
        contentTextStyle: TextStyle(color: AppColors.dark.textMain),
      ),
    );

    // 🌞 ライトテーマ
    static final lightTheme = ThemeData(

      // テーマ
      brightness: Brightness.light,

      colorScheme: ColorScheme.light(
        // 背景
        surface: AppColors.light.main,
        // カード背景
        surfaceContainer: AppColors.light.sub,
        primary: AppColors.light.primary,
        error: AppColors.light.error,
      ),


      // テキストスタイル
      textTheme: TextTheme(

        // 本文メイン
        bodyLarge: TextStyle(
          color: AppColors.light.textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        // 本文サブ
        bodyMedium: TextStyle(
          color: AppColors.light.textMain,
          fontSize: 14,
        ),

        // 本文サブ
        bodySmall: TextStyle(
          color: AppColors.light.textSub,
          fontSize: 14,
        ),

        // タイトル用
        titleLarge: TextStyle(
          color: AppColors.light.textTitle,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        // ボタン上用
        labelLarge: TextStyle(
          color: AppColors.light.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.light.sub,
        contentTextStyle: TextStyle(color: AppColors.light.textMain),
      ),
    );
  }
