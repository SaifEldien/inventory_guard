import 'dart:convert';
import '../../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    required super.id,
    required super.name,
    required super.contactPerson,
    required super.email,
    required super.phone,
    required super.suppliedCategories,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contactPerson: json['contactPerson'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      suppliedCategories: json['suppliedCategories'] is String 
          ? (jsonDecode(json['suppliedCategories'] as String) as List).cast<String>()
          : (json['suppliedCategories'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'suppliedCategories': jsonEncode(suppliedCategories),
    };
  }

  factory SupplierModel.fromEntity(Supplier entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      contactPerson: entity.contactPerson,
      email: entity.email,
      phone: entity.phone,
      suppliedCategories: entity.suppliedCategories,
    );
  }

  Supplier toEntity() {
    return Supplier(
      id: id,
      name: name,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      suppliedCategories: suppliedCategories,
    );
  }
}
