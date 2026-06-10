import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResendCodeUseCase {
  final AuthRepository repository;

  ResendCodeUseCase(this.repository);

  Future<Either<Failure, void>> call({required String email, required String type}) async {
    if (email.isEmpty) {
      return Left(ValidationFailure('E-mail obrigatório'));
    }
    if (type.isEmpty) {
      return Left(ValidationFailure('Tipo obrigatório'));
    }

    return repository.resendCode(email: email, type: type);
  }
}
