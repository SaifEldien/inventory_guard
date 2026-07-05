import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/warehouse_model.dart';
import 'warehouse_remote_data_source.dart';

class WarehouseRemoteDataSourceImpl implements WarehouseRemoteDataSource {
  final FirebaseFirestore firestore;

  WarehouseRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _warehouses => firestore.collection('warehouses');

  @override
  Future<List<WarehouseModel>> getAllWarehouses() async {
    final snapshot = await _warehouses.get();
    return snapshot.docs.map((doc) => WarehouseModel.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    })).toList();
  }

  @override
  Future<void> addWarehouse(WarehouseModel warehouse) async {
    await _warehouses.doc(warehouse.id).set(warehouse.toJson());
  }

  @override
  Future<void> updateWarehouse(WarehouseModel warehouse) async {
    await _warehouses.doc(warehouse.id).update(warehouse.toJson());
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    await _warehouses.doc(id).delete();
  }
}
