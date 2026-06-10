import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:financas_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:financas_app/core/errors/failures.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, void>>(const Right(null));
  });

  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });

  final String tEmail = 'test@test.com';
  final String tPassword = 'password123';

  test('Deve retornar ValidationFailure quando o email for inválido', () async {
    // Arrange
    // Act
    final result = await usecase(email: 'invalid-email', password: tPassword);
    
    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'E-mail inválido ou vazio');
      },
      (_) => fail('Não deveria retornar sucesso'),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('Deve retornar ValidationFailure quando a senha tiver menos de 6 caracteres', () async {
    // Act
    final result = await usecase(email: tEmail, password: '123');
    
    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Senha deve ter no mínimo 6 caracteres');
      },
      (_) => fail('Não deveria retornar sucesso'),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('Deve chamar repository.login() e retornar Right(null) em caso de sucesso', () async {
    // Arrange
    when(mockRepository.login(email: tEmail, password: tPassword))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await usecase(email: tEmail, password: tPassword);

    // Assert
    expect(result, const Right(null));
    verify(mockRepository.login(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
