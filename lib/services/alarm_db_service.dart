import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AlarmDbService {
  static final AlarmDbService instance = AlarmDbService._init();
  static Database? _database;

  AlarmDbService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alarms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alarms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT NOT NULL,
            hour INTEGER NOT NULL,
            minute INTEGER NOT NULL,
            isEnabled INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertAlarm(String label, int hour, int minute) async {
    final db = await instance.database;
    return await db.insert('alarms', {
      'label': label,
      'hour': hour,
      'minute': minute,
      'isEnabled': 1,
    });
  }

  Future<List<Map<String, dynamic>>> getAlarms() async {
    final db = await instance.database;
    return await db.query('alarms', orderBy: 'id DESC');
  }

  Future<int> updateAlarmStatus(int id, bool isEnabled) async {
    final db = await instance.database;
    return await db.update(
      'alarms',
      {'isEnabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAlarm(int id) async {
    final db = await instance.database;
    return await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }
}