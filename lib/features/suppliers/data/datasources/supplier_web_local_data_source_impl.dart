import '../models/supplier_model.dart';
import 'supplier_local_data_source.dart';

class SupplierWebLocalDataSourceImpl implements SupplierLocalDataSource {
  @override
  Future<List<SupplierModel>> getAllSuppliers() async => [];

  @override
  Stream<List<SupplierModel>> watchAllSuppliers() => const Stream.empty();

  @override
  Future<SupplierModel?> getSupplierById(String id) async => null;

  @override
  Future<void> cacheSupplier(SupplierModel supplier) async {}

  @override
  Future<void> deleteSupplier(String id) async {}
}
