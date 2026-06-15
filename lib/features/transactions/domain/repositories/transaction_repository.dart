import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getAll({DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, Transaction>> getById(String id);
  Future<Either<Failure, Transaction>> create(Transaction transaction);
  Future<Either<Failure, Transaction>> update(Transaction transaction);
  Future<Either<Failure, void>> delete(String id);
  Future<Either<Failure, double>> getBalance();
}
