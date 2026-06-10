import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:financas_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:financas_app/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:financas_app/core/errors/failures.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    provideDummy<DashboardSummaryModel>(
      DashboardSummaryModel(
        balance: 0,
        totalIncome: 0,
        totalExpense: 0,
        categoryBreakdown: [],
        transactions: [],
      ),
    );
  });

  setUp(() {
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    repository = DashboardRepositoryImpl(mockRemoteDataSource);
  });

  final tSummaryModel = DashboardSummaryModel(
    balance: 200.0,
    totalIncome: 500.0,
    totalExpense: 300.0,
    categoryBreakdown: [],
    transactions: [],
  );

  test('Deve retornar Right(DashboardSummary) quando o DataSource retornar com sucesso', () async {
    // Arrange
    when(mockRemoteDataSource.getSummary(startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
        .thenAnswer((_) async => tSummaryModel);

    // Act
    final result = await repository.getSummary(startDate: '2026-06-01', endDate: '2026-06-10');

    // Assert
    expect(result, Right(tSummaryModel));
    verify(mockRemoteDataSource.getSummary(startDate: '2026-06-01', endDate: '2026-06-10')).called(1);
    verifyNoMoreInteractions(mockRemoteDataSource);
  });

  test('Deve retornar Left(ServerFailure) quando o DataSource remoto lançar DioException', () async {
    // Arrange
    final tException = DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 500,
        data: {'message': 'Erro interno do servidor'},
      ),
    );
    when(mockRemoteDataSource.getSummary(startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
        .thenThrow(tException);

    // Act
    final result = await repository.getSummary();

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Erro interno do servidor');
      },
      (_) => fail('Deveria retornar uma falha'),
    );
    verify(mockRemoteDataSource.getSummary(startDate: null, endDate: null)).called(1);
    verifyNoMoreInteractions(mockRemoteDataSource);
  });

  test('Deve retornar Left(ServerFailure) quando ocorrer um erro genérico', () async {
    // Arrange
    when(mockRemoteDataSource.getSummary(startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
        .thenThrow(Exception('Erro de conexão'));

    // Act
    final result = await repository.getSummary();

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('Erro de conexão'));
      },
      (_) => fail('Deveria retornar uma falha'),
    );
  });
}
