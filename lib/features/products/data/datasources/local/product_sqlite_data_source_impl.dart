import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/sqlite/sqlite_helper.dart';
import '../../../../../core/database/sqlite/sqlite_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../models/product_model.dart';
import 'product_local_data_source.dart';

class ProductSqliteDataSourceImpl implements ProductLocalDataSource {
  final SqliteHelper dbHelper;
  
  // StreamController لبث التحديثات لجميع المشتركين
  final _productStreamController = StreamController<List<ProductModel>>.broadcast();

  ProductSqliteDataSourceImpl({required this.dbHelper});

  // دالة مساعدة لتحديث الـ Stream
  Future<void> _updateStream() async {
    final products = await getAllProducts();
    _productStreamController.add(products);
  }

  @override
  Stream<List<ProductModel>> watchAllProducts() {
    _updateStream(); // جلب البيانات لأول مرة
    return _productStreamController.stream;
  }

  @override
  Future<List<ProductModel>> getAllProducts({
    int limit = 20,
    int offset = 0,
    String? query,
  }) async {
    if (kIsWeb) return [];
    final db = await dbHelper.database;
    try {
      String? where;
      List<dynamic>? whereArgs;

      if (query != null && query.isNotEmpty) {
        where = '${SqliteConstants.colProductName} LIKE ? OR ${SqliteConstants.colProductSku} LIKE ?';
        whereArgs = ['%$query%', '%$query%'];
      }

      final List<Map<String, dynamic>> maps = await db.query(
        SqliteConstants.tableProducts,
        where: where,
        whereArgs: whereArgs,
        limit: limit,
        offset: offset,
        orderBy: '${SqliteConstants.colProductName} ASC',
      );
      return maps.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to fetch products: $e');
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    if (kIsWeb) return;
    final db = await dbHelper.database;
    try {
      await db.insert(
        SqliteConstants.tableProducts,
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _updateStream(); // إخطار المشتركين بالتغيير
    } catch (e) {
      throw CacheException('Failed to cache product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    if (kIsWeb) return;
    final db = await dbHelper.database;
    try {
      await db.delete(
        SqliteConstants.tableProducts,
        where: '${SqliteConstants.colProductId} = ?',
        whereArgs: [id],
      );
      await _updateStream(); // إخطار المشتركين بالتغيير
    } catch (e) {
      throw CacheException('Failed to delete product: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    if (kIsWeb) throw CacheException('SQLite not supported on Web');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteConstants.tableProducts,
      where: '${SqliteConstants.colProductId} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return ProductModel.fromJson(maps.first);
    throw CacheException('Product not found');
  }

  @override
  Future<List<ProductModel>> getLowStockProducts() async {
    if (kIsWeb) return [];
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteConstants.tableProducts,
      where: '${SqliteConstants.colProductQuantity} <= ${SqliteConstants.colProductLowStockThreshold}',
    );
    return maps.map((json) => ProductModel.fromJson(json)).toList();
  }
}
