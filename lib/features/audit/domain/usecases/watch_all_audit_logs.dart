import '../entities/audit_log.dart';
import '../repositories/audit_repository.dart';

class WatchAllAuditLogs {
  final AuditRepository repository;

  WatchAllAuditLogs(this.repository);

  Stream<List<AuditLog>> call({int limit = 50, int offset = 0}) {
    return repository.watchAllLogs(limit: limit, offset: offset);
  }
}
