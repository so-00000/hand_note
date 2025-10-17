/// ===============================
/// 🟢 Status モデル
/// ===============================
///
/// - 対応テーブル：`status`
///
class Status {
  final int? statusId;     // ステータスID（主キー）
  final String statusNm;   // ステータス名
  final String colorCd;  // カラーコード

  const Status({
    this.statusId,
    required this.statusNm,
    required this.colorCd,
  });

  ///
  /// Map ⇔ クラス変換
  ///

  /// Map → クラス（DB読み込み用）
  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      statusId: map['status_id'] as int?,
      statusNm: map['status_nm'] ?? '',
      colorCd: map['color_cd'] ?? '',
    );
  }

  /// クラス → Map（DB保存用）
  Map<String, dynamic> toMap() {
    return {
      'status_id': statusId,
      'status_nm': statusNm,
      'color_cd': colorCd,
    };
  }

  ///
  /// copyWith
  ///
  Status copyWith({
    int? statusId,
    String? statusNm,
    String? colorCd,
  }) {
    return Status(
      statusId: statusId ?? this.statusId,
      statusNm: statusNm ?? this.statusNm,
      colorCd: colorCd ?? this.colorCd,
    );
  }
}
