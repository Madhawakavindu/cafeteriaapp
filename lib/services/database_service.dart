import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'cafeteria.db');

    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Feedback table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS feedback(
        id TEXT PRIMARY KEY,
        canteenId TEXT,
        userId TEXT,
        comment TEXT,
        rating INTEGER,
        timestamp TEXT
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders(
        id TEXT PRIMARY KEY,
        canteenId TEXT,
        userId TEXT,
        mealType TEXT,
        mainFood TEXT,
        vegetables TEXT,
        status TEXT,
        createdAt TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
