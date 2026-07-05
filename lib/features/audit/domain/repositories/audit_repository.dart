import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/audit_log.dart';

abstract class AuditRepository {
  Future<Either<Failure, void>> logAction(AuditLog log);
  Future<Either<Failure, List<AuditLog>>> getLogsByProduct(String productId);
  Future<Either<Failure, List<AuditLog>>> getAllLogs({int limit = 50, int offset = 0});
  Stream<List<AuditLog>> watchAllLogs({int limit = 50, int offset = 0});
}
