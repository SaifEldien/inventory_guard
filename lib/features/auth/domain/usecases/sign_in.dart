import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) async {
    return await repository.signIn(email, password);
  }
}
