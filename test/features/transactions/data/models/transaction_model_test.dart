import 'package:flutter_test/flutter_test.dart';
import 'package:financas_app/features/transactions/domain/entities/transaction.dart';
import 'package:financas_app/features/transactions/data/models/transaction_model.dart';

void main() {
  final tDate = DateTime.parse('2026-06-09T00:00:00.000Z');
  final tTransactionModel = TransactionModel(
    id: 'f550e061-0b86-4fb4-8975-d91d17983637',
    title: 'Uber para escritório',
    amount: 25.50,
    type: TransactionType.expense,
    categoryId: 'e229e061-0b86-4fb4-8975-d91d17983637',
    date: tDate,
    description: 'Reunião de negócios',
  );

  test('Deve ser uma subclasse de Transaction', () {
    expect(tTransactionModel, isA<Transaction>());
  });

  group('fromJson', () {
    test('Deve instanciar corretamente TransactionModel a partir do JSON da API (que usa name, value, expense_date e out/income)', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'f550e061-0b86-4fb4-8975-d91d17983637',
        'name': 'Uber para escritório',
        'value': '25.50',
        'type': 'out',
        'expense_date': '2026-06-09T00:00:00.000000Z',
        'category_id': 'e229e061-0b86-4fb4-8975-d91d17983637',
        'description': 'Reunião de negócios',
      };

      // Act
      final result = TransactionModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'f550e061-0b86-4fb4-8975-d91d17983637');
      expect(result.title, 'Uber para escritório');
      expect(result.amount, 25.50);
      expect(result.type, TransactionType.expense);
      expect(result.categoryId, 'e229e061-0b86-4fb4-8975-d91d17983637');
      expect(result.date, DateTime.parse('2026-06-09T00:00:00.000000Z'));
      expect(result.description, 'Reunião de negócios');
    });

    test('Deve instanciar corretamente usando chaves fallback do specs.md (title, amount, date, income/expense)', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'f550e061-0b86-4fb4-8975-d91d17983637',
        'title': 'Uber para escritório',
        'amount': 25.50,
        'type': 'expense',
        'date': '2026-06-09T00:00:00.000000Z',
        'category_id': 'e229e061-0b86-4fb4-8975-d91d17983637',
        'description': 'Reunião de negócios',
      };

      // Act
      final result = TransactionModel.fromJson(jsonMap);

      // Assert
      expect(result.title, 'Uber para escritório');
      expect(result.amount, 25.50);
      expect(result.type, TransactionType.expense);
    });
  });

  group('toJson', () {
    test('Deve retornar um Map contendo as chaves corretas para a API e fallback', () {
      // Act
      final result = tTransactionModel.toJson();

      // Assert
      expect(result['name'], 'Uber para escritório');
      expect(result['title'], 'Uber para escritório');
      expect(result['value'], 25.50);
      expect(result['amount'], 25.50);
      expect(result['type'], 'out');
      expect(result['category_id'], 'e229e061-0b86-4fb4-8975-d91d17983637');
      expect(result['expense_date'], '2026-06-09');
      expect(result['description'], 'Reunião de negócios');
    });
  });
}
