/// ===============================
/// 🟢 ステータスマスタモデル（sqfliteローカルDB対応）
/// ===============================
///
/// 対応テーブル: `status`
/// カラム構成:
///   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
///   - name (TEXT NOT NULL)
///   - color_code (TEXT NOT NULL)
///
class MemoStatus {
  /// 主キー
  final int? id;

  /// ステータス名（例：「完了」「未完了」「進行中」など）
  final String name;

  /// カラーコード（例：「01」「02」「03」など）
  /// UI側で `getStatusColor(code)` により実際のColorへ変換
  final String colorCode;

  const MemoStatus({
    this.id,
    required this.name,
    required this.colorCode,
  });

  // ===============================
  // 🔁 Map → Model 変換
  // ===============================
  factory MemoStatus.fromMap(Map<String, dynamic> map) {
    return MemoStatus(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      name: map['name']?.toString() ?? '',
      colorCode: map['color_code']?.toString() ?? '',
    );
  }

  // ===============================
  // 💾 Model → Map 変換
  // ===============================
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color_code': colorCode,
    };
  }

  // ===============================
  // 🧩 copyWith
  // ===============================
  //
  // 値を部分的に変更して新しいインスタンスを生成。
  //
  MemoStatus copyWith({
    int? id,
    String? name,
    String? colorCode,
  }) {
    return MemoStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
    );
  }
}
