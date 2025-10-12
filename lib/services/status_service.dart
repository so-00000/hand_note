import '../db/database_helper.dart';

class StatusService {
  /// 🔧 カスタムステータスを追加（ユーザー操作用）
  Future<void> addCustomStatus(String name, String colorCode) async {
    final db = await DatabaseHelper.instance.database;

    // 同じ color_code が既に登録されていないかチェック
    final existing = await db.query(
      'status',
      where: 'color_code = ?',
      whereArgs: [colorCode],
    );

    if (existing.isNotEmpty) {
      throw Exception('同じカラーコードはすでに存在します');
    }

    await db.insert('status', {
      'name': name,
      'color_code': colorCode,
    });
  }

  /// 🔍 ステータス一覧取得
  Future<List<Map<String, dynamic>>> fetchAllStatuses() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('status', orderBy: 'id ASC');
  }

  /// ❌ ステータス削除（固定は削除不可）
  Future<void> deleteStatus(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('status', where: 'id = ?', whereArgs: [id]);
  }
}
