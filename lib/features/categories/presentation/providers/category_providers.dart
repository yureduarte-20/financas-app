import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSourceImpl(ref.read(dioProvider));
});

final categoryRepositoryProvider = Provider((ref) {
  return CategoryRepositoryImpl(remote: ref.read(categoryRemoteDataSourceProvider));
});

final getCategoriesUseCaseProvider = Provider((ref) {
  return GetCategoriesUseCase(ref.read(categoryRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider((ref) {
  return CreateCategoryUseCase(ref.read(categoryRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider((ref) {
  return UpdateCategoryUseCase(ref.read(categoryRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider((ref) {
  return DeleteCategoryUseCase(ref.read(categoryRepositoryProvider));
});

final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.read(getCategoriesUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw failure,
    (list) => list,
  );
});
