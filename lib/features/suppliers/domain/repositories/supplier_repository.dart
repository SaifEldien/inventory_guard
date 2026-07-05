import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/supplier.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<Supplier>>> getAllSuppliers({String? query});
  Stream<List<Supplier>> watchAllSuppliers();
  Future<Either<Failure, Supplier>> getSupplierById(String id);
  Future<Either<Failure, void>> addSupplier(Supplier supplier);
  Future<Either<Failure, void>> updateSupplier(Supplier supplier);
  Future<Either<Failure, void>> deleteSupplier(String id);
}
