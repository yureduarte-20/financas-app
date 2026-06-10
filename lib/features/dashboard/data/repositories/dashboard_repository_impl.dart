import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DashboardSummary>> getSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final summaryModel = await remoteDataSource.getSummary(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(summaryModel);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data['message'] ?? e.message ?? 'Erro desconhecido ao carregar relatório',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
