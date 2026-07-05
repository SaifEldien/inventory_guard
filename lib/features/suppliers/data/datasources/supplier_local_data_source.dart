import '../models/supplier_model.dart';

abstract class SupplierLocalDataSource {
  Future<List<SupplierModel>> getAllSuppliers();
  Stream<List<SupplierModel>> watchAllSuppliers();
  Future<SupplierModel?> getSupplierById(String id);
  Future<void> cacheSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
}
