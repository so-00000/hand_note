import 'dart:math';

import 'package:sqflite/sqflite.dart';
import '../../../../core/db/database_helper.dart';
import '../../3_domain/entities/memo.dart';

/// ===============================
/// 💾 MemoDao（sqflite用）
/// ===============================
///
/// memosテーブルへのCRUDを担当。
/// JOINでstatusテーブルを参照してメモ一覧を取得。
///
class MemoDao {

  // テーブル名のセット
  static const tableName = 'memos';

  /// 🟢 追加（INSERT）
  Future<int> insert(Memo memo) async {
    final db = await DatabaseHelper.instance.database;
    final data = memo.toMap()
      ..removeWhere((k, v) => v == null); // nullを除外して安全化
    return await db.insert(tableName, data);
  }

  /// 全件取得（READ）
  ///
  /// JOIN : memoテーブル + statusテーブル
  ///
  /// ➡ステータス名・カラーコードも取得
  ///
  Future<List<Memo>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT 
        m.id,
        m.content,
        m.status_id,
        s.name AS status_name,
        s.color_code AS status_color,
        m.created_at,
        m.updated_at
      FROM memos AS m
      LEFT JOIN status AS s ON m.status_id = s.id
      ORDER BY m.created_at DESC
    ''');

    return result.map((e) => Memo.fromJoinedMap(e)).toList();
  }

  /// 特定IDのメモ取得（READ）
  Future<Memo?> fetchById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT 
        m.id,
        m.content,
        m.status_id,
        s.name AS status_name,
        s.color_code AS status_color,
        m.created_at,
        m.updated_at
      FROM memos AS m
      LEFT JOIN status AS s ON m.status_id = s.id
      WHERE m.id = ?
      LIMIT 1
    ''', [id]);

    if (result.isEmpty) return null;
    return Memo.fromJoinedMap(result.first);
  }

  /// 更新（UPDATE）
  Future<int> update(Memo memo) async {

    // DB取得
    final db = await DatabaseHelper.instance.database;

    // Modelから型変換
    // 値がnullのキーを除外
    final data = memo.toMap()
      ..removeWhere((k, v) => v == null);

    // データ更新
    return await db.update(
      tableName,            // table
      data,                 // value(SET句)
      where: 'id = ?',      // where
      whereArgs: [memo.id],
    );
  }

  /// 削除（DELETE）
  Future<int> delete(int id) async {

    // DB取得
    final db = await DatabaseHelper.instance.database;

    // データ削除
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}
