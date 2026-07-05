import '../../models/product_model.dart';
import 'product_local_data_source.dart';

/// Web implementation that bypasses local storage as requested.
class ProductWebLocalDataSourceImpl implements ProductLocalDataSource {
  @override
  Future<List<ProductModel>> getAllProducts({int limit = 20, int offset = 0, String? query}) async => [];

  @override
  Stream<List<ProductModel>> watchAllProducts() => const Stream.empty();

  @override
  Future<ProductModel> getProductById(String id) async => throw UnimplementedError('Local storage disabled on Web');

  @override
  Future<void> cacheProduct(ProductModel productToCache) async {}

  @override
  Future<void> deleteProduct(String id) async {}

  @override
  Future<List<ProductModel>> getLowStockProducts() async => [];
}
