import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository repository;

  WatchAuthState(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges();
  }
}
