import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:financas_app/features/auth/domain/entities/user.dart';
import 'package:financas_app/core/errors/failures.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late AuthNotifier authNotifier;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockVerifyCodeUseCase mockVerifyCodeUseCase;
  late MockResendCodeUseCase mockResendCodeUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetProfileUseCase mockGetProfileUseCase;

  setUpAll(() {
    provideDummy<Either<Failure, User>>(Left(ServerFailure('')));
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockVerifyCodeUseCase = MockVerifyCodeUseCase();
    mockResendCodeUseCase = MockResendCodeUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetProfileUseCase = MockGetProfileUseCase();

    authNotifier = AuthNotifier(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      verifyCodeUseCase: mockVerifyCodeUseCase,
      resendCodeUseCase: mockResendCodeUseCase,
      logoutUseCase: mockLogoutUseCase,
      getProfileUseCase: mockGetProfileUseCase,
    );
  });

  final tUser = User(id: '1', name: 'Test User', email: 'test@test.com');

  test('O estado inicial deve ser AuthStatus.initial', () {
    expect(authNotifier.state.status, AuthStatus.initial);
    expect(authNotifier.state.user, isNull);
  });

  group('checkAuthStatus', () {
    test('Deve transicionar para authenticated quando GetProfileUseCase retornar sucesso', () async {
      // Arrange
      when(mockGetProfileUseCase()).thenAnswer((_) async => Right(tUser));

      // Act
      final future = authNotifier.checkAuthStatus();

      // Assert - verifica estado temporário de loading
      expect(authNotifier.state.status, AuthStatus.loading);

      await future;

      // Assert - verificação final
      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user, tUser);
      verify(mockGetProfileUseCase()).called(1);
    });

    test('Deve transicionar para unauthenticated quando GetProfileUseCase falhar', () async {
      // Arrange
      when(mockGetProfileUseCase()).thenAnswer((_) async => Left(ServerFailure('Erro de autenticação')));

      // Act
      final future = authNotifier.checkAuthStatus();

      // Assert - verifica estado temporário de loading
      expect(authNotifier.state.status, AuthStatus.loading);

      await future;

      // Assert - verificação final
      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      expect(authNotifier.state.user, isNull);
      verify(mockGetProfileUseCase()).called(1);
    });
  });
}
