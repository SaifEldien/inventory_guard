import 'package:equatable/equatable.dart';
import '../../domain/entities/audit_log.dart';

abstract class AuditState extends Equatable {
  const AuditState();

  @override
  List<Object?> get props => [];
}

class AuditInitial extends AuditState {}

class AuditLoading extends AuditState {}

class AuditLoaded extends AuditState {
  final List<AuditLog> logs;
  const AuditLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class AuditError extends AuditState {
  final String message;
  const AuditError(this.message);

  @override
  List<Object?> get props => [message];
}
