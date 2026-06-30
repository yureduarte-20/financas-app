import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/constants/dimension_tokens.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_card_widget.dart';
import 'create_transaction_page.dart';
import 'edit_transaction_page.dart';
import '../../../../core/widgets/state_widgets.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        backgroundColor: ColorTokens.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(transactionListProvider.future),
        child: transactionsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'Nenhuma Transação',
                description: 'Você ainda não registrou nenhuma transação financeira.',
                actionLabel: 'Nova Transação',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateTransactionPage()),
                  );
                },
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(DimensionTokens.paddingMedium),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final transaction = list[i];
                return Dismissible(
                  key: Key(transaction.id),
                  background: Container(
                    color: ColorTokens.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: DimensionTokens.paddingLarge),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Excluir Transação'),
                        content: Text('Tem certeza que deseja excluir "${transaction.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(foregroundColor: ColorTokens.error),
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    final result = await ref.read(deleteTransactionUseCaseProvider)(id: transaction.id);
                    result.fold(
                      (failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(failure.message),
                            backgroundColor: ColorTokens.error,
                          ),
                        );
                        ref.invalidate(transactionListProvider);
                      },
                      (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transação excluída com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        ref.invalidate(transactionListProvider);
                      },
                    );
                  },
                  child: TransactionCardWidget(
                    transaction: transaction,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditTransactionPage(transaction: transaction),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => const LoadingWidget(message: 'Carregando transações...'),
          error: (e, _) => ErrorFallbackWidget(
            errorMessage: e.toString(),
            onRetry: () => ref.invalidate(transactionListProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorTokens.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
