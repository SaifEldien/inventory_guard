import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_state.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_low_stock_products.dart';
import '../../domain/entities/product.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetAllProducts getAllProducts;
  final AddProduct addProductUseCase;
  final UpdateProduct updateProductUseCase;
  final DeleteProduct deleteProductUseCase;
  final GetLowStockProducts getLowStockProducts;

  ProductCubit({
    required this.getAllProducts,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.getLowStockProducts,
  }) : super(ProductInitial());

  Future<void> loadProducts({String? query}) async {
    debugPrint('Loading products... query: $query');
    emit(ProductLoading());
    final result = await getAllProducts(GetAllProductsParams(query: query));
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('Load products failed: $message');
        emit(ProductError(message));
      },
      (products) {
        debugPrint('Loaded ${products.length} products');
        emit(ProductLoaded(products));
      },
    );
  }

  Future<void> searchProducts(String query) async {
    debugPrint('Searching products... query: $query');
    final result = await getAllProducts(GetAllProductsParams(query: query));
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('Search failed: $message');
        emit(ProductError(message));
      },
      (products) => emit(ProductLoaded(products)),
    );
  }

  Future<void> loadLowStockProducts() async {
    emit(ProductLoading());
    final result = await getLowStockProducts(NoParams());
    result.fold(
      (failure) => emit(ProductError(_mapFailureToMessage(failure))),
      (products) => emit(ProductLoaded(products)),
    );
  }

  Future<void> addProduct(Product product) async {
    debugPrint('ProductCubit: Adding product: ${product.name}');
    final result = await addProductUseCase(product);
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('ProductCubit: Add product failed: $message');
        emit(ProductError(message));
      },
      (_) => loadProducts(),
    );
  }

  Future<void> updateProduct(Product product) async {
    debugPrint('ProductCubit: Updating product: ${product.id}');
    final result = await updateProductUseCase(product);
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('ProductCubit: Update product failed: $message');
        emit(ProductError(message));
      },
      (_) => loadProducts(),
    );
  }

  Future<void> deleteProduct(String id) async {
    debugPrint('ProductCubit: Deleting product: $id');
    final result = await deleteProductUseCase(id);
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('ProductCubit: Delete product failed: $message');
        emit(ProductError(message));
      },
      (_) => loadProducts(),
    );
  }

  Future<void> bulkImportProducts(List<Map<String, dynamic>> productsData) async {
    emit(ProductLoading());
    for (final data in productsData) {
      final product = Product(
        id: data['ID']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: data['Name']?.toString() ?? 'Unnamed Product',
        sku: data['SKU']?.toString() ?? 'SKU-${DateTime.now().millisecondsSinceEpoch}',
        category: data['Category']?.toString() ?? 'Other',
        quantity: int.tryParse(data['Quantity']?.toString() ?? '0') ?? 0,
        unitPrice: double.tryParse(data['UnitPrice']?.toString() ?? '0.0') ?? 0.0,
        supplierId: data['SupplierID']?.toString() ?? '',
        warehouseId: data['WarehouseID']?.toString() ?? 'wh-main',
        lowStockThreshold: int.tryParse(data['LowStockThreshold']?.toString() ?? '5') ?? 5,
      );
      // We use addProductUseCase. Ideally, we should have a bulk add usecase for performance.
      await addProductUseCase(product);
    }
    await loadProducts();
  }

  Future<void> seedProducts() async {
    final seedData = [
      Product(
        id: '1',
        name: 'MacBook Pro M3',
        sku: 'MBP-M3-001',
        category: 'Electronics',
        quantity: 15,
        unitPrice: 1999.99,
        supplierId: 'SUP-001',
        warehouseId: 'wh-main',
        lowStockThreshold: 5,
      ),
      Product(
        id: '2',
        name: 'Ergonomic Desk Chair',
        sku: 'CHAIR-ERG-02',
        category: 'Furniture',
        quantity: 4,
        unitPrice: 299.50,
        supplierId: 'SUP-002',
        warehouseId: 'wh-showroom',
        lowStockThreshold: 10,
      ),
      Product(
        id: '3',
        name: 'Logitech MX Master 3S',
        sku: 'MOUSE-LOG-03',
        category: 'Electronics',
        quantity: 45,
        unitPrice: 99.00,
        supplierId: 'SUP-001',
        warehouseId: 'wh-main',
        lowStockThreshold: 15,
      ),
    ];

    emit(ProductLoading());
    for (final product in seedData) {
      await addProductUseCase(product);
    }
    await loadProducts();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    return "An unexpected error occurred.";
  }
}
