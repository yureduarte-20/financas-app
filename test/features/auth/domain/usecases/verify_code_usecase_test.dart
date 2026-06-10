import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:financas_app/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:financas_app/features/auth/domain/entities/user.dart';
import 'package:financas_app/core/errors/failures.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  final String tEmail = 'test@test.com';
  final tUser = User(id: '1', name: 'Test User', email: tEmail);

  setUpAll(() {
    provideDummy<Either<Failure, User>>(Right(tUser));
  });

  late VerifyCodeUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = VerifyCodeUseCase(mockRepository);
  });

  final String tCode = '123456';
  final String tDeviceName = 'Mobile';

  test('Deve retornar o UserModel quando a confirmação do código for bem-sucedida', () async {
    // Arrange
    when(mockRepository.verifyCode(email: tEmail, code: tCode, deviceName: tDeviceName))
        .thenAnswer((_) async => Right(tUser));

    // Act
    final result = await usecase(email: tEmail, code: tCode, deviceName: tDeviceName);

    // Assert
    expect(result, Right(tUser));
    verify(mockRepository.verifyCode(email: tEmail, code: tCode, deviceName: tDeviceName));
    verifyNoMoreInteractions(mockRepository);
  });
}
