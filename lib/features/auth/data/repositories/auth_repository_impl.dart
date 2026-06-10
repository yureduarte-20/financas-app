import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, void>> login({required String email, required String password}) async {
    try {
      await remote.login(email, password);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message ?? 'Erro desconhecido'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> register({required String name, required String email, required String password}) async {
    try {
      await remote.register(name, email, password);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message ?? 'Erro desconhecido'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyCode({required String email, required String code, required String deviceName}) async {
    try {
      final userModel = await remote.verifyCode(email, code, deviceName);
      await local.saveToken(userModel.token);
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message ?? 'Erro desconhecido'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendCode({required String email, required String type}) async {
    try {
      await remote.resendCode(email, type);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message ?? 'Erro desconhecido'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remote.logout();
      await local.clearToken();
      return const Right(null);
    } on DioException catch (e) {
      // Mesmo com erro na API, é bom limpar o token local
      await local.clearToken();
      return Left(ServerFailure(e.response?.data['message'] ?? e.message ?? 'Erro desconhecido'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    final token = local.getToken();
    if (token == null || token.isEmpty) {
      return Left(CacheFailure('Token não encontrado'));
    }
    try {
      final userModel = await remote.getProfile();
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message ?? 'Erro desconhecido'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
