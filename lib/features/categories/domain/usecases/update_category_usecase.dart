import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Either<Failure, Category>> call({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) async {
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('Nome da categoria obrigatório'));
    }
    return repository.update(id: id, name: name, icon: icon, color: color);
  }
}
