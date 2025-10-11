import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _db;

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dinning.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE orders(
          id TEXT PRIMARY KEY,
          items TEXT,
          total REAL,
          date INTEGER
        )
      ''');
    });
  }

  static Future<void> insertOrder(String id, String itemsJson, double total) async {
    await _db!.insert('orders', {
      'id': id,
      'items': itemsJson,
      'total': total,
      'date': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    return await _db!.query('orders', orderBy: 'date DESC');
  }
}
