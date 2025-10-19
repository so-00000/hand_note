import '../../../../core/db/database_helper.dart';
import '../model/memo_model.dart';

/// ===============================
/// 💾 MemoDao（sqflite用）
/// ===============================
///
/// memosテーブルへのCRUDを担当。
///
class MemoDao {
  // テーブル名
  static const tableName = 'memos';

  /// 🟢 INSERT（追加）
  Future<int> insert(Memo memo) async {
    final db = await DatabaseHelper.instance.database;
    final data = memo.toMap()
      ..removeWhere((k, v) => v == null); // null除外

    return await db.insert(tableName, data);
  }

  /// 🔵 READ（全件取得）
  Future<List<Memo>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      tableName,
      orderBy: 'created_at DESC',
    );
    return result.map((e) => Memo.fromMap(e)).toList();
  }

  /// 🔵 READ（ID指定で1件取得）
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

  /// 🟠 UPDATE（更新）
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

  /// 🔴 DELETE（削除）
  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
