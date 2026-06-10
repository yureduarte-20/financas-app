import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';
  static int get apiTimeout => int.parse(dotenv.env['API_TIMEOUT'] ?? '5000');
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
}
