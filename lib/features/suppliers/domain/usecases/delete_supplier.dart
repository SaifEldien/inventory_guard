import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/supplier_repository.dart';

class DeleteSupplier implements UseCase<void, String> {
  final SupplierRepository repository;

  DeleteSupplier(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteSupplier(id);
  }
}
