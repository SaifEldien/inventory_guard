import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/warehouse.dart';
import '../repositories/warehouse_repository.dart';

class UpdateWarehouseUseCase implements UseCase<void, Warehouse> {
  final WarehouseRepository repository;

  UpdateWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Warehouse warehouse) async {
    return await repository.updateWarehouse(warehouse);
  }
}
