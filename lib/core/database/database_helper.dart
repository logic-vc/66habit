import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/habit.dart';
import '../../models/check_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'habit_66.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create habits table
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        goal TEXT NOT NULL,
        start_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_archived INTEGER DEFAULT 0
      )
    ''');

    // Create check_records table
    await db.execute('''
      CREATE TABLE check_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        check_date TEXT NOT NULL,
        checked_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE(habit_id, check_date)
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_habit_id ON check_records (habit_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_check_date ON check_records (check_date)
    ''');
  }

  // ==================== Habit CRUD ====================

  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: includeArchived ? null : 'is_archived = ?',
      whereArgs: includeArchived ? null : [0],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  Future<Habit?> getHabitById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    // This will also delete associated check_records due to CASCADE
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> archiveHabit(int id) async {
    final db = await database;
    return await db.update(
      'habits',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CheckRecord CRUD ====================

  Future<int> insertCheckRecord(CheckRecord record) async {
    final db = await database;
    try {
      return await db.insert(
        'check_records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // If duplicate (same habit_id and check_date), replace
      rethrow;
    }
  }

  Future<List<CheckRecord>> getCheckRecordsByHabit(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'check_records',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'check_date DESC',
    );

    return List.generate(maps.length, (i) => CheckRecord.fromMap(maps[i]));
  }

  Future<CheckRecord?> getCheckRecordByDate(int habitId, DateTime date) async {
    final db = await database;
    final normalizedDate = CheckRecord.normalizeDate(date);
    final dateStr = CheckRecord._formatDate(normalizedDate);

    final List<Map<String, dynamic>> maps = await db.query(
      'check_records',
      where: 'habit_id = ? AND check_date = ?',
      whereArgs: [habitId, dateStr],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CheckRecord.fromMap(maps.first);
  }

  Future<bool> isCheckedToday(int habitId) async {
    final today = CheckRecord.normalizeDate(DateTime.now());
    final record = await getCheckRecordByDate(habitId, today);
    return record != null;
  }

  Future<int> deleteCheckRecord(int id) async {
    final db = await database;
    return await db.delete(
      'check_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCheckRecordByDate(int habitId, DateTime date) async {
    final db = await database;
    final normalizedDate = CheckRecord.normalizeDate(date);
    final dateStr = CheckRecord._formatDate(normalizedDate);

    return await db.delete(
      'check_records',
      where: 'habit_id = ? AND check_date = ?',
      whereArgs: [habitId, dateStr],
    );
  }

  // ==================== Statistics ====================

  Future<int> getTotalCheckCount(int habitId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM check_records WHERE habit_id = ?',
      [habitId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getCheckCountByDate(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'check_records',
      columns: ['check_date'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );

    final Map<String, int> checkMap = {};
    for (final map in maps) {
      checkMap[map['check_date'] as String] = 1;
    }
    return checkMap;
  }

  // ==================== Utility ====================

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'habit_66.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

// Extension to make _formatDate accessible
extension CheckRecordExtension on CheckRecord {
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
