import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'api_config.dart';

class FragellaConfig {
  /// Fragella is reached through the `/api/fragrances` proxy, which holds the API key.
  static String get baseUrl => '${ApiConfig.baseUrl}/api';
  static String get widgetId => dotenv.env['FRAGELLA_WIDGET_ID'] ?? '';
}
