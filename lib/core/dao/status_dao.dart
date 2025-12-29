import '../../../../core/db/database_helper.dart';
import '../3_model/model/status_model.dart';

/// ===============================
/// StatusDao（sqflite用）
/// ===============================

class StatusDao {

  /// テーブル名のセット
  static const tableName = 'status';



  ///
  /// INSERT
  ///

  // 1件
  Future<int> insert(String name, String colorCode) async {
    final db = await DatabaseHelper.instance.database;

    // sort_no を決定
    final nextSortNo = await getMaxSortNo() + 1;

    // データ生成
    final newStatus = Status(
      sortNo: nextSortNo,
      statusNm: name,
      statusColor: colorCode,
    );

    // 挿入
    final data = newStatus.toInsertMap()..removeWhere((k, v) => v == null);
    return await db.insert('status', data);
  }

  // 最大sort_no取得
  Future<int> getMaxSortNo() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COALESCE(MAX(sort_no), 0) AS next_no FROM status');
    return (result.first['next_no'] as int?) ?? 1;
  }



  ///
  /// READ
  ///

  // 全件（status_id昇順）
  Future<List<Status>> fetchAll() async {

    final db = await DatabaseHelper.instance.database;
    final result = await db.query('status', orderBy: 'sort_no ASC');

    return result.map((e) => Status.fromMap(e)).toList();
  }

  // 1件：ステータスID指定
  Future<Status> fetchById(int status_id) async {

    // DB取得
    final db = await DatabaseHelper.instance.database;

    // 取得処理の呼び出し
    final result = await db.query(
      tableName,
      where: 'status_id = ?',
      whereArgs: [status_id],
      limit: 1,
    );

    return Status.fromMap(result.first);
  }



  ///
  /// UPDATE
  ///

  // 1件：ステータスID指定
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

  Future<void> updateStatusOrder(List<Status> statuses) async {
    final db = await DatabaseHelper.instance.database;

    // 1トランザクションで実行
    await db.transaction((txn) async {
      for (final s in statuses) {
        final data = s.toMap()..removeWhere((k, v) => v == null);
        await txn.update(
          'status',
          data,
          where: 'status_id = ?',
          whereArgs: [s.statusId],
        );
      }
    });
  }



  ///
  /// DELETE
  ///

  Future<int> delete(int status_id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      tableName,
      where: 'status_id = ?',
      whereArgs: [status_id],
    );
  }
}
