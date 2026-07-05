import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_local_data_source.dart';
import '../datasources/supplier_remote_data_source.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierLocalDataSource localDataSource;
  final SupplierRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SupplierRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // نستخدم نفس الدالة المركزية لمعالجة الأخطاء كما في المنتجات
  Future<Either<Failure, T>> _repoTask<T>(Future<T> Function() task) async {
    try {
      final result = await task();
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('[SUPPLIER REPO ERROR] Server: ${e.message}');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      debugPrint('[SUPPLIER REPO ERROR] Cache: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e, stack) {
      debugPrint('[SUPPLIER REPO ERROR] Unexpected: $e');
      debugPrint(stack.toString());
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addSupplier(Supplier supplier) async {
    return _repoTask(() async {
      final model = SupplierModel.fromEntity(supplier);
      if (!kIsWeb) {
        await localDataSource.cacheSupplier(model);
      }
      
      if (await networkInfo.isConnected) {
        await remoteDataSource.uploadSupplier(model);
      } else if (kIsWeb) {
        throw ServerException('No internet connection');
      }
    });
  }

  @override
  Stream<List<Supplier>> watchAllSuppliers() {
    if (kIsWeb) {
      // For web, emit current suppliers from remote once to avoid infinite loading
      return Stream.fromFuture(
        remoteDataSource.getAllSuppliers().then(
          (models) => models.map((m) => m.toEntity()).toList(),
        ),
      );
    }
    return localDataSource.watchAllSuppliers().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, List<Supplier>>> getAllSuppliers({String? query}) async {
    return _repoTask(() async {
      List<Supplier> suppliers;
      if (await networkInfo.isConnected) {
        final models = await remoteDataSource.getAllSuppliers();
        if (!kIsWeb) {
          for (var model in models) {
            await localDataSource.cacheSupplier(model);
          }
        }
        suppliers = models.map((m) => m.toEntity()).toList();
      } else {
        if (kIsWeb) throw ServerException('Offline on Web');
        final models = await localDataSource.getAllSuppliers();
        suppliers = models.map((m) => m.toEntity()).toList();
      }

      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        return suppliers.where((s) {
          return s.name.toLowerCase().contains(lowercaseQuery) ||
              s.contactPerson.toLowerCase().contains(lowercaseQuery) ||
              s.email.toLowerCase().contains(lowercaseQuery);
        }).toList();
      }
      return suppliers;
    });
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(String id) async {
    return _repoTask(() async {
      if (!kIsWeb) {
        await localDataSource.deleteSupplier(id);
      }
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteSupplier(id);
      }
    });
  }

  @override
  Future<Either<Failure, Supplier>> getSupplierById(String id) async {
    return _repoTask(() async {
      if (kIsWeb) {
        // Assume remoteDataSource has getSupplierById or use getAll and find
        final all = await remoteDataSource.getAllSuppliers();
        final model = all.firstWhere((m) => m.id == id);
        return model.toEntity();
      }
      final model = await localDataSource.getSupplierById(id);
      if (model != null) return model.toEntity();
      throw CacheException();
    });
  }

  @override
  Future<Either<Failure, void>> updateSupplier(Supplier supplier) async {
    return addSupplier(supplier); // الـ SQLite يستخدم Replace
  }
}
