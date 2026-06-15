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
import 'package:financas_app/features/categories/domain/repositories/category_repository.dart';
import 'package:financas_app/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financas_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financas_app/features/transactions/data/datasources/transaction_remote_datasource.dart';

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
  CategoryRepository,
  CategoryRemoteDataSource,
  TransactionRepository,
  TransactionRemoteDataSource,
  Dio,
])
void main() {}

