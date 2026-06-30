import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:financas_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:financas_app/core/errors/failures.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, void>>(const Right(null));
  });

  late RegisterUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUseCase(mockRepository);
  });

  final String tName = 'João Silva';
  final String tEmail = 'test@test.com';
  final String tPassword = 'password123';

  test('Deve retornar ValidationFailure quando o nome estiver vazio', () async {
    // Act
    final result = await usecase(name: '', email: tEmail, password: tPassword);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Nome obrigatório');
      },
      (_) => fail('Não deveria retornar sucesso'),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('Deve retornar ValidationFailure quando o e-mail for inválido', () async {
    // Arrange
    final invalidEmails = [
      '',
      'invalid-email',
      'user@',
      'user@domain',
      '@domain.com',
      'user@domain.',
    ];

    // Act & Assert
    for (final email in invalidEmails) {
      final result = await usecase(name: tName, email: email, password: tPassword);
      expect(result.isLeft(), true, reason: 'E-mail "$email" deve ser considerado inválido');
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'E-mail inválido');
        },
        (_) => fail('Não deveria retornar sucesso para o e-mail: $email'),
      );
    }
    verifyZeroInteractions(mockRepository);
  });

  test('Deve retornar ValidationFailure quando a senha tiver menos de 6 caracteres', () async {
    // Act
    final result = await usecase(name: tName, email: tEmail, password: '123');

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

  test('Deve chamar repository.register() e retornar Right(null) em caso de sucesso', () async {
    // Arrange
    when(mockRepository.register(name: tName, email: tEmail, password: tPassword))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await usecase(name: tName, email: tEmail, password: tPassword);

    // Assert
    expect(result, const Right(null));
    verify(mockRepository.register(name: tName, email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
