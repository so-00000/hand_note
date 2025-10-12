import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/memo.dart';

class MemoDao {
  Future<int> insert(Memo memo) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('memos', memo.toMap());
  }

  Future<List<Memo>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT 
        m.id,
        m.content,
        m.status_id,
        s.name AS status_name,
        s.color_code AS status_color,   -- ✅ color_codeも取得！
        m.created_at
      FROM memos m
      LEFT JOIN status s ON m.status_id = s.id   -- ✅ テーブル名修正！
      ORDER BY m.created_at DESC
    ''');
    return result.map((e) => Memo.fromJoinedMap(e)).toList();
  }

  Future<int> update(Memo memo) async {
    final db = await DatabaseHelper.instance.database;
    final data = memo.toMap();
    data.removeWhere((k, v) => v == null); // ✅ nullは除外OK
    return await db.update(
      'memos',
      data,
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }


  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.delete('memos', where: 'id = ?', whereArgs: [id]);
  }
}
