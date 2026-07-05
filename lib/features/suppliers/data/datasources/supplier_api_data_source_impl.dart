import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../models/supplier_model.dart';
import 'supplier_remote_data_source.dart';

class SupplierApiDataSourceImpl implements SupplierRemoteDataSource {
  final http.Client client;
  SupplierApiDataSourceImpl({required this.client});

  @override
  Future<List<SupplierModel>> getAllSuppliers() async {
    final response = await client.get(Uri.parse('${AppConfig.apiBaseUrl}/suppliers'));
    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      return decoded.map((json) => SupplierModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> uploadSupplier(SupplierModel supplier) async {
    await client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/suppliers'),
      body: json.encode(supplier.toJson()),
      headers: {'Content-Type': 'application/json'},
    ); 
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await client.delete(Uri.parse('${AppConfig.apiBaseUrl}/suppliers/$id'));
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    final response = await client.get(Uri.parse('${AppConfig.apiBaseUrl}/suppliers/$id'));
    if (response.statusCode == 200) {
      return SupplierModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load supplier');
  }
}
