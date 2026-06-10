import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financas_app/features/auth/presentation/pages/verification_page.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_providers.dart';

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
  late var getProfileUseCase;

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

  @override
  Future<void> checkAuthStatus() async {}
}

void main() {
  testWidgets('Deve restringir a confirmação caso o código não tenha exatamente 6 dígitos', (tester) async {
    final mockNotifier = MockAuthNotifier(AuthState(status: AuthStatus.codeSent, email: 'test@test.com'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockNotifier),
        ],
        child: const MaterialApp(home: VerificationPage()),
      ),
    );

    // Tentar enviar vazio
    await tester.tap(find.text('VERIFICAR'));
    await tester.pump();
    expect(find.text('O código deve ter 6 dígitos'), findsOneWidget);

    // Tentar enviar com 3 digitos
    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.text('VERIFICAR'));
    await tester.pump();
    expect(find.text('O código deve ter 6 dígitos'), findsOneWidget);
  });
}
