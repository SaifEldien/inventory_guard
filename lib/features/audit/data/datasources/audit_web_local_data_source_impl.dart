import '../models/audit_log_model.dart';
import 'audit_local_data_source.dart';

class AuditWebLocalDataSourceImpl implements AuditLocalDataSource {
  @override
  Future<void> cacheLog(AuditLogModel log) async {}

  @override
  Future<List<AuditLogModel>> getAllLogs({int limit = 50, int offset = 0}) async => [];

  @override
  Future<List<AuditLogModel>> getLogsByProduct(String productId) async => [];

  @override
  Stream<List<AuditLogModel>> watchAllLogs({int limit = 50, int offset = 0}) => const Stream.empty();
}
