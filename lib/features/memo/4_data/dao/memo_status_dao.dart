import 'package:sqflite/sqflite.dart';
import '../../../../core/db/database_helper.dart';
import '../../3_domain/entities/memo_status.dart';

/// ===============================
/// 🎨 MemoStatusDao（sqflite用）
/// ===============================
///
/// `status` テーブルのCRUDを担当。
/// 固定ステータスとカスタムステータスを一元管理。
///
class MemoStatusDao {

  // テーブル名のセット
  static const tableName = 'status';

  /// 🔍 全件取得（id昇順）
  Future<List<MemoStatus>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('status', orderBy: 'id ASC');
    return result.map((e) => MemoStatus.fromMap(e)).toList();
  }

  /// 🟢 追加（INSERT）
  ///
  /// ※ color_code の一意性チェックは上位層（Service側）で行う想定。
  ///
  Future<int> insert(MemoStatus status) async {
    final db = await DatabaseHelper.instance.database;
    final data = status.toMap()..removeWhere((k, v) => v == null);
    return await db.insert('status', data);
  }

  /// ✏️ 更新（UPDATE）
  Future<int> update(MemoStatus status) async {
    final db = await DatabaseHelper.instance.database;
    final data = status.toMap()..removeWhere((k, v) => v == null);
    return await db.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [status.id],
    );
  }

  /// ❌ 削除（DELETE）
  ///
  /// ※ 固定ステータスはService側で削除制御する想定。
  ///
  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 1件取得（ステータスIDで検索）
  Future<MemoStatus?> fetchById(int id) async {

    // DB取得
    final db = await DatabaseHelper.instance.database;

    // 取得処理の呼び出し
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return MemoStatus.fromMap(result.first);
  }

}
