import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/constants/dimension_tokens.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../categories/presentation/pages/categories_page.dart';
import '../../../transactions/presentation/pages/transactions_page.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${authState.user?.name ?? ''}'),
        backgroundColor: ColorTokens.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: ColorTokens.primary,
              ),
              accountName: Text(
                authState.user?.name ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(authState.user?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: ColorTokens.primary, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: ColorTokens.primary),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: ColorTokens.primary),
              title: const Text('Transações'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TransactionsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: ColorTokens.primary),
              title: const Text('Categorias'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: ColorTokens.error),
              title: const Text('Sair'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardSummaryProvider.future),
        child: summaryAsync.when(
          data: (summary) {
            return ListView(
              padding: const EdgeInsets.all(DimensionTokens.paddingMedium),
              children: [
                // Card Saldo
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(DimensionTokens.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Saldo Atual',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${summary.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: summary.balance >= 0
                                ? ColorTokens.income
                                : ColorTokens.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DimensionTokens.paddingMedium),
                // Row Receita / Despesa
                Row(
                  children: [
                    Expanded(
                      child: _buildTile(
                        'Receitas',
                        summary.totalIncome,
                        ColorTokens.income,
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: DimensionTokens.paddingSmall),
                    Expanded(
                      child: _buildTile(
                        'Despesas',
                        summary.totalExpense,
                        ColorTokens.expense,
                        Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DimensionTokens.paddingLarge),
                // Seção de gráfico
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(DimensionTokens.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Distribuição por Categoria',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: DimensionTokens.paddingLarge),
                        if (summary.categoryBreakdown.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: DimensionTokens.paddingLarge,
                              ),
                              child: Text(
                                'Nenhuma transação registrada.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else ...[
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: summary.categoryBreakdown.map((cs) {
                                  return PieChartSectionData(
                                    value: cs.total,
                                    title: cs.categoryName,
                                    color: Color(int.parse('0xFF${cs.categoryColor}')),
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: DimensionTokens.paddingMedium),
                          // Legenda
                          ...summary.categoryBreakdown.map((cs) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse('0xFF${cs.categoryColor}')),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    cs.categoryName,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'R\$ ${cs.total.toStringAsFixed(2)} (${cs.count})',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Erro ao carregar dashboard: $err',
              style: const TextStyle(color: ColorTokens.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String title, double value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DimensionTokens.paddingMedium),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(26), // soft background (approx. 10% opacity)
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
