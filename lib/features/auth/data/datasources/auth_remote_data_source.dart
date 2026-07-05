import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> authStateChanges();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Stream<UserModel?> authStateChanges() {
    return firebaseAuth.authStateChanges().map(
          (user) => user != null ? UserModel.fromFirebase(user) : null,
        );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebase(user) : null;
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    final result = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebase(result.user!);
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    final result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user!.updateDisplayName(name);
    return UserModel.fromFirebase(result.user!);
  }
}
