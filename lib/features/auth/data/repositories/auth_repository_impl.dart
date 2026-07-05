import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> authStateChanges() {
    return remoteDataSource.authStateChanges();
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn(String email, String password) async {
    try {
      final user = await remoteDataSource.signIn(email, password);
      return Right(user);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Password reset failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name) async {
    try {
      final user = await remoteDataSource.signUp(email, password, name);
      return Right(user);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
