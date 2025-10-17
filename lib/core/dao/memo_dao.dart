import '../db/database_helper.dart';
import '../entities/memo_entity.dart';

/// ===============================
/// 🗒️ Memo DAO
/// ===============================
///
/// 対応テーブル：`memos`
/// - CRUD操作を1:1で管理（JOINは行わない）
///
class MemoDao {
  final dbHelper = DatabaseHelper.instance;

  /// テーブル名定義（定数として管理）
  static const String tableName = 'memos';

  /// カラム名定義（保守性向上のため）
  static const String colId = 'memo_id';
  static const String colContent = 'content';
  static const String colStatusId = 'status_id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // ===============================
  // 🔍 全件取得（最新順）
  // ===============================
  Future<List<MemoEntity>> getAllMemos() async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      orderBy: '$colCreatedAt DESC',
    );
    return result.map((map) => MemoEntity.fromMap(map)).toList();
  }

  // ===============================
  // 🔍 1件取得（ID指定）
  // ===============================
  Future<MemoEntity?> getMemoById(int memoId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: '$colId = ?',
      whereArgs: [memoId],
    );
    if (result.isEmpty) return null;
    return MemoEntity.fromMap(result.first);
  }

  // ===============================
  // 💾 登録（INSERT）
  // ===============================
  Future<int> insertMemo(MemoEntity memo) async {
    final db = await dbHelper.database;
    return await db.insert(tableName, memo.toMap());
  }

  // ===============================
  // ✏️ 更新（UPDATE）
  // ===============================
  Future<int> updateMemo(MemoEntity memo) async {
    final db = await dbHelper.database;
    if (memo.memoId == null) {
      throw ArgumentError('updateMemo: memoId が null です。');
    }
    return await db.update(
      tableName,
      memo.toMap(),
      where: '$colId = ?',
      whereArgs: [memo.memoId],
    );
  }

  // ===============================
  // ❌ 削除（DELETE）
  // ===============================
  Future<int> deleteMemo(int memoId) async {
    final db = await dbHelper.database;
    return await db.delete(
      tableName,
      where: '$colId = ?',
      whereArgs: [memoId],
    );
  }

  // ===============================
  // 🧹 全削除（リセット用）
  // ===============================
  Future<int> deleteAll() async {
    final db = await dbHelper.database;
    return await db.delete(tableName);
  }
}
