import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> call({DateTime? startDate, DateTime? endDate}) {
    return repository.getAll(startDate: startDate, endDate: endDate);
  }
}
