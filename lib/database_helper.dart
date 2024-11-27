import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "db_barang.db";
  static const _databaseVersion = 2; // Naikkan versi ke 2

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Tambahkan onUpgrade
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image TEXT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        merk TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Di sini kita bisa menambahkan kolom baru jika perlu
      await db.execute('ALTER TABLE barang ADD COLUMN image TEXT'); // Menambahkan kolom image
      await db.execute('ALTER TABLE barang ADD COLUMN merk TEXT'); // Menambahkan kolom merk
    }
  }

  // CREATE
  Future<int> insertBarang(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('barang', row);
  }

  // READ
  Future<List<Map<String, dynamic>>> queryAllBarang() async {
    Database db = await instance.database;
    return await db.query('barang');
  }

  // UPDATE
  Future<int> updateBarang(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('barang', row, where: 'id = ?', whereArgs: [id]);
  }

  // DELETE
  Future<int> deleteBarang(int id) async {
    Database db = await instance.database;
    return await db.delete('barang', where: 'id = ?', whereArgs: [id]);
  }
}