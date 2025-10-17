/// ===============================
/// 🟢 ステータスマスタ Entity
/// ===============================
///
/// 対応テーブル: `status`
/// カラム構成:
///   - status_id (INTEGER PRIMARY KEY AUTOINCREMENT)
///   - status_nm (TEXT NOT NULL)
///   - color_cd (TEXT NOT NULL)
///
class StatusEntity {
  /// 主キー
  final int? statusId;

  /// ステータス名（例：「完了」「未完了」「進行中」など）
  final String statusNm;

  /// カラーコード（例：「01」「02」「03」など）
  /// UI側で `getStatusColor(code)` により実際のColorへ変換
  final String colorCd;

  const StatusEntity({
    this.statusId,
    required this.statusNm,
    required this.colorCd,
  });

  // ===============================
  // 🔁 Map → Model 変換
  // ===============================
  factory StatusEntity.fromMap(Map<String, dynamic> map) {
    return StatusEntity(
      statusId: map['status_id'] is int
          ? map['status_id']
          : int.tryParse(map['status_id']?.toString() ?? ''),
      statusNm: map['status_nm']?.toString() ?? '',
      colorCd: map['color_cd']?.toString() ?? '',
    );
  }

  // ===============================
  // 💾 Model → Map 変換
  // ===============================
  Map<String, dynamic> toMap() {
    return {
      if (statusId != null) 'status_id': statusId,
      'status_nm': statusNm,
      'color_cd': colorCd,
    };
  }

  // ===============================
  // 🧩 copyWith
  // ===============================
  //
  // 値を部分的に変更して新しいインスタンスを生成。
  //
  StatusEntity copyWith({
    int? statusId,
    String? statusNm,
    String? colorCd,
  }) {
    return StatusEntity(
      statusId: statusId ?? this.statusId,
      statusNm: statusNm ?? this.statusNm,
      colorCd: colorCd ?? this.colorCd,
    );
  }
}
