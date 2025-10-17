/// ============================================================
///  Memo・Status結合モデル
/// ============================================================
///
class MemoWithStatus {
  final int? id;        // メモID（主キー）
  final String? content;     // メモ内容
  final int? statusId;      // ステータスID（外部キー）
  final DateTime? createdAt; // 作成日時
  final DateTime? updatedAt; // 更新日時（null可）
  final String? statusNm;   // ステータス名（LEFT JOIN想定でnull可）
  final String? colorCd;    // カラーコード（LEFT JOIN想定でnull可）

  const MemoWithStatus({
    this.id,
    this.content,
    this.statusId,
    this.createdAt,
    this.updatedAt,
    this.statusNm,
    this.colorCd,
  });
}
