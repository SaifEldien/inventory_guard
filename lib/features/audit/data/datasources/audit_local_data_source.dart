import '../models/audit_log_model.dart';

abstract class AuditLocalDataSource {
  Future<void> cacheLog(AuditLogModel log);
  Future<List<AuditLogModel>> getLogsByProduct(String productId);
  Future<List<AuditLogModel>> getAllLogs({int limit = 50, int offset = 0});
  Stream<List<AuditLogModel>> watchAllLogs({int limit = 50, int offset = 0});
}
