/// ===============================
///  StatusHomeWidgetDto
/// ===============================
///
/// - ホームウィジェット用ステータスDTO
/// - Android / iOS 共通
/// - MemoHomeWidgetDto.statusId から参照される前提
///
class StatusHomeWidgetDto {

  final int statusId;     // ステータスID（主キー）
  final int sortNo;       // ソート番号
  final String statusNm;  // ステータス名
  final String statusColor;  // ステータス色


  const StatusHomeWidgetDto({
    required this.statusId,
    required this.sortNo,
    required this.statusNm,
    required this.statusColor,
  });

  /// DTO ➡ JSON 変換
  Map<String, dynamic> toJson() {
    return {
      'statusId': statusId,
      'sortNo': sortNo,
      'statusNm': statusNm,
      'statusColor': statusColor,
    };
  }

  /// JSON ➡ DTO 変換
  factory StatusHomeWidgetDto.fromJson(Map<String, dynamic> json) {
    return StatusHomeWidgetDto(
      statusId: json['statusId'] as int,
      sortNo: json['sortNo'] as int,
      statusNm: json['statusNm'] as String,
      statusColor: json['statusColor'] as String,
    );
  }
}
