import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;

  AuthInterceptor(this.localDataSource);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = localDataSource.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      localDataSource.clearToken();
      // O redirecionamento será gerenciado por um listen global ou Navigator
    }
    handler.next(err);
  }
}
