/// ===============================
/// 🗒️ Memo モデル
/// ===============================
///
/// - SQLiteテーブル：`memos`
/// - ステータスは `status` テーブルと JOIN
/// - created_at / updated_at は TEXT(ISO8601文字列) で保存
///
class Memo {
  final int? id;
  final String content;

  /// 🔗 ステータス関連
  final int? statusId;        // status.id
  final String? statusName;   // JOIN結果: status.name
  final String? statusColor;  // JOIN結果: status.color_code

  /// 📅 日時情報
  final DateTime createdAt;   // 作成日時
  final DateTime? updatedAt;  // 更新日時（null可）

  const Memo({
    this.id,
    required this.content,
    this.statusId,
    this.statusName,
    this.statusColor,
    required this.createdAt,
    this.updatedAt,
  });

  // ===============================
  // 💾 DB保存用（toMap）
  // ===============================
  //
  // SQLiteはDateTimeをTEXTで扱うため、ISO8601形式で保存。
  //
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ===============================
  // 🔁 DB取得用（memos単体からの生成）
  // ===============================
  //
  // JOINなしで memos テーブルだけを SELECT した場合に使用。
  //
  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      content: map['content'] ?? '',
      statusId: map['status_id'] is int
          ? map['status_id']
          : int.tryParse(map['status_id']?.toString() ?? ''),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  // ===============================
  // 🔁 JOIN結果からの生成
  // ===============================
  //
  // SELECT句に以下を含むことを前提：
  //   s.name AS status_name,
  //   s.color_code AS status_color
  //
  factory Memo.fromJoinedMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      content: map['content'] ?? '',
      statusId: map['status_id'] is int
          ? map['status_id']
          : int.tryParse(map['status_id']?.toString() ?? ''),
      statusName: map['status_name'] as String?,
      statusColor: map['status_color'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  // ===============================
  // 🧩 copyWith
  // ===============================
  //
  // 値を部分的に置き換えて新しいインスタンスを生成。
  //
  Memo copyWith({
    int? id,
    String? content,
    int? statusId,
    String? statusName,
    String? statusColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memo(
      id: id ?? this.id,
      content: content ?? this.content,
      statusId: statusId ?? this.statusId,
      statusName: statusName ?? this.statusName,
      statusColor: statusColor ?? this.statusColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
