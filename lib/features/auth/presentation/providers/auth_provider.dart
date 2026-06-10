import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_code_usecase.dart';
import '../../domain/usecases/resend_code_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';

enum AuthStatus { initial, loading, codeSent, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? email;
  final String? verificationType;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.email,
    this.verificationType,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? email,
    String? verificationType,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      email: email ?? this.email,
      verificationType: verificationType ?? this.verificationType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;
  final ResendCodeUseCase resendCodeUseCase;
  final LogoutUseCase logoutUseCase;
  final GetProfileUseCase getProfileUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyCodeUseCase,
    required this.resendCodeUseCase,
    required this.logoutUseCase,
    required this.getProfileUseCase,
  }) : super(AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await loginUseCase(email: email, password: password);
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
      (_) => state = state.copyWith(status: AuthStatus.codeSent, email: email, verificationType: 'api_login', errorMessage: null),
    );
  }

  Future<void> register({required String name, required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await registerUseCase(name: name, email: email, password: password);
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
      (_) => state = state.copyWith(status: AuthStatus.codeSent, email: email, verificationType: 'registration', errorMessage: null),
    );
  }

  Future<void> verifyCode({required String code, required String deviceName}) async {
    if (state.email == null) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'E-mail não encontrado para verificação');
      return;
    }
    final emailSalvo = state.email!;
    state = state.copyWith(status: AuthStatus.loading);
    
    final result = await verifyCodeUseCase(email: emailSalvo, code: code, deviceName: deviceName);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null),
    );
  }

  Future<void> resendCode() async {
    if (state.email == null) return;
    await resendCodeUseCase(email: state.email!, type: state.verificationType ?? 'api_login');
  }

  Future<void> cancelVerification() async {
    state = state.copyWith(status: AuthStatus.unauthenticated, email: null, verificationType: null, errorMessage: null);
  }

  Future<void> logout() async {
    await logoutUseCase();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null, email: null, errorMessage: null);
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await getProfileUseCase();
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.unauthenticated, user: null, errorMessage: null),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null),
    );
  }
}

