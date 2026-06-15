import 'package:flutter/material.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/constants/dimension_tokens.dart';
import '../../domain/entities/transaction.dart';

class TransactionCardWidget extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? ColorTokens.income : ColorTokens.expense;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: DimensionTokens.paddingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(26), // 10% soft opacity
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Text(
          '${isIncome ? "+" : "-"} R\$ ${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
