import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/audit_log.dart';
import '../repositories/audit_repository.dart';

class GetProductAuditLogs implements UseCase<List<AuditLog>, String> {
  final AuditRepository repository;

  GetProductAuditLogs(this.repository);

  @override
  Future<Either<Failure, List<AuditLog>>> call(String productId) async {
    return await repository.getLogsByProduct(productId);
  }
}
