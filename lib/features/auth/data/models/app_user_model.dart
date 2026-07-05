import '../../domain/entities/app_user.dart';
import '../../domain/enums/user_role.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.lastLogin,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.values.byName(json['role'] as String),
      lastLogin: DateTime.fromMillisecondsSinceEpoch(json['lastLogin'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'lastLogin': lastLogin.millisecondsSinceEpoch,
    };
  }

  factory AppUserModel.fromEntity(AppUser entity) {
    return AppUserModel(
      id: entity.id,
      email: entity.email,
      role: entity.role,
      lastLogin: entity.lastLogin,
    );
  }
}
