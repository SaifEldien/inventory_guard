import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../../domain/usecases/reset_password.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn _signInUseCase;
  final SignUp _signUpUseCase;
  final SignOut _signOutUseCase;
  final WatchAuthState _watchAuthStateUseCase;
  final ResetPassword _resetPasswordUseCase;
  
  StreamSubscription? _authSubscription;

  AuthCubit({
    required this._signInUseCase,
    required this._signUpUseCase,
    required this._signOutUseCase,
    required this._watchAuthStateUseCase,
    required this._resetPasswordUseCase,
  }) : super(AuthInitial()) {
    _init();
  }

  void _init() {
    _authSubscription = _watchAuthStateUseCase().listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    debugPrint('AuthCubit: Attempting signIn for $email');
    emit(AuthLoading());
    final result = await _signInUseCase(email, password);
    result.fold(
      (failure) {
        debugPrint('AuthCubit: signIn failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('AuthCubit: signIn success for ${user.email}');
        emit(Authenticated(user));
      },
    );
  }
 
  Future<void> signUp(String email, String password, String name) async {
    debugPrint('AuthCubit: Attempting signUp for $email');
    emit(AuthLoading());
    final result = await _signUpUseCase(email, password, name);
    result.fold(
      (failure) {
        debugPrint('AuthCubit: signUp failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('AuthCubit: signUp success for ${user.email}');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> logout() async {
    debugPrint('AuthCubit: Attempting logout');
    emit(AuthLoading());
    final result = await _signOutUseCase();
    result.fold(
      (failure) {
        debugPrint('AuthCubit: logout failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (_) {
        debugPrint('AuthCubit: logout success');
        emit(Unauthenticated());
      },
    );
  }

  Future<void> resetPassword(String email) async {
    debugPrint('AuthCubit: Attempting password reset for $email');
    emit(AuthLoading());
    final result = await _resetPasswordUseCase(email);
    result.fold(
      (failure) {
        debugPrint('AuthCubit: resetPassword failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (_) {
        debugPrint('AuthCubit: resetPassword success');
        emit(Unauthenticated()); // Go back to login state
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
