import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPassword implements UseCase<void, String> {
  final AuthRepository repository;

  ResetPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await repository.resetPassword(email);
  }
}
