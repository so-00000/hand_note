/// ===============================
/// 🗒️ Memo Entity
/// ===============================
///
/// 対応テーブル：`memos`
/// 外部キー：status_id → status.status_id
/// created_at / updated_at は DATETIME 型
///
class MemoEntity {
  /// 主キー
  final int? memoId;

  /// 本文
  final String content;

  /// 外部キー（status.status_id）
  final int? statusId;

  /// 作成日時
  final DateTime createdAt;

  /// 更新日時（null可）
  final DateTime? updatedAt;

  const MemoEntity({
    this.memoId,
    required this.content,
    this.statusId,
    required this.createdAt,
    this.updatedAt,
  });

  // ===============================
  // 💾 DB保存用（toMap）
  // ===============================
  Map<String, dynamic> toMap() {
    return {
      if (memoId != null) 'memo_id': memoId,
      'content': content,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ===============================
  // 🔁 DB取得用（fromMap）
  // ===============================
  factory MemoEntity.fromMap(Map<String, dynamic> map) {
    return MemoEntity(
      memoId: map['memo_id'] is int
          ? map['memo_id']
          : int.tryParse(map['memo_id']?.toString() ?? ''),
      content: map['content']?.toString() ?? '',
      statusId: map['status_id'] is int
          ? map['status_id']
          : int.tryParse(map['status_id']?.toString() ?? ''),
      createdAt:
      DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  // ===============================
  // 🧩 copyWith
  // ===============================
  MemoEntity copyWith({
    int? memoId,
    String? content,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoEntity(
      memoId: memoId ?? this.memoId,
      content: content ?? this.content,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
