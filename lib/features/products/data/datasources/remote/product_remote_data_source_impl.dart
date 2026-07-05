import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/error/exceptions.dart';
import '../../models/product_model.dart';
import 'product_remote_data_source.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  static const baseUrl = 'https://api.inventory.com';

  @override
  Future<List<ProductModel>> getAllProducts({
    int limit = 20,
    int offset = 0,
    String? query,
  }) async {
    final queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (query != null) queryParams['search'] = query;

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
    
    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      return decoded.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to fetch products from server');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException('Product not found on server');
    }
  }

  @override
  Future<void> uploadProduct(ProductModel product) async {
    final response = await client.post(
      Uri.parse('$baseUrl/products'),
      body: json.encode(product.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException('Failed to upload product to server');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException('Failed to delete product from server');
    }
  }
}
