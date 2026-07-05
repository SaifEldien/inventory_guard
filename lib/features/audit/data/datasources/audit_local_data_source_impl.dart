import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/sqlite/sqlite_helper.dart';
import '../../../../core/database/sqlite/sqlite_constants.dart';
import '../models/audit_log_model.dart';
import 'audit_local_data_source.dart';

class AuditLocalDataSourceImpl implements AuditLocalDataSource {
  final SqliteHelper dbHelper;
  final _logStreamController = StreamController<List<AuditLogModel>>.broadcast();

  AuditLocalDataSourceImpl(this.dbHelper);

  Future<void> _updateStream() async {
    final logs = await getAllLogs();
    _logStreamController.add(logs);
  }

  @override
  Future<void> cacheLog(AuditLogModel log) async {
    if (kIsWeb) return;
    final db = await dbHelper.database;
    await db.insert(
      SqliteConstants.tableAuditLogs,
      log.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _updateStream();
  }

  @override
  Future<List<AuditLogModel>> getAllLogs({int limit = 50, int offset = 0}) async {
    if (kIsWeb) return [];
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteConstants.tableAuditLogs,
      limit: limit,
      offset: offset,
      orderBy: '${SqliteConstants.colAuditTimestamp} DESC',
    );
    return maps.map((map) => AuditLogModel.fromJson(map)).toList();
  }

  @override
  Future<List<AuditLogModel>> getLogsByProduct(String productId) async {
    if (kIsWeb) return [];
    final db = await dbHelper.database;
    final maps = await db.query(
      SqliteConstants.tableAuditLogs,
      where: '${SqliteConstants.colAuditProductId} = ?',
      whereArgs: [productId],
      orderBy: '${SqliteConstants.colAuditTimestamp} DESC',
    );
    return maps.map((map) => AuditLogModel.fromJson(map)).toList();
  }

  @override
  Stream<List<AuditLogModel>> watchAllLogs({int limit = 50, int offset = 0}) {
    _updateStream();
    return _logStreamController.stream;
  }
}
