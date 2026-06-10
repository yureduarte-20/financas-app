import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyCodeUseCase {
  final AuthRepository repository;

  VerifyCodeUseCase(this.repository);

  Future<Either<Failure, User>> call({required String email, required String code, required String deviceName}) async {
    if (email.isEmpty) {
      return Left(ValidationFailure('E-mail obrigatório'));
    }
    if (code.length != 6) {
      return Left(ValidationFailure('Código deve ter 6 dígitos'));
    }
    if (deviceName.isEmpty) {
      return Left(ValidationFailure('Nome do dispositivo obrigatório'));
    }

    return repository.verifyCode(email: email, code: code, deviceName: deviceName);
  }
}
