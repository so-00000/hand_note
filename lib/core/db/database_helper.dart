import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

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
      version: 12, // ✅ 最新バージョン
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  //
  // 🧩 テーブル作成
  //
  Future _createDB(Database db, int version) async {
    // 🎨 ステータステーブル
    await db.execute('''
      CREATE TABLE status (
        status_id INTEGER PRIMARY KEY AUTOINCREMENT,
        status_nm TEXT NOT NULL,
        color_cd TEXT NOT NULL
      )
    ''');

    // 🗒️ メモテーブル
    await db.execute('''
      CREATE TABLE memos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        status_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (status_id) REFERENCES status(status_id)
      )
    ''');

    // 🧩 初期データ登録（固定ステータス）
    final initialStatuses = [
      {'status_nm': '完了', 'color_cd': '01'},
      {'status_nm': '未完了', 'color_cd': '02'},
    ];

    for (final status in initialStatuses) {
      await db.insert('status', status);
    }
  }

  //
  // 🔁 バージョンアップ対応
  //
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 12) {
      await db.execute('DROP TABLE IF EXISTS memos');
      await db.execute('DROP TABLE IF EXISTS status');
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
}
