import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import 'product_remote_data_source.dart';

class ProductFirestoreDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductFirestoreDataSourceImpl({required this.firestore});

  CollectionReference get _products => firestore.collection('products');

  @override
  Future<List<ProductModel>> getAllProducts({
    int limit = 20,
    int offset = 0,
    String? query,
  }) async {
    // Basic Firestore implementation
    Query queryRef = _products.orderBy('name').limit(limit);
    
    if (query != null && query.isNotEmpty) {
      queryRef = queryRef.where('name', isGreaterThanOrEqualTo: query)
                         .where('name', isLessThanOrEqualTo: '$query\uf8ff');
    }

    final snapshot = await queryRef.get();
    return snapshot.docs.map((doc) => ProductModel.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    })).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await _products.doc(id).get();
    return ProductModel.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    });
  }

  @override
  Future<void> uploadProduct(ProductModel product) async {
    await _products.doc(product.id).set(product.toJson());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }
}
