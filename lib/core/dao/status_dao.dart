import '../db/database_helper.dart';
import '../entities/status_entity.dart';

/// ===============================
/// 🎨 Status DAO
/// ===============================
///
/// 対応テーブル：`status`
/// - 固定マスタを基本とするが、ユーザー編集も可能
/// - メモ以外の画面（設定画面など）でも利用
///
class StatusDao {
  final dbHelper = DatabaseHelper.instance;

  /// テーブル名定義（定数として管理）
  static const String tableName = 'status';

  /// カラム名定義（保守性向上のため）
  static const String colId = 'status_id';
  static const String colName = 'status_nm';
  static const String colColor = 'color_cd';

  // ===============================
  // 🔍 全件取得（登録順）
  // ===============================
  Future<List<StatusEntity>> getAllStatuses() async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      orderBy: '$colId ASC',
    );
    return result.map((map) => StatusEntity.fromMap(map)).toList();
  }

  // ===============================
  // 🔍 1件取得（ID指定）
  // ===============================
  Future<StatusEntity?> getStatusById(int statusId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: '$colId = ?',
      whereArgs: [statusId],
    );
    if (result.isEmpty) return null;
    return StatusEntity.fromMap(result.first);
  }


  // ===============================
  // 💾 登録（INSERT）
  // ===============================
  Future<int> insertStatus(StatusEntity status) async {
    final db = await dbHelper.database;
    return await db.insert(tableName, status.toMap());
  }

  // ===============================
  // ✏️ 更新（UPDATE）
  // ===============================
  Future<int> updateStatus(StatusEntity status) async {
    final db = await dbHelper.database;
    if (status.statusId == null) {
      throw ArgumentError('updateStatus: statusId が null です。');
    }
    return await db.update(
      tableName,
      status.toMap(),
      where: '$colId = ?',
      whereArgs: [status.statusId],
    );
  }

  // ===============================
  // ❌ 削除（DELETE）
  // ===============================
  Future<int> deleteStatus(int statusId) async {
    final db = await dbHelper.database;
    return await db.delete(
      tableName,
      where: '$colId = ?',
      whereArgs: [statusId],
    );
  }
}
