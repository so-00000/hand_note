import 'package:flutter/foundation.dart';

/// =======================================
/// 🧰 log_util.dart
/// Listや任意オブジェクトを整形して出力するユーティリティ
/// =======================================

/// 📋 任意のList全件をインデックス付きで出力
/// - kDebugMode限定（本番ビルドでは無効）
/// - 型はジェネリクス<T>で対応
/// - ModelにtoString()が実装されていれば可読性が高い
void logList<T>(String title, List<T> list) {
  if (kDebugMode) {
    print('📄 [$title] ${list.length}件');
    if (list.isEmpty) {
      print('（リストは空です）');
      return;
    }
    for (int i = 0; i < list.length; i++) {
      print('[$i] ${list[i]}');
    }
    print('----------------------------------------');
  }
}

/// 💬 任意オブジェクト1件を整形して出力
void logObject(String title, Object? obj) {
  if (kDebugMode) {
    print('🔹 [$title] → $obj');
  }
}
