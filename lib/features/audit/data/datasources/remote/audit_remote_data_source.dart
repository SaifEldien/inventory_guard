import '../../models/audit_log_model.dart';

abstract class AuditRemoteDataSource {
  Future<void> uploadLog(AuditLogModel log);
  Future<List<AuditLogModel>> getAllLogs({int limit = 50, int offset = 0});
  Future<List<AuditLogModel>> getLogsByProduct(String productId);
}
