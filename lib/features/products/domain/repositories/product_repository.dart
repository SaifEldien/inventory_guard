import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts({
    int limit = 20,
    int offset = 0,
    String? query,
  });
  Stream<List<Product>> watchAllProducts();
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, void>> addProduct(Product product);
  Future<Either<Failure, void>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String id);
  Future<Either<Failure, List<Product>>> getLowStockProducts();
}
