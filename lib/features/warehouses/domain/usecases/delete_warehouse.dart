import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/warehouse_repository.dart';

class DeleteWarehouseUseCase implements UseCase<void, String> {
  final WarehouseRepository repository;

  DeleteWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteWarehouse(id);
  }
}
