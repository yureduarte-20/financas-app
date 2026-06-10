import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:financas_app/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financas_app/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:financas_app/core/errors/failures.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late GetDashboardSummaryUseCase usecase;
  late MockDashboardRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<Failure, DashboardSummary>>(Left(ServerFailure('')));
  });

  setUp(() {
    mockRepository = MockDashboardRepository();
    usecase = GetDashboardSummaryUseCase(mockRepository);
  });

  final tDashboardSummary = DashboardSummary(
    balance: 2274.5,
    totalIncome: 3500.0,
    totalExpense: 1225.5,
    categoryBreakdown: [
      CategorySummary(
        categoryId: 'a9ef52eb-5460-449e-b9ef-dcd41bb0b793',
        categoryName: 'Alimentação',
        total: 1200.0,
        count: 4,
        categoryColor: 'a9ef52eb',
      ),
    ],
    transactions: [
      DashboardTransaction(
        id: 'f550e061-0b86-4fb4-8975-d91d17983637',
        name: 'Uber para escritório',
        value: 25.5,
        type: 'out',
        expenseDate: DateTime.parse('2026-06-09T00:00:00.000Z'),
        categoryId: 'e229e061-0b86-4fb4-8975-d91d17983637',
      ),
    ],
  );

  test('Deve chamar repository.getSummary() e retornar DashboardSummary em caso de sucesso', () async {
    // Arrange
    when(mockRepository.getSummary(startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
        .thenAnswer((_) async => Right(tDashboardSummary));

    // Act
    final result = await usecase(startDate: '2026-06-01', endDate: '2026-06-10');

    // Assert
    expect(result, Right(tDashboardSummary));
    verify(mockRepository.getSummary(startDate: '2026-06-01', endDate: '2026-06-10')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('Deve retornar Failure quando a chamada ao repositório falhar', () async {
    // Arrange
    when(mockRepository.getSummary(startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
        .thenAnswer((_) async => Left(ServerFailure('Erro no servidor')));

    // Act
    final result = await usecase();

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Erro no servidor');
      },
      (_) => fail('Deveria ter retornado uma falha'),
    );
    verify(mockRepository.getSummary(startDate: null, endDate: null)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
