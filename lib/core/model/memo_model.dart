/// ===============================
///  Memo モデル
/// ===============================
///
/// - 対応テーブル：`memos`
///
class Memo {
  final int? memoId;             // メモID（主キー）
  final String? content;      // メモ本文
  final int statusId;       // ステータスID
  final DateTime? createdAt;  // 作成日時
  final DateTime? updatedAt; // 更新日時（null可）

  const Memo({
    this.memoId,
    required this.content,
    required this.statusId,
    required this.createdAt,
    this.updatedAt,
  });

  ///
  /// Map ⇔ クラス変換
  ///

  /// Map → クラス（DB読み込み用）
  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      memoId: map['id'] as int?,
      content: map['content'] ?? '',
      statusId: map['status_id'] as int,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
      map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  /// クラス → Map（DB保存用）
  Map<String, dynamic> toMap() {
    return {
      'id': memoId,
      'content': content,
      'status_id': statusId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ///
  /// copyWith
  ///

  Memo copyWith({
    int? id,
    String? content,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memo(
      memoId: id ?? this.memoId,
      content: content ?? this.content,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
