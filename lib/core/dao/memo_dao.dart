import '../../../../core/db/database_helper.dart';
import '../3_model/model/memo_model.dart';

/// ===============================
/// MemoDao（sqflite用）
/// ===============================

class MemoDao {

  /// テーブル名のセット
  static const tableName = 'memos';



  ///
  /// INSERT
  ///

  // 1件
  Future<int> insert(Memo memo) async {
    final db = await DatabaseHelper.instance.database;
    final data = memo.toMap()
      ..removeWhere((k, v) => v == null); // null除外

    return await db.insert(tableName, data);
  }

  ///
  /// READ
  ///

  // 全件
  Future<List<Memo>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      tableName,
      orderBy: 'created_at DESC',
    );
    return result.map((e) => Memo.fromMap(e)).toList();
  }

  // 1件：メモID指定
  Future<Memo?> fetchById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Memo.fromMap(result.first);
  }

  // 1件：ステータスID指定
  Future<List<Memo>> fetchByStatus(int statusId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      tableName,
      where: 'status_id = ?',
      whereArgs: [statusId],
    );

    return result.map((e) => Memo.fromMap(e)).toList();
  }

  ///
  /// UPDATE
  ///

  // 1件：メモID指定
  Future<int> update(Memo memo) async {
    final db = await DatabaseHelper.instance.database;
    final data = memo.toMap()
      ..removeWhere((k, v) => v == null);

    return await db.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [memo.memoId],
    );
  }

  // 複数件：ステータスID指定
  Future<int> updateStatusByStatusId({
    required int fromStatusId,
    required int toStatusId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      tableName,
      {'status_id': toStatusId},
      where: 'status_id = ?',
      whereArgs: [fromStatusId],
    );
  }


  ///
  /// DELETE
  ///

  // 1件：メモID指定
  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
