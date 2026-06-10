class CategorySummary {
  final String categoryId;
  final String categoryName;
  final double total;
  final int count;
  final String categoryColor;

  CategorySummary({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.count,
    required this.categoryColor,
  });
}

class DashboardTransaction {
  final String id;
  final String name;
  final double value;
  final String type;
  final DateTime expenseDate;
  final String categoryId;

  DashboardTransaction({
    required this.id,
    required this.name,
    required this.value,
    required this.type,
    required this.expenseDate,
    required this.categoryId,
  });
}

class DashboardSummary {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final List<CategorySummary> categoryBreakdown;
  final List<DashboardTransaction> transactions;

  DashboardSummary({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryBreakdown,
    required this.transactions,
  });
}
