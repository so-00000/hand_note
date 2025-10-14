import 'package:flutter/material.dart';

/// 🎨 アプリ全体で共通して使うカラーパレット定義
class AppColors {
  // === 🌙 ダークテーマ用 ===
  static final dark = _DarkColors();

  // === 🌞 ライトテーマ用 ===
  static final light = _LightColors();
}

/// 🌙 ダークテーマカラーセット
class _DarkColors {
  _DarkColors();

  // メイン
  final Color main = Color(0xFF000000);

  // サブ（入力欄やカードの背景）
  final Color sub = Color(0xFF1C1C1E);

  // アクセントカラー
  final Color primary = Color(0xFF007AFF);

  // アクセントカラー上（ボタン）
  final Color onPrimary = Colors.white;

  // アイコン
  final Color icon = Colors.white;

  // 選択中アイコン
  final Color selectedIcon = Color(0xFF1C1C1E);

  // タイトルテキスト
  final Color textTitle = Colors.white;

  // メインテキスト
  final Color textMain = Colors.white;

  // サブテキスト・ヒント（半透明白）
  final Color textSub = Color(0x99EBEBF5);

  // 成功（SnackBar 成功など）
  final Color success = Color(0xFF30D158);

  // エラー（SnackBar エラーなど）
  final Color error = Colors.redAccent;
}

/// 🌞 ライトテーマカラーセット
class _LightColors {
  _LightColors();

  // 背景
  final Color main = Color(0xFFE6E5EF);

  // 入力欄やカードなどの背景
  final Color sub = Color(0xFF3E3A3A);

  // メインのボタンやアクセントカラー
  final Color primary = Color(0xFFCED7DC);

  // アクセントカラー上（ボタン）
  final Color onPrimary = Colors.white;

  // アイコン
  final Color icon = Colors.white;

  // 選択中アイコン
  final Color selectedIcon = Color(0xFF1C1C1E);

  // タイトルテキスト
  final Color textTitle = Color(0xFF3E3A3A);

  // メインテキスト
  final Color textMain = Colors.white;

  // サブテキスト・ヒント（半透明白）
  final Color textSub = Color(0x99EBEBF5);

  // 成功（SnackBar 成功など）
  final Color success = Color(0xFF30D158);

  // エラー（SnackBar エラーなど）
  final Color error = Colors.redAccent;
}
