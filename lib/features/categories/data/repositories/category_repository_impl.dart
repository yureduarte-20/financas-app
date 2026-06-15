import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remote;

  CategoryRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Category>>> getAll() async {
    try {
      final models = await remote.getAll();
      return Right(models);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao buscar categorias'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> getById(String id) async {
    try {
      final model = await remote.getById(id);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao buscar categoria'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> create({
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      final model = await remote.create(name: name, icon: icon, color: color);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao criar categoria'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> update({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      final model = await remote.update(id: id, name: name, icon: icon, color: color);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao atualizar categoria'));
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
      return Left(ServerFailure(e.message ?? 'Erro de servidor ao excluir categoria'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
