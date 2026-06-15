import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:financas_app/core/errors/failures.dart';
import 'package:financas_app/features/transactions/domain/entities/transaction.dart';
import 'package:financas_app/features/transactions/domain/usecases/create_transaction_usecase.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late CreateTransactionUseCase usecase;
  late MockTransactionRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<Failure, Transaction>>(Left(ServerFailure('')));
  });

  setUp(() {
    mockRepository = MockTransactionRepository();
    usecase = CreateTransactionUseCase(mockRepository);
  });

  final tDate = DateTime.parse('2026-06-09T00:00:00.000Z');
  final tTransaction = Transaction(
    id: 'f550e061-0b86-4fb4-8975-d91d17983637',
    title: 'Uber para escritório',
    amount: 25.50,
    type: TransactionType.expense,
    categoryId: 'e229e061-0b86-4fb4-8975-d91d17983637',
    date: tDate,
    description: 'Reunião de negócios',
  );

  test('Deve retornar ValidationFailure se o título estiver vazio', () async {
    // Act
    final result = await usecase(
      title: '',
      amount: 25.50,
      type: TransactionType.expense,
      categoryId: 'e229e061-0b86-4fb4-8975-d91d17983637',
      date: tDate,
    );

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Título obrigatório');
      },
      (_) => fail('Deveria ter falhado'),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('Deve retornar ValidationFailure se o valor for menor ou igual a zero', () async {
    // Act
    final result = await usecase(
      title: 'Uber para escritório',
      amount: 0.0,
      type: TransactionType.expense,
      categoryId: 'e229e061-0b86-4fb4-8975-d91d17983637',
      date: tDate,
    );

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Valor deve ser maior que zero');
      },
      (_) => fail('Deveria ter falhado'),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('Deve retornar ValidationFailure se o categoryId estiver vazio', () async {
    // Act
    final result = await usecase(
      title: 'Uber para escritório',
      amount: 25.50,
      type: TransactionType.expense,
      categoryId: '',
      date: tDate,
    );

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Categoria obrigatória');
      },
      (_) => fail('Deveria ter falhado'),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('Deve chamar o repository.create e retornar Transaction em caso de sucesso', () async {
    // Arrange
    when(mockRepository.create(any)).thenAnswer((_) async => Right(tTransaction));

    // Act
    final result = await usecase(
      title: 'Uber para escritório',
      amount: 25.50,
      type: TransactionType.expense,
      categoryId: 'e229e061-0b86-4fb4-8975-d91d17983637',
      date: tDate,
      description: 'Reunião de negócios',
    );

    // Assert
    expect(result.isRight(), true);
    expect(result.getOrElse((_) => throw Exception()), tTransaction);
    verify(mockRepository.create(any)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
