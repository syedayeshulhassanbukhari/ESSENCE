import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/exchange_listing.dart';
import '../config/marketplace_exchange_config.dart';

class ExchangeMarketplaceException implements Exception {
  const ExchangeMarketplaceException(this.message);

  final String message;
}

class ExchangeMarketplaceService {
  ExchangeMarketplaceService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const _tableName = 'exchange_listings';
  static const Uuid _uuid = Uuid();

  final SupabaseClient _client;

  Future<List<ExchangeListing>> fetchListings() async {
    try {
      final rows = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return rows
          .whereType<Map<String, dynamic>>()
          .map(ExchangeListing.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      throw ExchangeMarketplaceException(e.message ?? 'Failed to load exchange listings.');
    } on StorageException catch (e) {
      throw ExchangeMarketplaceException(e.message);
    } catch (_) {
      throw const ExchangeMarketplaceException('Failed to load exchange listings.');
    }
  }

  Future<ExchangeListing> createListing({
    required String name,
    required String description,
    required String price,
    required XFile image,
  }) async {
    try {
      final parsedPrice = double.tryParse(price.trim());
      if (parsedPrice == null || parsedPrice <= 0) {
        throw const ExchangeMarketplaceException('Enter a valid PKR price.');
      }

      final listingId = _uuid.v4();
      final imageBytes = await image.readAsBytes();
      final safeName = image.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final objectPath = 'exchange-listings/${listingId}_$safeName';
      final bucket = MarketplaceExchangeConfig.exchangeBucket;

      await _client.storage.from(bucket).uploadBinary(
        objectPath,
        imageBytes,
        fileOptions: FileOptions(
          upsert: false,
          contentType: _detectImageContentType(image.name),
        ),
      );

      final imageUrl = _client.storage.from(bucket).getPublicUrl(objectPath);

      final inserted = await _client
          .from(_tableName)
          .insert({
            'id': listingId,
            'name': name.trim(),
            'description': description.trim(),
            'price': parsedPrice,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return ExchangeListing.fromJson(inserted);
    } on PostgrestException catch (e) {
      throw ExchangeMarketplaceException(e.message ?? 'Failed to upload your perfume listing.');
    } on StorageException catch (e) {
      throw ExchangeMarketplaceException(e.message);
    } on ExchangeMarketplaceException {
      rethrow;
    } catch (_) {
      throw const ExchangeMarketplaceException('Failed to upload your perfume listing.');
    }
  }

  String _detectImageContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    return 'image/jpeg';
  }
}
