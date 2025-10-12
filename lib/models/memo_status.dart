// lib/models/memo_status.dart

/// 🟢 ステータスマスタモデル
class MemoStatus {
  final int? id;
  final String name;

  /// 色はカラーコードではなく、アプリ側で固定管理するため optional
  final String? color;

  const MemoStatus({
    this.id,
    required this.name,
    this.color,
  });

  factory MemoStatus.fromMap(Map<String, dynamic> map) {
    return MemoStatus(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}
