import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../datasources/warehouse_remote_data_source.dart';
import '../models/warehouse_model.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final WarehouseRemoteDataSource remoteDataSource;

  WarehouseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Warehouse>>> getWarehouses() async {
    try {
      final remoteWarehouses = await remoteDataSource.getAllWarehouses();
      return Right(remoteWarehouses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addWarehouse(Warehouse warehouse) async {
    try {
      await remoteDataSource.addWarehouse(WarehouseModel.fromEntity(warehouse));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWarehouse(Warehouse warehouse) async {
    try {
      await remoteDataSource.updateWarehouse(WarehouseModel.fromEntity(warehouse));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWarehouse(String id) async {
    try {
      await remoteDataSource.deleteWarehouse(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
