import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remote;

  TransactionRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Transaction>>> getAll({DateTime? startDate, DateTime? endDate}) async {
    try {
      final models = await remote.getAll(startDate: startDate, endDate: endDate);
      return Right(models);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao buscar transações'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getById(String id) async {
    try {
      final model = await remote.getById(id);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao buscar transação'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> create(Transaction transaction) async {
    try {
      final model = TransactionModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        categoryId: transaction.categoryId,
        date: transaction.date,
        description: transaction.description,
      );
      final created = await remote.create(model);
      return Right(created);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao criar transação'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> update(Transaction transaction) async {
    try {
      final model = TransactionModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        categoryId: transaction.categoryId,
        date: transaction.date,
        description: transaction.description,
      );
      final updated = await remote.update(model);
      return Right(updated);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao atualizar transação'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await remote.delete(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao excluir transação'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getBalance() async {
    try {
      final result = await remote.getAll();
      double balance = 0.0;
      for (final t in result) {
        if (t.type == TransactionType.income) {
          balance += t.amount;
        } else {
          balance -= t.amount;
        }
      }
      return Right(balance);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao calcular saldo'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
