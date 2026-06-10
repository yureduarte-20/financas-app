import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financas_app/features/auth/presentation/pages/login_page.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:mockito/mockito.dart';

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier(super.state);

  @override
  late var loginUseCase;
  @override
  late var registerUseCase;
  @override
  late var verifyCodeUseCase;
  @override
  late var resendCodeUseCase;
  @override
  late var logoutUseCase;

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> register({required String name, required String email, required String password}) async {}

  @override
  Future<void> verifyCode({required String code, required String deviceName}) async {}

  @override
  Future<void> resendCode() async {}

  @override
  Future<void> cancelVerification() async {}

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('Deve exibir mensagem de erro no TextFormField ao tentar enviar o formulário vazio', (tester) async {
    final mockNotifier = MockAuthNotifier(AuthState());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockNotifier),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.tap(find.text('ENTRAR'));
    await tester.pump();

    expect(find.text('E-mail inválido'), findsOneWidget);
    expect(find.text('Mínimo de 6 caracteres'), findsOneWidget);
  });

  testWidgets('Deve exibir um CircularProgressIndicator caso o AuthState.status seja loading', (tester) async {
    final mockNotifier = MockAuthNotifier(AuthState(status: AuthStatus.loading));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockNotifier),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('ENTRAR'), findsNothing);
  });
}
