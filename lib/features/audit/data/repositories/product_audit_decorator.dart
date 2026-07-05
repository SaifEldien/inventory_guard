import 'package:dartz/dartz.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../domain/enums/action_type.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class ProductAuditDecorator implements ProductRepository {
  final ProductRepository _base;
  final AuditRepository _auditRepository;
  final AuthRepository _authRepository;

  ProductAuditDecorator(this._base, this._auditRepository, this._authRepository);

  Future<String> _getUserId() async {
    final userResult = await _authRepository.getCurrentUser();
    return userResult.fold(
      (failure) => 'unknown_user',
      (user) => user?.email ?? 'anonymous_user',
    );
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    final result = await _base.addProduct(product);
    final userId = await _getUserId();
    
    result.fold(
      (failure) => null, 
      (_) => _auditRepository.logAction(AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        actionType: ActionType.create,
        quantityChanged: product.quantity,
        timestamp: DateTime.now(),
        userId: userId,
        notes: 'Product added to inventory',
      )),
    );
    
    return result;
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts({int limit = 20, int offset = 0, String? query}) {
    return _base.getAllProducts(limit: limit, offset: offset, query: query);
  }

  @override
  Stream<List<Product>> watchAllProducts() => _base.watchAllProducts();

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    final result = await _base.deleteProduct(id);
    final userId = await _getUserId();
    
    result.fold(
      (failure) => null,
      (_) => _auditRepository.logAction(AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: id,
        actionType: ActionType.delete,
        quantityChanged: 0,
        timestamp: DateTime.now(),
        userId: userId,
        notes: 'Product removed from inventory',
      )),
    );
    
    return result;
  }

  @override
  Future<Either<Failure, List<Product>>> getLowStockProducts() => _base.getLowStockProducts();

  @override
  Future<Either<Failure, Product>> getProductById(String id) => _base.getProductById(id);

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    final result = await _base.updateProduct(product);
    final userId = await _getUserId();
    
    result.fold(
      (failure) => null,
      (_) => _auditRepository.logAction(AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        actionType: ActionType.update,
        quantityChanged: 0,
        timestamp: DateTime.now(),
        userId: userId,
        notes: 'Product details updated',
      )),
    );
    
    return result;
  }
}
