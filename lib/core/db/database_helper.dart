import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  final dbVer = 26; // ✅ 最新バージョン

  //
  // 🔌 DB接続
  //
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('memos.db');
    return _database!;
  }

  //
  // 🧱 初期化
  //
  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);
    return await openDatabase(
      path,
      version: dbVer,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );

    logAllTables();
  }

  //
  // 🧩 テーブル作成
  //
  Future _createDB(Database db, int version) async {

    // ステータステーブル
    await db.execute('''
      CREATE TABLE status (
        status_id   INTEGER PRIMARY KEY AUTOINCREMENT,
        sort_no     INTEGER NOT NULL,
        status_nm   TEXT    NOT NULL,
        status_color TEXT   NOT NULL
      );
    ''');

    // カテゴリテーブル
    await db.execute('''
      CREATE TABLE category (
        category_id   INTEGER PRIMARY KEY AUTOINCREMENT,
        sort_no     INTEGER NOT NULL,
        category_nm   TEXT    NOT NULL,
      );
    ''');

    // メモテーブル
    await db.execute('''
      CREATE TABLE memos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        category_id INTEGER NOT NULL DEFAULT 0,
        status_id INTEGER NOT NULL DEFAULT 2,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (status_id) REFERENCES status(status_id)
      )
    ''');

    // 🧩 初期データ登録（固定ステータス）
    final initialStatuses = [
      {'sort_no': 1, 'status_nm': '完了', 'status_color': '1'},
      {'sort_no': 2, 'status_nm': '未完了', 'status_color': '2'},
    ];

    for (final status in initialStatuses) {
      await db.insert('status', status);
    }
  }

  //
  // 🔁 バージョンアップ対応
  //
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < dbVer) {
      await db.execute('DROP TABLE IF EXISTS memos');
      await db.execute('DROP TABLE IF EXISTS status');
      await db.execute('DROP TABLE IF EXISTS category');
      await _createDB(db, newVersion);
    }
  }

  //
  // 🚪 クローズ処理
  //
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  //
  // 🧾 全テーブル内容を出力（デバッグ用）
  //
  Future<void> logAllTables() async {
    final db = await instance.database;

    // すべてのテーブル名を取得（内部テーブル除外）
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );

    debugPrint('==============================');
    debugPrint('📊 [DatabaseHelper] 全テーブル内容出力開始');
    debugPrint('==============================');

    for (final table in tables) {
      final tableName = table['name'] as String;
      final rows = await db.query(tableName);

      debugPrint('--- 📋 Table: $tableName (${rows.length}件) ---');
      if (rows.isEmpty) {
        debugPrint('  （データなし）');
      } else {
        for (final row in rows) {
          debugPrint('  $row');
        }
      }
      debugPrint('-----------------------------------');
    }

    debugPrint('==============================');
    debugPrint('✅ [DatabaseHelper] 出力完了');
    debugPrint('==============================');
  }
}