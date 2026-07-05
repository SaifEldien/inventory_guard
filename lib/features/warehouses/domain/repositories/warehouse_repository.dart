import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/warehouse.dart';

abstract class WarehouseRepository {
  Future<Either<Failure, List<Warehouse>>> getWarehouses();
  Future<Either<Failure, void>> addWarehouse(Warehouse warehouse);
  Future<Either<Failure, void>> updateWarehouse(Warehouse warehouse);
  Future<Either<Failure, void>> deleteWarehouse(String id);
}
