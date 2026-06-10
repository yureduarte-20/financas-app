import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:financas_app/core/errors/failures.dart';
import 'package:financas_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:financas_app/features/auth/data/models/user_model.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remote: mockRemoteDataSource,
      local: mockLocalDataSource,
    );
  });

  final tEmail = 'test@test.com';
  final tCode = '123456';
  final tDeviceName = 'Mobile';
  final tUserModel = UserModel(id: '1', name: 'Test', email: tEmail, token: 'token123');

  test('Deve retornar Right(UserModel) quando o DataSource remoto confirmar o código 2FA', () async {
    when(mockRemoteDataSource.verifyCode(tEmail, tCode, tDeviceName))
        .thenAnswer((_) async => tUserModel);
    when(mockLocalDataSource.saveToken('token123'))
        .thenAnswer((_) async => Future.value());

    final result = await repository.verifyCode(email: tEmail, code: tCode, deviceName: tDeviceName);

    expect(result, Right(tUserModel));
    verify(mockLocalDataSource.saveToken('token123'));
  });

  test('Deve retornar Left(ServerFailure) mapeando a exceção caso o DataSource remoto lance DioException', () async {
    final tException = DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(requestOptions: RequestOptions(path: ''), data: {'message': 'Invalid code'}),
    );

    when(mockRemoteDataSource.verifyCode(tEmail, tCode, tDeviceName))
        .thenThrow(tException);

    final result = await repository.verifyCode(email: tEmail, code: tCode, deviceName: tDeviceName);

    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Invalid code');
      },
      (_) => fail('Não deveria ter sucesso'),
    );
  });
}
