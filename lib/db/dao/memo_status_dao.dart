import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/memo_status.dart';

class MemoStatusDao {
  Future<List<MemoStatus>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('memo_statuses', orderBy: 'id ASC');
    return result.map((e) => MemoStatus.fromMap(e)).toList();
  }

  Future<int> insert(MemoStatus status) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('memo_statuses', status.toMap());
  }

  Future<int> update(MemoStatus status) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'memo_statuses',
      status.toMap(),
      where: 'id = ?',
      whereArgs: [status.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.delete('memo_statuses', where: 'id = ?', whereArgs: [id]);
  }
}
