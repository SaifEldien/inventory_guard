import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'audit_state.dart';
import '../../domain/usecases/get_all_audit_logs.dart';
import '../../domain/usecases/get_product_audit_logs.dart';
import '../../domain/usecases/watch_all_audit_logs.dart';
import '../../../../core/error/failures.dart';

class AuditCubit extends Cubit<AuditState> {
  final GetAllAuditLogs getAllAuditLogs;
  final GetProductAuditLogs getProductAuditLogs;
  final WatchAllAuditLogs watchAllAuditLogs;
  StreamSubscription? _auditSubscription;

  AuditCubit({
    required this.getAllAuditLogs,
    required this.getProductAuditLogs,
    required this.watchAllAuditLogs,
  }) : super(AuditInitial());

  void watchLogs({int limit = 50, int offset = 0}) {
    debugPrint('AuditCubit: Starting to watch logs...');
    emit(AuditLoading());
    _auditSubscription?.cancel();
    _auditSubscription = watchAllAuditLogs(limit: limit, offset: offset).listen(
      (logs) {
        debugPrint('AuditCubit: Received ${logs.length} logs via stream');
        emit(AuditLoaded(logs));
      },
      onError: (error) {
        debugPrint('AuditCubit: Stream error: $error');
        emit(AuditError(error.toString()));
      },
    );
  }

  Future<void> loadAllLogs({int limit = 50, int offset = 0}) async {
    debugPrint('AuditCubit: Loading all logs...');
    emit(AuditLoading());
    final result = await getAllAuditLogs(AuditLogsParams(limit: limit, offset: offset));
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('AuditCubit: Load all logs failed: $message');
        emit(AuditError(message));
      },
      (logs) {
        debugPrint('AuditCubit: Loaded ${logs.length} logs');
        emit(AuditLoaded(logs));
      },
    );
  }

  Future<void> loadProductLogs(String productId) async {
    debugPrint('AuditCubit: Loading logs for product: $productId');
    emit(AuditLoading());
    final result = await getProductAuditLogs(productId);
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('AuditCubit: Load product logs failed: $message');
        emit(AuditError(message));
      },
      (logs) {
        debugPrint('AuditCubit: Loaded ${logs.length} logs for product');
        emit(AuditLoaded(logs));
      },
    );
  }

  @override
  Future<void> close() {
    _auditSubscription?.cancel();
    return super.close();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    return "An unexpected error occurred.";
  }
}
