import '../../domain/entities/user.dart';

class UserModel extends User {
  final String token;

  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json;
    return UserModel(
      id: userJson['id'].toString(),
      name: userJson['name'],
      email: userJson['email'],
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
