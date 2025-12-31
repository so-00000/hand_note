/// ===============================
///  WidgetMemoItem（Widget表示・操作用DTO）
/// ===============================
///
/// - Android / iOS ホームウィジェット共通
/// （App Group / SharedPreferences 用）
///
class MemoHomeWidgetDto {

  final int memoId;         // メモID
  final String content;     // 本文
  final int statusId;       // ステータスID
  final int prevStatusId;   // ステータスID（変更前）

  const MemoHomeWidgetDto({
    required this.memoId,
    required this.content,
    required this.statusId,
    required this.prevStatusId,
  });

  /// DTO ➡ JSON 変換
  Map<String, dynamic> toJson() {
    return {
      'memoId': memoId,
      'content': content,
      'statusId': statusId,
      'prevStatusId': prevStatusId,
    };
  }

  /// JSON ➡ DTO 変換
  factory MemoHomeWidgetDto.fromJson(Map<String, dynamic> json) {
    return MemoHomeWidgetDto(
      memoId: json['memoId'] as int,
      content: json['content'] as String,
      statusId: json['statusId'] as int,
      prevStatusId: json['prevStatusId'] as int,
    );
  }
}
