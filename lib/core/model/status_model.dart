/// ===============================
/// 🟢 Status モデル
/// ===============================
/// 対応テーブル：status
class Status {
  final int? statusId;       // ステータスID（PK。新規挿入時は null）
  final int? sortNo;          // 並び順
  final String statusNm;     // ステータス名
  final String statusColor;  // カラーコード

  const Status({
    this.statusId,
    this.sortNo,
    required this.statusNm,
    required this.statusColor,
  });

  /// Map → クラス（DB読み込み用）
  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      statusId: map['status_id'] as int?,         // ← nullable で受ける
      sortNo: map['sort_no'] as int,              // ← キーは sort_no
      statusNm: map['status_nm'] as String? ?? '',
      statusColor: map['status_color'] as String? ?? '',
    );
  }

  /// クラス → Map（更新用：id含む）
  Map<String, dynamic> toMap() {
    return {
      'status_id': statusId,
      'sort_no': sortNo,
      'status_nm': statusNm,
      'status_color': statusColor,
    };
  }

  /// クラス → Map（挿入用：idは含めない）
  Map<String, dynamic> toInsertMap() {
    return {
      'sort_no': sortNo,
      'status_nm': statusNm,
      'status_color': statusColor,
    };
  }

  /// copyWith
  Status copyWith({
    int? statusId,
    int? sortNo,
    String? statusNm,
    String? statusColor,
  }) {
    return Status(
      statusId: statusId ?? this.statusId,
      sortNo: sortNo ?? this.sortNo,
      statusNm: statusNm ?? this.statusNm,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}
