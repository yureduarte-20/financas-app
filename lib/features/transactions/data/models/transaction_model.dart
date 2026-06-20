import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.categoryId,
    required super.date,
    super.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String? ?? 'out';
    final parsedType = rawType == 'income'
        ? TransactionType.income
        : TransactionType.expense;

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      title: (json['name'] ?? json['title']) as String? ?? '',
      amount:
          double.tryParse((json['value'] ?? json['amount'] ?? 0).toString()) ??
          0.0,
      type: parsedType,
      categoryId: (json['category_id'] ?? json['categoryId'])?.toString() ?? '',
      date: json['expense_date'] != null
          ? DateTime.parse(json['expense_date'] as String)
          : json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': title,
      'title': title,
      'value': amount,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'out',
      'category_id': categoryId,
      'expense_date': date.toIso8601String().substring(
        0,
        10,
      ), // Send YYYY-MM-DD
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
