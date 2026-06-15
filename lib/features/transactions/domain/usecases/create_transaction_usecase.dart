import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<Either<Failure, Transaction>> call({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? description,
  }) async {
    if (title.trim().isEmpty) {
      return Left(ValidationFailure('Título obrigatório'));
    }
    if (amount <= 0) {
      return Left(ValidationFailure('Valor deve ser maior que zero'));
    }
    if (categoryId.trim().isEmpty) {
      return Left(ValidationFailure('Categoria obrigatória'));
    }

    final transaction = Transaction(
      id: '',
      title: title.trim(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      description: description,
    );

    return repository.create(transaction);
  }
}
