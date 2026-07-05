import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'sqlite_constants.dart';

class SqliteHelper {
  static final SqliteHelper _instance = SqliteHelper._internal();
  factory SqliteHelper() => _instance;
  SqliteHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web platform');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory_guard.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${SqliteConstants.tableProducts} (
        ${SqliteConstants.colProductId} TEXT PRIMARY KEY,
        ${SqliteConstants.colProductName} TEXT,
        ${SqliteConstants.colProductSku} TEXT,
        ${SqliteConstants.colProductCategory} TEXT,
        ${SqliteConstants.colProductQuantity} INTEGER,
        ${SqliteConstants.colProductUnitPrice} REAL,
        ${SqliteConstants.colProductSupplierId} TEXT,
        ${SqliteConstants.colProductLowStockThreshold} INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE ${SqliteConstants.tableSyncQueue} (
        ${SqliteConstants.colSyncId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SqliteConstants.colSyncAction} TEXT NOT NULL,
        ${SqliteConstants.colSyncPayload} TEXT NOT NULL,
        ${SqliteConstants.colSyncTimestamp} TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE ${SqliteConstants.tableSuppliers} (
        ${SqliteConstants.colSupplierId} TEXT PRIMARY KEY,
        ${SqliteConstants.colSupplierName} TEXT,
        ${SqliteConstants.colSupplierContactPerson} TEXT,
        ${SqliteConstants.colSupplierEmail} TEXT,
        ${SqliteConstants.colSupplierPhone} TEXT,
        ${SqliteConstants.colSupplierAddress} TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${SqliteConstants.tableAuditLogs} (
        ${SqliteConstants.colAuditId} TEXT PRIMARY KEY,
        ${SqliteConstants.colAuditProductId} TEXT,
        ${SqliteConstants.colAuditActionType} TEXT,
        ${SqliteConstants.colAuditQuantityChanged} INTEGER,
        ${SqliteConstants.colAuditTimestamp} INTEGER,
        ${SqliteConstants.colAuditUserId} TEXT,
        ${SqliteConstants.colAuditNotes} TEXT
      )
    ''');
  }
}
