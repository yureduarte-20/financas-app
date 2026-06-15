import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:financas_app/core/errors/failures.dart';
import 'package:financas_app/features/transactions/domain/entities/transaction.dart';
import 'package:financas_app/features/transactions/data/models/transaction_model.dart';
import 'package:financas_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late TransactionRepositoryImpl repository;
  late MockTransactionRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockTransactionRemoteDataSource();
    repository = TransactionRepositoryImpl(remote: mockRemoteDataSource);
  });

  final tDate = DateTime.parse('2026-06-09T00:00:00.000Z');
  final tTransactionModel = TransactionModel(
    id: 'f550e061-0b86-4fb4-8975-d91d17983637',
    title: 'Uber para escritório',
    amount: 25.50,
    type: TransactionType.expense,
    categoryId: 'e229e061-0b86-4fb4-8975-d91d17983637',
    date: tDate,
    description: 'Reunião de negócios',
  );

  group('getAll', () {
    test('Deve retornar List<Transaction> quando a chamada ao DataSource for bem-sucedida', () async {
      // Arrange
      when(mockRemoteDataSource.getAll(
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).thenAnswer((_) async => [tTransactionModel]);

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result.isRight(), true);
      final list = result.getOrElse((_) => []);
      expect(list.length, 1);
      expect(list.first, tTransactionModel);
      verify(mockRemoteDataSource.getAll(startDate: null, endDate: null)).called(1);
    });

    test('Deve retornar ServerFailure quando a chamada ao DataSource lançar DioException', () async {
      // Arrange
      when(mockRemoteDataSource.getAll(
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Erro de conexão',
        ),
      );

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Erro de conexão');
        },
        (_) => fail('Deveria ter retornado Left'),
      );
    });
  });

  group('create', () {
    test('Deve retornar Transaction quando a criação for bem-sucedida', () async {
      // Arrange
      when(mockRemoteDataSource.create(any)).thenAnswer((_) async => tTransactionModel);

      // Act
      final result = await repository.create(tTransactionModel);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => throw Exception()), tTransactionModel);
    });
  });
}
