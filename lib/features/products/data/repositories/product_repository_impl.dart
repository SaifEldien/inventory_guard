import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_data_source.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getAllProducts({
    int limit = 20,
    int offset = 0,
    String? query,
  }) async {
    return _repoTask(() async {
      if (await networkInfo.isConnected) {
        final remoteProducts = await remoteDataSource.getAllProducts(
          limit: limit,
          offset: offset,
          query: query,
        );
        
        if (!kIsWeb) {
          for (var product in remoteProducts) {
            await localDataSource.cacheProduct(product);
          }
        }
        return remoteProducts;
      } else {
        if (kIsWeb) {
          throw ServerException('Internet connection required on Web');
        }
        return await localDataSource.getAllProducts(
          limit: limit,
          offset: offset,
          query: query,
        );
      }
    });
  }

  @override
  Stream<List<Product>> watchAllProducts() {
    if (kIsWeb) {
      // For web, emit current products from remote once to avoid infinite loading
      return Stream.fromFuture(
        remoteDataSource.getAllProducts(limit: 100).then(
          (models) => models.map((m) => m as Product).toList(),
        ),
      );
    }
    return localDataSource.watchAllProducts().map(
          (models) => models.map((m) => m as Product).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    return _repoTask(() async {
      final model = product.toModel();
      
      if (!kIsWeb) {
        await localDataSource.cacheProduct(model);
      }
      
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.uploadProduct(model);
        } on ServerException catch (e) {
          debugPrint('Remote upload failed: ${e.message}');
          if (!kIsWeb) {
            await _addToSyncQueue('ADD', model.toJson());
          } else {
            rethrow;
          }
        }
      } else {
        if (kIsWeb) {
          throw ServerException('No internet connection');
        }
        await _addToSyncQueue('ADD', model.toJson());
      }
    });
  }

  Future<void> _addToSyncQueue(String action, Map<String, dynamic> payload) async {
    debugPrint('Adding to sync queue: $action');
    // Sync Queue logic to be implemented in local data source
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    return _repoTask(() async {
      final model = product.toModel();
      if (!kIsWeb) {
        await localDataSource.cacheProduct(model);
      }
      if (await networkInfo.isConnected) {
        await remoteDataSource.uploadProduct(model);
      }
    });
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    return _repoTask(() async {
      if (!kIsWeb) {
        await localDataSource.deleteProduct(id);
      }
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteProduct(id);
      }
    });
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    return _repoTask(() async {
      if (kIsWeb) {
        return await remoteDataSource.getProductById(id);
      }
      return await localDataSource.getProductById(id);
    });
  }

  @override
  Future<Either<Failure, List<Product>>> getLowStockProducts() async {
    return _repoTask(() async {
      if (kIsWeb) {
        final all = await remoteDataSource.getAllProducts(limit: 100);
        return all.where((p) => p.quantity <= p.lowStockThreshold).map((m) => m as Product).toList();
      }
      final models = await localDataSource.getLowStockProducts();
      return models.map((m) => m as Product).toList();
    });
  }

  Future<Either<Failure, T>> _repoTask<T>(Future<T> Function() task) async {
    try {
      final result = await task();
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('[REPOSITORY ERROR] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      debugPrint('[REPOSITORY ERROR] CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e, stack) {
      debugPrint('[REPOSITORY ERROR] Unexpected: $e');
      debugPrint(stack.toString());
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
