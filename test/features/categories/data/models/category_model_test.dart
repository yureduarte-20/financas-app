import 'package:flutter_test/flutter_test.dart';
import 'package:financas_app/features/categories/domain/entities/category.dart';
import 'package:financas_app/features/categories/data/models/category_model.dart';

void main() {
  const tCategoryModel = CategoryModel(
    id: '123',
    name: 'Saúde',
    icon: 'medical_services',
    color: '81C784',
  );

  test('Deve ser uma subclasse de Category', () {
    expect(tCategoryModel, isA<Category>());
  });

  group('fromJson', () {
    test('Deve instanciar corretamente CategoryModel a partir de um JSON válido', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': '123',
        'name': 'Saúde',
        'icon': 'medical_services',
        'color': '81C784',
      };

      // Act
      final result = CategoryModel.fromJson(jsonMap);

      // Assert
      expect(result.id, '123');
      expect(result.name, 'Saúde');
      expect(result.icon, 'medical_services');
      expect(result.color, '81C784');
    });

    test('Deve usar valores padrão se icon ou color forem nulos', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': '123',
        'name': 'Saúde',
      };

      // Act
      final result = CategoryModel.fromJson(jsonMap);

      // Assert
      expect(result.id, '123');
      expect(result.name, 'Saúde');
      expect(result.icon, 'category');
      expect(result.color, '6C63FF');
    });
  });

  group('toJson', () {
    test('Deve retornar um Map contendo as propriedades corretas', () {
      // Act
      final result = tCategoryModel.toJson();

      // Assert
      final expectedMap = {
        'name': 'Saúde',
        'icon': 'medical_services',
        'color': '81C784',
      };
      expect(result, expectedMap);
    });
  });
}
