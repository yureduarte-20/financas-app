import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:financas_app/core/errors/failures.dart';
import 'package:financas_app/features/categories/domain/entities/category.dart';
import 'package:financas_app/features/categories/domain/usecases/create_category_usecase.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late CreateCategoryUseCase usecase;
  late MockCategoryRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<Failure, Category>>(Left(ServerFailure('')));
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    usecase = CreateCategoryUseCase(mockRepository);
  });

  const tCategory = Category(
    id: '1',
    name: 'Alimentação',
    icon: 'restaurant',
    color: 'E57373',
  );

  test('Deve retornar ValidationFailure se o nome estiver vazio', () async {
    // Act
    final result = await usecase(name: '', icon: 'restaurant', color: 'E57373');

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Nome da categoria obrigatório');
      },
      (_) => fail('Deveria ter retornado uma falha'),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('Deve chamar o repository.create e retornar Category em caso de sucesso', () async {
    // Arrange
    when(mockRepository.create(
      name: anyNamed('name'),
      icon: anyNamed('icon'),
      color: anyNamed('color'),
    )).thenAnswer((_) async => const Right(tCategory));

    // Act
    final result = await usecase(name: 'Alimentação', icon: 'restaurant', color: 'E57373');

    // Assert
    expect(result, const Right(tCategory));
    verify(mockRepository.create(name: 'Alimentação', icon: 'restaurant', color: 'E57373')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
