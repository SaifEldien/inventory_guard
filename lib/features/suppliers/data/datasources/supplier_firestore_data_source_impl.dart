import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier_model.dart';
import 'supplier_remote_data_source.dart';

class SupplierFirestoreDataSourceImpl implements SupplierRemoteDataSource {
  final FirebaseFirestore firestore;
  SupplierFirestoreDataSourceImpl({required this.firestore});

  CollectionReference get _suppliers => firestore.collection('suppliers');

  @override
  Future<List<SupplierModel>> getAllSuppliers() async {
    final snapshot = await _suppliers.get();
    return snapshot.docs.map((doc) => SupplierModel.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    })).toList();
  }

  @override
  Future<void> uploadSupplier(SupplierModel supplier) async {
    await _suppliers.doc(supplier.id).set(supplier.toJson());
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _suppliers.doc(id).delete();
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    final doc = await _suppliers.doc(id).get();
    return SupplierModel.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    });
  }
}
