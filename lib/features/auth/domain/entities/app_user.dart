import 'package:equatable/equatable.dart';
import '../enums/user_role.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final UserRole role;
  final DateTime lastLogin;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.lastLogin,
  });

  @override
  List<Object?> get props => [id, email, role, lastLogin];

  AppUser copyWith({
    String? id,
    String? email,
    UserRole? role,
    DateTime? lastLogin,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
