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
    final result = await db.query('status', orderBy: 'sort_no ASC');

    return result.map((e) => Status.fromMap(e)).toList();
  }

  /// 🟢 追加（INSERT）

  // 「最大+1のsort_no」取得
  Future<int> getNextSortNo() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COALESCE(MAX(sort_no), 0) + 1 AS next_no FROM status');
    return (result.first['next_no'] as int?) ?? 1;
  }

  Future<int> insert(String name, String colorCode) async {
    final db = await DatabaseHelper.instance.database;

    // sort_no を決定
    final nextSortNo = await getNextSortNo();

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
}
