import 'package:flutter_dotenv/flutter_dotenv.dart';

class MarketplaceExchangeConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey {
    final publishable = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
    if (publishable.isNotEmpty) {
      return publishable;
    }
    // Backward compatibility for legacy projects using anon key naming.
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
  static String get exchangeBucket =>
      dotenv.env['SUPABASE_EXCHANGE_BUCKET'] ?? 'exchange-images';
}
