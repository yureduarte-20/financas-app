import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_code_usecase.dart';
import '../../domain/usecases/resend_code_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'auth_provider.dart';

// Este provider precisará ser sobreescrito no ProviderScope (main.dart) 
// pois a inicialização do SharedPreferences é assíncrona.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final dioProvider = Provider((ref) => DioClient().instance);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(dioProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.read(sharedPreferencesProvider));
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(
    remote: ref.read(authRemoteDataSourceProvider),
    local: ref.read(authLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.read(authRepositoryProvider)));
final registerUseCaseProvider = Provider((ref) => RegisterUseCase(ref.read(authRepositoryProvider)));
final verifyCodeUseCaseProvider = Provider((ref) => VerifyCodeUseCase(ref.read(authRepositoryProvider)));
final resendCodeUseCaseProvider = Provider((ref) => ResendCodeUseCase(ref.read(authRepositoryProvider)));
final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(ref.read(authRepositoryProvider)));
final getProfileUseCaseProvider = Provider((ref) => GetProfileUseCase(ref.read(authRepositoryProvider)));

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.read(loginUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
    verifyCodeUseCase: ref.read(verifyCodeUseCaseProvider),
    resendCodeUseCase: ref.read(resendCodeUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
  );
});
