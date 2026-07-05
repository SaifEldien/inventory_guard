import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final List<String> suppliedCategories;

  const Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.suppliedCategories,
  });

  // Basic Validation Logic
  bool get isValid => name.isNotEmpty && email.contains('@');

  @override
  List<Object?> get props => [
        id,
        name,
        contactPerson,
        email,
        phone,
        suppliedCategories,
      ];

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    List<String>? suppliedCategories,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      suppliedCategories: suppliedCategories ?? this.suppliedCategories,
    );
  }
}
