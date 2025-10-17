/// ===============================
/// 🧩 MemoWithStatus（共通DTO）
/// ===============================
///
/// memos と status を結合した“受け渡し用”データ構造。
/// - 永続化はしない（DB保存は Entity 側のみ）
/// - ホームウィジェット／メモ画面など複数機能で共通利用
///
/// 期待するJOIN例:
/// SELECT
///   m.memo_id,
///   m.content,
///   m.status_id,
///   m.created_at,
///   m.updated_at,
///   s.status_nm,
///   s.color_cd
/// FROM memos m
/// LEFT JOIN status s ON m.status_id = s.status_id;
///
class MemoWithStatus {

  final int? memoId;           // メモID（主キー）
  final String content;        // メモ内容
  final int? statusId;         // ステータスID（外部キー）
  final DateTime createdAt;    // 作成日時
  final DateTime? updatedAt;   // 更新日時（null可）
  final String? statusNm;      // ステータス名（LEFT JOIN想定でnull可）
  final String? colorCd;       // カラーコード（LEFT JOIN想定でnull可）

  const MemoWithStatus({
    this.memoId,
    required this.content,
    this.statusId,
    required this.createdAt,
    this.updatedAt,
    this.statusNm,
    this.colorCd,
  });

  // ===============================
  // 🔁 JOIN結果の1行(Map)から生成
  // ===============================
  factory MemoWithStatus.fromJoinedMap(Map<String, dynamic> map) {
    return MemoWithStatus(
      memoId: map['memo_id'] is int
          ? map['memo_id']
          : int.tryParse(map['memo_id']?.toString() ?? ''),
      content: map['content']?.toString() ?? '',
      statusId: map['status_id'] is int
          ? map['status_id']
          : int.tryParse(map['status_id']?.toString() ?? ''),
      createdAt: DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      statusNm: map['status_nm']?.toString(),
      colorCd: map['color_cd']?.toString(),
    );
  }

  // ===============================
  // 💾 Map変換（Widget連携・ログ用）
  // ===============================
  Map<String, dynamic> toMap() {
    return {
      'memo_id': memoId,
      'content': content,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status_nm': statusNm,
      'color_cd': colorCd,
    };
  }

  // ===============================
  // 🧩 copyWith
  // ===============================
  MemoWithStatus copyWith({
    int? memoId,
    String? content,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? statusNm,
    String? colorCd,
  }) {
    return MemoWithStatus(
      memoId: memoId ?? this.memoId,
      content: content ?? this.content,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusNm: statusNm ?? this.statusNm,
      colorCd: colorCd ?? this.colorCd,
    );
  }
}
