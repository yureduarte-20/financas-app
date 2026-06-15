import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:financas_app/core/errors/failures.dart';
import 'package:financas_app/features/categories/data/models/category_model.dart';
import 'package:financas_app/features/categories/data/repositories/category_repository_impl.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockCategoryRemoteDataSource();
    repository = CategoryRepositoryImpl(remote: mockRemoteDataSource);
  });

  const tCategoryModel = CategoryModel(
    id: '123',
    name: 'Alimentação',
    icon: 'restaurant',
    color: 'E57373',
  );

  group('getAll', () {
    test('Deve retornar List<Category> quando a chamada ao DataSource for bem-sucedida', () async {
      // Arrange
      when(mockRemoteDataSource.getAll()).thenAnswer((_) async => [tCategoryModel]);

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result.isRight(), true);
      final list = result.getOrElse((_) => []);
      expect(list.length, 1);
      expect(list.first, tCategoryModel);
      verify(mockRemoteDataSource.getAll()).called(1);
    });

    test('Deve retornar ServerFailure quando a chamada ao DataSource lançar DioException', () async {
      // Arrange
      when(mockRemoteDataSource.getAll()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Erro de conexão',
        ),
      );

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Erro de conexão');
        },
        (_) => fail('Deveria ter retornado Left'),
      );
      verify(mockRemoteDataSource.getAll()).called(1);
    });
  });

  group('create', () {
    test('Deve retornar Category quando a criação for bem-sucedida', () async {
      // Arrange
      when(mockRemoteDataSource.create(
        name: anyNamed('name'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      )).thenAnswer((_) async => tCategoryModel);

      // Act
      final result = await repository.create(name: 'Alimentação', icon: 'restaurant', color: 'E57373');

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => throw Exception()), tCategoryModel);
      verify(mockRemoteDataSource.create(name: 'Alimentação', icon: 'restaurant', color: 'E57373')).called(1);
    });

    test('Deve retornar ServerFailure ao falhar na criação', () async {
      // Arrange
      when(mockRemoteDataSource.create(
        name: anyNamed('name'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Erro ao criar',
        ),
      );

      // Act
      final result = await repository.create(name: 'Alimentação', icon: 'restaurant', color: 'E57373');

      // Assert
      expect(result.isLeft(), true);
      verify(mockRemoteDataSource.create(name: 'Alimentação', icon: 'restaurant', color: 'E57373')).called(1);
    });
  });
}
