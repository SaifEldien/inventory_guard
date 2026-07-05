import '../models/warehouse_model.dart';

abstract class WarehouseRemoteDataSource {
  Future<List<WarehouseModel>> getAllWarehouses();
  Future<void> addWarehouse(WarehouseModel warehouse);
  Future<void> updateWarehouse(WarehouseModel warehouse);
  Future<void> deleteWarehouse(String id);
}
