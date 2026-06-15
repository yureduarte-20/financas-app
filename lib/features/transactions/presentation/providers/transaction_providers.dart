import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';

final transactionRemoteDataSourceProvider = Provider<TransactionRemoteDataSource>((ref) {
  return TransactionRemoteDataSourceImpl(ref.read(dioProvider));
});

final transactionRepositoryProvider = Provider((ref) {
  return TransactionRepositoryImpl(remote: ref.read(transactionRemoteDataSourceProvider));
});

final getTransactionsUseCaseProvider = Provider((ref) {
  return GetTransactionsUseCase(ref.read(transactionRepositoryProvider));
});

final createTransactionUseCaseProvider = Provider((ref) {
  return CreateTransactionUseCase(ref.read(transactionRepositoryProvider));
});

final updateTransactionUseCaseProvider = Provider((ref) {
  return UpdateTransactionUseCase(ref.read(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider((ref) {
  return DeleteTransactionUseCase(ref.read(transactionRepositoryProvider));
});

final transactionListProvider = FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final useCase = ref.read(getTransactionsUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw failure,
    (list) => list,
  );
});
