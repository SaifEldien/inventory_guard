import '../../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts({
    int limit = 20,
    int offset = 0,
    String? query,
  });
  Future<ProductModel> getProductById(String id);
  Future<void> uploadProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}
