import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, void>> call({required String name, required String email, required String password}) async {
    if (name.isEmpty) {
      return Left(ValidationFailure('Nome obrigatório'));
    }
    if (email.isEmpty || !email.contains('@')) {
      return Left(ValidationFailure('E-mail inválido'));
    }
    if (password.length < 6) {
      return Left(ValidationFailure('Senha deve ter no mínimo 6 caracteres'));
    }

    return repository.register(name: name, email: email, password: password);
  }
}
