import 'package:financas_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:financas_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:financas_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:financas_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:financas_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:financas_app/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:financas_app/features/auth/domain/usecases/resend_code_usecase.dart';
import 'package:financas_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:financas_app/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:financas_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:financas_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';

@GenerateMocks([
  AuthRepository,
  AuthRemoteDataSource,
  AuthLocalDataSource,
  LoginUseCase,
  RegisterUseCase,
  VerifyCodeUseCase,
  ResendCodeUseCase,
  LogoutUseCase,
  GetProfileUseCase,
  DashboardRepository,
  DashboardRemoteDataSource,
  Dio,
])
void main() {}

