import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financas_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:financas_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:financas_app/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:financas_app/features/auth/domain/entities/user.dart';

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
  final tUser = User(id: '1', name: 'Yure Duarte', email: 'yure@test.com');
  final tDashboardSummary = DashboardSummary(
    balance: 2274.5,
    totalIncome: 3500.0,
    totalExpense: 1225.5,
    categoryBreakdown: [
      CategorySummary(
        categoryId: 'cat1',
        categoryName: 'Alimentação',
        total: 1200.0,
        count: 4,
        categoryColor: 'E57373',
      ),
    ],
    transactions: [],
  );

  testWidgets('Deve exibir CircularProgressIndicator quando o provider estiver carregando', (tester) async {
    final mockAuthNotifier = MockAuthNotifier(AuthState(status: AuthStatus.authenticated, user: tUser));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
          // Deixa o FutureProvider travado sem completar (ou retornando um Future pendente)
          dashboardSummaryProvider.overrideWith((ref) => const PendingFuture<DashboardSummary>()),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Deve exibir os dados formatados corretamente quando carregar com sucesso', (tester) async {
    final mockAuthNotifier = MockAuthNotifier(AuthState(status: AuthStatus.authenticated, user: tUser));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
          dashboardSummaryProvider.overrideWith((ref) => Future.value(tDashboardSummary)),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    // Aguarda a resolução dos futures
    await tester.pumpAndSettle();

    // Verifica saudação
    expect(find.text('Olá, Yure Duarte'), findsOneWidget);

    // Verifica saldo, receitas e despesas
    expect(find.text('Saldo Atual'), findsOneWidget);
    expect(find.text('R\$ 2274.50'), findsOneWidget);
    expect(find.text('Receitas'), findsOneWidget);
    expect(find.text('R\$ 3500.00'), findsOneWidget);
    expect(find.text('Despesas'), findsOneWidget);
    expect(find.text('R\$ 1225.50'), findsOneWidget);

    // Verifica breakdown de categoria e legenda
    expect(find.text('Distribuição por Categoria'), findsOneWidget);
    expect(find.text('Alimentação'), findsWidgets);
    expect(find.text('R\$ 1200.00 (4)'), findsOneWidget);
  });

  testWidgets('Deve exibir a mensagem de erro quando o provider falhar', (tester) async {
    final mockAuthNotifier = MockAuthNotifier(AuthState(status: AuthStatus.authenticated, user: tUser));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
          dashboardSummaryProvider.overrideWith((ref) => Future.error('Falha de conexão')),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Falha de conexão'), findsOneWidget);
  });
}

// Classe auxiliar para simular um future pendente (loading infinito) no Riverpod 2.x
class PendingFuture<T> implements Future<T> {
  const PendingFuture();

  @override
  Stream<T> asStream() => const Stream.empty();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) => this;

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) => PendingFuture<R>();

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) => this;

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) => this;
}
