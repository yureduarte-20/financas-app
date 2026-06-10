import '../../domain/entities/dashboard_summary.dart';

class CategorySummaryModel extends CategorySummary {
  CategorySummaryModel({
    required super.categoryId,
    required super.categoryName,
    required super.total,
    required super.count,
    required super.categoryColor,
  });

  factory CategorySummaryModel.fromJson(Map<String, dynamic> json) {
    final categoryId = json['category_id'] as String? ?? '';
    return CategorySummaryModel(
      categoryId: categoryId,
      categoryName: json['category_name'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
      categoryColor: _getColorForCategory(categoryId),
    );
  }

  static const List<String> _presetColors = [
    'E57373', // Light Red
    '81C784', // Light Green
    '64B5F6', // Light Blue
    'BA68C8', // Light Purple
    'FFD54F', // Light Yellow
    'F06292', // Light Pink
    '4DD0E1', // Light Cyan
    'FFB74D', // Light Orange
    'A1887F', // Light Brown
    '90A4AE', // Light Blue Grey
  ];

  static String _getColorForCategory(String categoryId) {
    if (categoryId.isEmpty) return '90A4AE';
    final index = categoryId.hashCode.abs() % _presetColors.length;
    return _presetColors[index];
  }
}

class DashboardTransactionModel extends DashboardTransaction {
  DashboardTransactionModel({
    required super.id,
    required super.name,
    required super.value,
    required super.type,
    required super.expenseDate,
    required super.categoryId,
  });

  factory DashboardTransactionModel.fromJson(Map<String, dynamic> json) {
    return DashboardTransactionModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      value: double.tryParse(json['value'].toString()) ?? 0.0,
      type: json['type'] as String? ?? 'out',
      expenseDate: json['expense_date'] != null
          ? DateTime.parse(json['expense_date'] as String)
          : DateTime.now(),
      categoryId: json['category_id'] as String? ?? '',
    );
  }
}

class DashboardSummaryModel extends DashboardSummary {
  DashboardSummaryModel({
    required super.balance,
    required super.totalIncome,
    required super.totalExpense,
    required super.categoryBreakdown,
    required super.transactions,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    final breakdownJson = data['breakdown'] as List<dynamic>? ?? [];
    final transactionsJson = data['transactions'] as List<dynamic>? ?? [];

    final categoryBreakdown = breakdownJson
        .map((item) => CategorySummaryModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final transactions = transactionsJson
        .map((item) => DashboardTransactionModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return DashboardSummaryModel(
      balance: (summary['balance'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (summary['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (summary['total_expense'] as num?)?.toDouble() ?? 0.0,
      categoryBreakdown: categoryBreakdown,
      transactions: transactions,
    );
  }
}
