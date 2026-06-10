import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:financas_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:financas_app/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:financas_app/core/constants/api_paths.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late DashboardRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUpAll(() {
    provideDummy<Response<dynamic>>(
      Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {},
      ),
    );
  });

  setUp(() {
    mockDio = MockDio();
    dataSource = DashboardRemoteDataSourceImpl(mockDio);
  });

  final tJsonResponse = {
    "data": {
      "summary": {
        "total_income": 3500.0,
        "total_expense": 1225.5,
        "balance": 2274.5
      },
      "breakdown": [
        {
          "category_id": "a9ef52eb-5460-449e-b9ef-dcd41bb0b793",
          "category_name": "Alimentação",
          "total": 1200.0,
          "count": 4
        }
      ],
      "transactions": []
    }
  };

  test('Deve realizar uma requisição GET na rota /reports com parâmetros de query adequados', () async {
    // Arrange
    when(mockDio.get(
      ApiPaths.reports,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ApiPaths.reports),
          data: tJsonResponse,
          statusCode: 200,
        ));

    // Act
    final result = await dataSource.getSummary(startDate: '2026-06-01', endDate: '2026-06-10');

    // Assert
    expect(result, isA<DashboardSummaryModel>());
    expect(result.balance, 2274.5);
    expect(result.totalIncome, 3500.0);
    expect(result.totalExpense, 1225.5);

    verify(mockDio.get(
      ApiPaths.reports,
      queryParameters: {
        'start_date': '2026-06-01',
        'end_date': '2026-06-10',
      },
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).called(1);
  });

  test('Deve lançar DioException quando a chamada ao Dio falhar', () async {
    // Arrange
    final tDioException = DioException(
      requestOptions: RequestOptions(path: ApiPaths.reports),
      response: Response(
        requestOptions: RequestOptions(path: ApiPaths.reports),
        statusCode: 401,
      ),
    );
    when(mockDio.get(
      any,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenThrow(tDioException);

    // Act
    final call = dataSource.getSummary;

    // Assert
    expect(() => call(), throwsA(isA<DioException>()));
  });
}
