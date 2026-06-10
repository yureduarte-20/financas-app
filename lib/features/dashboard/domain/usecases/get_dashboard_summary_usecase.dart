import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  final DashboardRepository repository;

  GetDashboardSummaryUseCase(this.repository);

  Future<Either<Failure, DashboardSummary>> call({
    String? startDate,
    String? endDate,
  }) async {
    return repository.getSummary(startDate: startDate, endDate: endDate);
  }
}
