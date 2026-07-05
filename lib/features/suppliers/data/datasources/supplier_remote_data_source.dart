import '../models/supplier_model.dart';

abstract class SupplierRemoteDataSource {
  Future<List<SupplierModel>> getAllSuppliers();
  Future<void> uploadSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
  Future<SupplierModel> getSupplierById(String id);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  @override
  Future<List<SupplierModel>> getAllSuppliers() async => [];
  @override
  Future<void> uploadSupplier(SupplierModel supplier) async {}
  @override
  Future<void> deleteSupplier(String id) async {}

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    throw UnimplementedError();
  }
}
