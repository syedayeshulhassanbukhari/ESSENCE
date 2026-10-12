import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  /// Origin hosting the serverless `/api/*` routes. Defaults to the site's own
  /// origin; set API_BASE_URL in assets/.env to point local runs at a deployment.
  static String get baseUrl {
    final override = (dotenv.env['API_BASE_URL'] ?? '').trim();
    if (override.isNotEmpty) {
      return override.replaceAll(RegExp(r'/+$'), '');
    }
    final base = Uri.base;
    return base.scheme.startsWith('http') ? base.origin : '';
  }
}
