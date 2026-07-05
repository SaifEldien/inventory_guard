import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

class GetAllSuppliers implements UseCase<List<Supplier>, GetAllSuppliersParams> {
  final SupplierRepository repository;

  GetAllSuppliers(this.repository);

  @override
  Future<Either<Failure, List<Supplier>>> call(GetAllSuppliersParams params) async {
    return await repository.getAllSuppliers(query: params.query);
  }
}

class GetAllSuppliersParams extends Equatable {
  final String? query;

  const GetAllSuppliersParams({this.query});

  @override
  List<Object?> get props => [query];
}
