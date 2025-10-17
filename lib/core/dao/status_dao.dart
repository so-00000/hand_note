import 'package:sqflite/sqflite.dart';
import '../../../../core/db/database_helper.dart';
import '../model/status_model.dart';

/// ===============================
/// 🎨 MemoStatusDao（sqflite用）
/// ===============================
///
/// `status` テーブルのCRUDを担当。
/// 固定ステータスとカスタムステータスを一元管理。
///
class StatusDao {

  // テーブル名のセット
  static const tableName = 'status';

  /// 🔍 全件取得（status_id昇順）
  Future<List<Status>> fetchAll() async {

    final db = await DatabaseHelper.instance.database;
    final result = await db.query('status', orderBy: 'status_id ASC');

    return result.map((e) => Status.fromMap(e)).toList();
  }

  /// 🟢 追加（INSERT）

  Future<int> insert(Status status) async {
    final db = await DatabaseHelper.instance.database;
    final data = status.toMap()..removeWhere((k, v) => v == null);
    return await db.insert('status', data);
  }

  /// ✏️ 更新（UPDATE）
  Future<int> update(Status status) async {
    final db = await DatabaseHelper.instance.database;
    final data = status.toMap()..removeWhere((k, v) => v == null);
    return await db.update(
      tableName,
      data,
      where: 'status_id = ?',
      whereArgs: [status.statusId],
    );
  }

  /// ❌ 削除（DELETE）
  ///
  /// ※ 固定ステータスはService側で削除制御する想定。
  ///
  Future<int> delete(int status_id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      tableName,
      where: 'status_id = ?',
      whereArgs: [status_id],
    );
  }

  /// 1件取得（ステータスIDで検索）
  Future<Status?> fetchById(int status_id) async {

    // DB取得
    final db = await DatabaseHelper.instance.database;

    // 取得処理の呼び出し
    final result = await db.query(
      tableName,
      where: 'status_id = ?',
      whereArgs: [status_id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Status.fromMap(result.first);
  }

}
