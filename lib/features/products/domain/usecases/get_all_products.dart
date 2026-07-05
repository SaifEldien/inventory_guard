import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetAllProducts implements UseCase<List<Product>, GetAllProductsParams> {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetAllProductsParams params) async {
    return await repository.getAllProducts(
      limit: params.limit,
      offset: params.offset,
      query: params.query,
    );
  }
}

class GetAllProductsParams extends Equatable {
  final int limit;
  final int offset;
  final String? query;

  const GetAllProductsParams({
    this.limit = 20,
    this.offset = 0,
    this.query,
  });

  @override
  List<Object?> get props => [limit, offset, query];
}
