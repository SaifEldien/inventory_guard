import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

class AddSupplier implements UseCase<void, Supplier> {
  final SupplierRepository repository;

  AddSupplier(this.repository);

  @override
  Future<Either<Failure, void>> call(Supplier supplier) async {
    return await repository.addSupplier(supplier);
  }
}
