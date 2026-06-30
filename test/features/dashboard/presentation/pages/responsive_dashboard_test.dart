import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financas_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:financas_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:financas_app/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:financas_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:financas_app/features/auth/domain/entities/user.dart';
import 'package:financas_app/features/transactions/domain/entities/transaction.dart';
import 'package:financas_app/features/transactions/presentation/widgets/transaction_card_widget.dart';

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

  testWidgets('Deve conter marcacoes de Semantics no TransactionCardWidget', (tester) async {
    final transaction = Transaction(
      id: 'tx1',
      title: 'Supermercado',
      amount: 120.50,
      type: TransactionType.expense,
      categoryId: 'cat1',
      date: DateTime(2026, 6, 30),
      description: 'Compra do mês',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionCardWidget(
            transaction: transaction,
            onTap: () {},
          ),
        ),
      ),
    );

    // Encontra o widget Semantics
    final semanticsFinder = find.byType(Semantics);
    expect(semanticsFinder, findsAtLeastNWidgets(1));

    // Verifica se a label semântica unificada está presente
    final semantics = tester.getSemantics(find.byType(Card));
    expect(semantics.label, contains('Transação: Supermercado'));
    expect(semantics.label, contains('Tipo: Despesa'));
    expect(semantics.label, contains('Valor: 120.50 reais'));
    expect(semantics.label, contains('Data: 30 de 6 de 2026'));
  });

  testWidgets('Deve renderizar layout adequado em tela larga (>= 600px)', (tester) async {
    // Configura tamanho de tela larga
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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

    await tester.pumpAndSettle();

    // Em tela larga, os cards de Saldo, Receitas e Despesas devem estar dispostos horizontalmente em uma Row.
    expect(find.byType(Row), findsAtLeastNWidgets(2));
  });
}
