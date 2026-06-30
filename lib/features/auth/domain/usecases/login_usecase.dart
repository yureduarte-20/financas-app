import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  static final RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  Future<Either<Failure, void>> call({required String email, required String password}) async {
    if (email.isEmpty || !_emailRegExp.hasMatch(email)) {
      return Left(ValidationFailure('E-mail inválido ou vazio'));
    }
    if (password.length < 6) {
      return Left(ValidationFailure('Senha deve ter no mínimo 6 caracteres'));
    }

    return repository.login(email: email, password: password);
  }
}
