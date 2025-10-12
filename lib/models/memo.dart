/// ===============================
/// 🗒️ Memo モデル
/// ===============================
///
/// - SQLiteテーブル：`memos`
/// - ステータスは `status` テーブルと JOIN
/// - created_at / updated_at を DateTime 型で管理
///
class Memo {
  final int? id;
  final String content;
  final int? statusId;         // ステータスID（status.id）
  final String? statusName;    // JOIN結果: ステータス名
  final String? statusColor;   // JOIN結果: color_code（例: "01"〜"14"）
  final DateTime createdAt;    // 作成日時
  final DateTime? updatedAt;   // 更新日時（null可）

  const Memo({
    this.id,
    required this.content,
    this.statusId,
    this.statusName,
    this.statusColor,
    required this.createdAt,
    this.updatedAt,
  });

  /// ===============================
  /// 💾 DB保存用（toMap）
  /// ===============================
  ///
  /// SQLiteはDateTimeをTEXT型で保存するためISO8601文字列に変換。
  ///
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// ===============================
  /// 🔁 JOIN結果からの生成（status_name / status_color対応）
  /// ===============================
  ///
  /// SELECT 句で
  ///   s.name AS status_name,
  ///   s.color_code AS status_color
  /// が含まれることを前提。
  ///
  factory Memo.fromJoinedMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'] as int?,
      content: map['content'] as String,
      statusId: map['status_id'] as int?,
      statusName: map['status_name'] as String?,
      statusColor: map['status_color'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  /// ===============================
  /// 🧩 copyWith
  /// ===============================
  ///
  /// 値を部分的に置き換えて新しいインスタンスを生成。
  ///
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
