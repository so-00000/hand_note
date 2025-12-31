/// ===============================
///  WidgetMemoItem（Widget表示用DTO）
/// ===============================
///
/// - ホームウィジェット専用
/// - Domain(Memo) から変換して使用
/// - App Group に JSON として保存される前提
///
class WidgetMemoItem {
  /// メモID（タップ時の識別用）
  final int memoId;

  /// 表示用メモ本文（整形済み・null不可）
  final String content;

  /// ステータス名
  final String statusName;

  /// ステータス色（Color.value）
  final int statusColor;

  const WidgetMemoItem({
    required this.memoId,
    required this.content,
    required this.statusName,
    required this.statusColor,
  });

  /// ===============================
  /// JSON 変換（App Group 保存用）
  /// ===============================

  Map<String, dynamic> toJson() {
    return {
      'memoId': memoId,
      'content': content,
      'statusName': statusName,
      'statusColor': statusColor,
    };
  }

  factory WidgetMemoItem.fromJson(Map<String, dynamic> json) {
    return WidgetMemoItem(
      memoId: json['memoId'] as int,
      content: json['content'] as String,
      statusName: json['statusName'] as String,
      statusColor: json['statusColor'] as int,
    );
  }
}