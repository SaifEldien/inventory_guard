import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/audit_log.dart';
import '../repositories/audit_repository.dart';

class GetAllAuditLogs implements UseCase<List<AuditLog>, AuditLogsParams> {
  final AuditRepository repository;

  GetAllAuditLogs(this.repository);

  @override
  Future<Either<Failure, List<AuditLog>>> call(AuditLogsParams params) async {
    return await repository.getAllLogs(limit: params.limit, offset: params.offset);
  }
}

class AuditLogsParams extends Equatable {
  final int limit;
  final int offset;

  const AuditLogsParams({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}
