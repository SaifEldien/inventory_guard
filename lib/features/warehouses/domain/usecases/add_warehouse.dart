import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/warehouse.dart';
import '../repositories/warehouse_repository.dart';

class AddWarehouseUseCase implements UseCase<void, Warehouse> {
  final WarehouseRepository repository;

  AddWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Warehouse warehouse) async {
    return await repository.addWarehouse(warehouse);
  }
}
