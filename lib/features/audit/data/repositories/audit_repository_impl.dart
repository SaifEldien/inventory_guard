import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_repository.dart';
import '../datasources/audit_local_data_source.dart';
import '../datasources/remote/audit_remote_data_source.dart';
import '../models/audit_log_model.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditLocalDataSource localDataSource;
  final AuditRemoteDataSource remoteDataSource;

  AuditRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<Either<Failure, T>> _repoTask<T>(Future<T> Function() task) async {
    try {
      final result = await task();
      return Right(result);
    } on CacheException {
      return Left(CacheFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logAction(AuditLog log) async {
    return _repoTask(() async {
      final model = AuditLogModel.fromEntity(log);
      if (!kIsWeb) {
        await localDataSource.cacheLog(model);
      }
      try {
        await remoteDataSource.uploadLog(model);
      } catch (e) {
        if (kIsWeb) rethrow;
        debugPrint('Failed to upload audit log to remote: $e');
      }
    });
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getAllLogs({int limit = 50, int offset = 0}) async {
    return _repoTask(() async {
      if (kIsWeb) {
        final models = await remoteDataSource.getAllLogs(limit: limit, offset: offset);
        return models.map((m) => m.toEntity()).toList();
      }
      final models = await localDataSource.getAllLogs(limit: limit, offset: offset);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getLogsByProduct(String productId) async {
    return _repoTask(() async {
      if (kIsWeb) {
        final models = await remoteDataSource.getLogsByProduct(productId);
        return models.map((m) => m.toEntity()).toList();
      }
      final models = await localDataSource.getLogsByProduct(productId);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Stream<List<AuditLog>> watchAllLogs({int limit = 50, int offset = 0}) {
    if (kIsWeb) {
      // For Web, since we don't have a local DB stream, 
      // we emit the current logs once from remote to avoid infinite loading.
      return Stream.fromFuture(
        remoteDataSource.getAllLogs(limit: limit, offset: offset).then(
          (models) => models.map((m) => m.toEntity()).toList(),
        ),
      );
    }
    return localDataSource.watchAllLogs(limit: limit, offset: offset).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }
}
