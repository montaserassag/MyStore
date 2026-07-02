import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  DatabaseService._();
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shopx.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart_items (
            id       INTEGER PRIMARY KEY,
            title    TEXT    NOT NULL,
            price    REAL    NOT NULL,
            image    TEXT    NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_cart_id ON cart_items(id)',
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllCartItems() async {
    final database = await db;
    try {
      return await database.query('cart_items');
    } on DatabaseException {
      return [];
    }
  }

  Future<void> insertOrUpdateCartItem(Map<String, dynamic> item) async {
    final database = await db;
    try {
      await database.insert(
        'cart_items',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (_) {}
  }

  Future<void> updateCartQuantity(int id, int quantity) async {
    final database = await db;
    try {
      await database.update(
        'cart_items',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (_) {}
  }

  Future<void> deleteCartItem(int id) async {
    final database = await db;
    try {
      await database.delete(
        'cart_items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (_) {}
  }

  Future<void> clearCart() async {
    final database = await db;
    try {
      await database.delete('cart_items');
    } on DatabaseException catch (_) {}
  }
}
