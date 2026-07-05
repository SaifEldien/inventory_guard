import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/warehouse.dart';
import '../repositories/warehouse_repository.dart';

class GetWarehouses implements UseCase<List<Warehouse>, NoParams> {
  final WarehouseRepository repository;

  GetWarehouses(this.repository);

  @override
  Future<Either<Failure, List<Warehouse>>> call(NoParams params) async {
    return await repository.getWarehouses();
  }
}
