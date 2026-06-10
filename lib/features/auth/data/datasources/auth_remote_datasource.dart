import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<UserModel> verifyCode(String email, String code, String deviceName);
  Future<void> resendCode(String email, String type);
  Future<void> logout();
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<void> login(String email, String password) async {
    await dio.post(ApiPaths.login, data: {'email': email, 'password': password});
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await dio.post(ApiPaths.register, data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
  }

  @override
  Future<UserModel> verifyCode(String email, String code, String deviceName) async {
    final response = await dio.post(ApiPaths.verifyCode, data: {
      'email': email,
      'code': code,
      'device_name': deviceName,
    });
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> resendCode(String email, String type) async {
    await dio.post(ApiPaths.resendCode, data: {
      'email': email,
      'type': type,
    });
  }

  @override
  Future<void> logout() async {
    await dio.post(ApiPaths.logout);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await dio.get(ApiPaths.me);
    return UserModel.fromJson(response.data);
  }
}
