import '../../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getAllProducts({
    int limit = 20,
    int offset = 0,
    String? query,
  });
  Stream<List<ProductModel>> watchAllProducts();
  Future<ProductModel> getProductById(String id);
  Future<void> cacheProduct(ProductModel productToCache);
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> getLowStockProducts();
}
