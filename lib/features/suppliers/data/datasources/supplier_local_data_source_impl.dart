import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/sqlite/sqlite_helper.dart';
import '../../../../core/database/sqlite/sqlite_constants.dart';
import '../models/supplier_model.dart';
import 'supplier_local_data_source.dart';

class SupplierLocalDataSourceImpl implements SupplierLocalDataSource {
  final SqliteHelper dbHelper;
  final _supplierStreamController = StreamController<List<SupplierModel>>.broadcast();

  SupplierLocalDataSourceImpl(this.dbHelper) {
    // تحميل البيانات الأولية فور التشغيل إذا لم نكن على الويب
    if (!kIsWeb) {
      _refreshStream();
    }
  }

  @override
  Stream<List<SupplierModel>> watchAllSuppliers() => _supplierStreamController.stream;

  Future<void> _refreshStream() async {
    if (kIsWeb) return;
    final suppliers = await getAllSuppliers();
    _supplierStreamController.add(suppliers);
  }

  @override
  Future<void> cacheSupplier(SupplierModel supplier) async {
    if (kIsWeb) return;
    final db = await dbHelper.database;
    await db.insert(
      SqliteConstants.tableSuppliers,
      supplier.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _refreshStream(); // تحديث الـ Stream تلقائياً
  }

  @override
  Future<List<SupplierModel>> getAllSuppliers() async {
    if (kIsWeb) return [];
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(SqliteConstants.tableSuppliers);
    return maps.map((map) => SupplierModel.fromJson(map)).toList();
  }

  @override
  Future<SupplierModel?> getSupplierById(String id) async {
    if (kIsWeb) return null;
    final db = await dbHelper.database;
    final maps = await db.query(
      SqliteConstants.tableSuppliers,
      where: '${SqliteConstants.colSupplierId} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return SupplierModel.fromJson(maps.first);
    return null;
  }

  @override
  Future<void> deleteSupplier(String id) async {
    if (kIsWeb) return;
    final db = await dbHelper.database;
    await db.delete(
      SqliteConstants.tableSuppliers,
      where: '${SqliteConstants.colSupplierId} = ?',
      whereArgs: [id],
    );
    _refreshStream();
  }
}
