import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAll();
  Future<Either<Failure, Category>> getById(String id);
  Future<Either<Failure, Category>> create({
    required String name,
    required String icon,
    required String color,
  });
  Future<Either<Failure, Category>> update({
    required String id,
    required String name,
    required String icon,
    required String color,
  });
  Future<Either<Failure, void>> delete(String id);
}
