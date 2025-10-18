/// ============================================================
///  Memo・Status結合モデル
/// ============================================================
///
/// Flutter ⇄ DB ⇄ HomeWidget 共有用モデル
/// - Map/JSON相互変換対応
/// - null安全・日時変換対応
///
class MemoWithStatus {
  final int? id;             // メモID（主キー）
  final String? content;     // メモ内容
  final int? statusId;       // ステータスID（外部キー）
  final DateTime? createdAt; // 作成日時
  final DateTime? updatedAt; // 更新日時（null可）
  final String? statusNm;    // ステータス名（LEFT JOIN想定でnull可）
  final String? colorCd;     // カラーコード（LEFT JOIN想定でnull可）

  const MemoWithStatus({
    this.id,
    this.content,
    this.statusId,
    this.createdAt,
    this.updatedAt,
    this.statusNm,
    this.colorCd,
  });

  ///
  /// Map ⇔ クラス変換
  ///

  /// クラス → Map（HomeWidget保存やDB登録用）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'statusId': statusId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'statusNm': statusNm,
      'colorCd': colorCd,
    };
  }

  /// Map → モデル（DBやJSON読み込み時）
  factory MemoWithStatus.fromMap(Map<String, dynamic> map) {
    return MemoWithStatus(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      content: map['content']?.toString(),
      statusId: map['statusId'] is int
          ? map['statusId']
          : int.tryParse(map['statusId']?.toString() ?? ''),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      statusNm: map['statusNm']?.toString(),
      colorCd: map['colorCd']?.toString(),
    );
  }
  //
  // // ============================================================
  // // 🔹 JSON変換
  // // ============================================================
  //
  // /// モデル → JSON文字列
  // String toJson() => jsonEncode(toMap());
  //
  // /// JSON文字列 → モデル
  // factory MemoWithStatus.fromJson(String source) =>
  //     MemoWithStatus.fromMap(jsonDecode(source));
  //
  // ============================================================
  // 🔹 ヘルパー（日時パース）※ファイル分けてもいいかも
  // ============================================================
  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
