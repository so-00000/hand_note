import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class SnackBarUtil {
  /// 上部表示用Flushbar（Undo対応）
  static void showTop(
      BuildContext context,
      String message, {
        Color? backgroundColor,
        Color? textColor,
        IconData? icon,
        VoidCallback? onUndo, // ← Undoボタン（任意）
      }) {
    final theme = Theme.of(context);

    Flushbar(
      messageText: Text(
        message,
        style: TextStyle(
          color: textColor ?? theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      icon: icon != null
          ? Icon(icon, color: textColor ?? theme.colorScheme.onPrimary)
          : null,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(12),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 300),

      // ✅ Undo対応
      mainButton: (onUndo != null)
          ? TextButton(
        onPressed: () {
          Navigator.of(context).pop(); // Flushbarを閉じる
          onUndo();
        },
        child: Text(
          '元に戻す',
          style: TextStyle(
            color: textColor ?? theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
    ).show(context);
  }

  /// 成功（Undoなし）
  static void success(BuildContext context, String message) {
    showTop(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      icon: Icons.check_circle,
    );
  }

  /// 成功（Undoあり）
  static void successWithUndo(
      BuildContext context,
      String message,
      VoidCallback onUndo,
      ) {
    showTop(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      icon: Icons.check_circle,
      onUndo: onUndo,
    );
  }

  /// エラー
  static void error(BuildContext context, String message) {
    showTop(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      icon: Icons.error,
    );
  }
}
