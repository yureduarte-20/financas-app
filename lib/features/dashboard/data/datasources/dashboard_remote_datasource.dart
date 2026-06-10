import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary({String? startDate, String? endDate});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl(this.dio);

  @override
  Future<DashboardSummaryModel> getSummary({String? startDate, String? endDate}) async {
    final queryParameters = <String, dynamic>{};
    if (startDate != null) {
      queryParameters['start_date'] = startDate;
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate;
    }

    final response = await dio.get(
      ApiPaths.reports,
      queryParameters: queryParameters,
    );
    return DashboardSummaryModel.fromJson(response.data);
  }
}
