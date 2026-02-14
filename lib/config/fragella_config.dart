import 'package:flutter_dotenv/flutter_dotenv.dart';

class FragellaConfig {
  static String get apiKey => dotenv.env['FRAGELLA_API_KEY'] ?? '';
  static String get baseUrl =>
      dotenv.env['FRAGELLA_BASE_URL'] ?? 'https://api.fragella.com/api/v1';
}
