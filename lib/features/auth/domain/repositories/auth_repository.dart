import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<UserEntity?> authStateChanges();
}
