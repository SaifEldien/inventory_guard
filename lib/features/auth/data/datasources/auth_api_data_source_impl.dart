import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthApiDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthApiDataSourceImpl({required this.client});

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
      body: json.encode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return UserModel.fromFirebase(json.decode(response.body)); // Assuming same structure for simplicity
    } else {
      throw ServerException('Login failed');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    final response = await client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/register'),
      body: json.encode({'email': email, 'password': password, 'name': name}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UserModel.fromFirebase(json.decode(response.body));
    } else {
      throw ServerException('Registration failed');
    }
  }

  @override
  Future<void> signOut() async {
    // API Sign out logic (e.g. invalidate token)
  }

  @override
  Future<void> resetPassword(String email) async {
    final response = await client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/reset-password'),
      body: json.encode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw ServerException('Failed to send reset email');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Logic to get user from token/stored session
    return null; 
  }

  @override
  Stream<UserModel?> authStateChanges() {
    // For API, you'd usually use a StreamController to broadcast login/logout events
    return Stream.empty();
  }
}
