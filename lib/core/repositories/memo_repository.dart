import '../db/database_helper.dart';
import '../entities/memo_entity.dart';
import '../dto/memo_with_status.dart';

/// ===============================
/// 🗄️ Memo Repository
/// ===============================
///
/// - memosテーブルを中心とした集約の代表
/// - CRUD操作は MemoEntity を使う
/// - JOIN結果は MemoWithStatus（DTO）として返す
/// - 複数のDAOを統合する役割を担う
///
class MemoRepository {
  final dbHelper = DatabaseHelper.instance;

  // ===============================
  // 📋 JOIN済み一覧取得（Memo + Status）
  // ===============================
  Future<List<MemoWithStatus>> fetchAllWithStatus() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        m.memo_id,
        m.content,
        m.status_id,
        m.created_at,
        m.updated_at,
        s.status_nm,
        s.color_cd
      FROM memos m
      LEFT JOIN status s ON m.status_id = s.status_id
      ORDER BY m.created_at DESC;
    ''');

    return result.map((r) => MemoWithStatus.fromJoinedMap(r)).toList();
  }

  // ===============================
  // 📄 1件取得（JOIN付き）
  // ===============================
  Future<MemoWithStatus?> fetchById(int memoId) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        m.memo_id,
        m.content,
        m.status_id,
        m.created_at,
        m.updated_at,
        s.status_nm,
        s.color_cd
      FROM memos m
      LEFT JOIN status s ON m.status_id = s.status_id
      WHERE m.memo_id = ?;
    ''', [memoId]);

    if (result.isEmpty) return null;
    return MemoWithStatus.fromJoinedMap(result.first);
  }

  // ===============================
  // 💾 登録（INSERT）
  // ===============================
  Future<int> insert(MemoEntity memo) async {
    final db = await dbHelper.database;
    return await db.insert('memos', memo.toMap());
  }

  // ===============================
  // ✏️ 更新（UPDATE）
  // ===============================
  Future<int> update(MemoEntity memo) async {
    final db = await dbHelper.database;

    if (memo.memoId == null) {
      throw ArgumentError('update: memoId が null です。');
    }

    return await db.update(
      'memos',
      memo.toMap(),
      where: 'memo_id = ?',
      whereArgs: [memo.memoId],
    );
  }

  // ===============================
  // ❌ 削除（DELETE）
  // ===============================
  Future<int> delete(int memoId) async {
    final db = await dbHelper.database;

    return await db.delete(
      'memos',
      where: 'memo_id = ?',
      whereArgs: [memoId],
    );
  }

  // ===============================
  // 🧹 全削除（リセット用）
  // ===============================
  Future<int> deleteAll() async {
    final db = await dbHelper.database;
    return await db.delete('memos');
  }
}
