import 'package:flutter_test/flutter_test.dart';
import 'package:financas_app/features/auth/data/models/user_model.dart';
import 'package:financas_app/features/auth/domain/entities/user.dart';

void main() {
  final tUserModel = UserModel(
    id: '1',
    name: 'Test',
    email: 'test@test.com',
    token: 'jwt_token_123',
  );

  test('Deve ser uma subclasse de User', () {
    expect(tUserModel, isA<User>());
  });

  test('Deve retornar um modelo válido quando o JSON tiver o objeto user aninhado', () {
    final Map<String, dynamic> jsonMap = {
      'user': {
        'id': 1,
        'name': 'Test',
        'email': 'test@test.com',
      },
      'token': 'jwt_token_123',
    };

    final result = UserModel.fromJson(jsonMap);

    expect(result.id, '1');
    expect(result.name, 'Test');
    expect(result.token, 'jwt_token_123');
  });
}
