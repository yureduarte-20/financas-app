import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getAll({DateTime? startDate, DateTime? endDate});
  Future<TransactionModel> getById(String id);
  Future<TransactionModel> create(TransactionModel transaction);
  Future<TransactionModel> update(TransactionModel transaction);
  Future<void> delete(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final Dio dio;

  TransactionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TransactionModel>> getAll({DateTime? startDate, DateTime? endDate}) async {
    final params = <String, dynamic>{};
    if (startDate != null) {
      params['start_date'] = startDate.toIso8601String().substring(0, 10);
    }
    if (endDate != null) {
      params['end_date'] = endDate.toIso8601String().substring(0, 10);
    }

    final response = await dio.get(ApiPaths.transactions, queryParameters: params);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((j) => TransactionModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TransactionModel> getById(String id) async {
    final response = await dio.get('${ApiPaths.transactions}/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  @override
  Future<TransactionModel> create(TransactionModel transaction) async {
    final response = await dio.post(
      ApiPaths.transactions,
      data: transaction.toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  @override
  Future<TransactionModel> update(TransactionModel transaction) async {
    final response = await dio.put(
      '${ApiPaths.transactions}/${transaction.id}',
      data: transaction.toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await dio.delete('${ApiPaths.transactions}/$id');
  }
}
