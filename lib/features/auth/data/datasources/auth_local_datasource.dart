import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final SharedPreferences prefs;

  AuthLocalDataSource(this.prefs);

  Future<void> saveToken(String token) async {
    await prefs.setString('auth_token', token);
  }

  String? getToken() {
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    await prefs.remove('auth_token');
  }
}
