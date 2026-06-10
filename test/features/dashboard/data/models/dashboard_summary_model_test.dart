import 'package:flutter_test/flutter_test.dart';
import 'package:financas_app/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:financas_app/features/dashboard/domain/entities/dashboard_summary.dart';

void main() {
  final tJson = {
    "data": {
      "summary": {
        "total_income": 3500.0,
        "total_expense": 1225.5,
        "balance": 2274.5
      },
      "breakdown": [
        {
          "category_id": "a9ef52eb-5460-449e-b9ef-dcd41bb0b793",
          "category_name": "Alimentação",
          "total": 1200.0,
          "count": 4
        },
        {
          "category_id": "e229e061-0b86-4fb4-8975-d91d17983637",
          "category_name": "Transporte",
          "total": 25.5,
          "count": 1
        }
      ],
      "transactions": [
        {
          "id": "f550e061-0b86-4fb4-8975-d91d17983637",
          "name": "Uber para escritório",
          "value": "25.50",
          "type": "out",
          "expense_date": "2026-06-09T00:00:00.000000Z",
          "category_id": "e229e061-0b86-4fb4-8975-d91d17983637"
        }
      ]
    }
  };

  test('Deve ser uma subclasse de DashboardSummary', () {
    final model = DashboardSummaryModel.fromJson(tJson);
    expect(model, isA<DashboardSummary>());
  });

  test('Deve converter corretamente a partir do JSON da API', () {
    // Act
    final model = DashboardSummaryModel.fromJson(tJson);

    // Assert
    expect(model.balance, 2274.5);
    expect(model.totalIncome, 3500.0);
    expect(model.totalExpense, 1225.5);
    
    expect(model.categoryBreakdown.length, 2);
    expect(model.categoryBreakdown[0].categoryId, "a9ef52eb-5460-449e-b9ef-dcd41bb0b793");
    expect(model.categoryBreakdown[0].categoryName, "Alimentação");
    expect(model.categoryBreakdown[0].total, 1200.0);
    expect(model.categoryBreakdown[0].count, 4);
    expect(model.categoryBreakdown[0].categoryColor, isNotEmpty);

    expect(model.transactions.length, 1);
    expect(model.transactions[0].id, "f550e061-0b86-4fb4-8975-d91d17983637");
    expect(model.transactions[0].name, "Uber para escritório");
    expect(model.transactions[0].value, 25.5);
    expect(model.transactions[0].type, "out");
    expect(model.transactions[0].expenseDate, DateTime.parse("2026-06-09T00:00:00.000Z"));
    expect(model.transactions[0].categoryId, "e229e061-0b86-4fb4-8975-d91d17983637");
  });
}
