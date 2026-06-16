import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/exchange_listing.dart';
import '../config/marketplace_exchange_config.dart';

class FirestoreExchangeException implements Exception {
  const FirestoreExchangeException(this.message);

  final String message;
}

class FirestoreExchangeService {
  FirestoreExchangeService({
    FirebaseFirestore? firestore,
    SupabaseClient? supabase,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _supabase = supabase ?? Supabase.instance.client;

  static const _collectionName = 'exchange_listings';
  static const _storageBucket = 'exchange-listings';
  static const Uuid _uuid = Uuid();

  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase;

  CollectionReference<Map<String, dynamic>> get _listingsCollection =>
      _firestore.collection(_collectionName);

  /// Fetch all exchange listings from Firestore, ordered by creation date (newest first)
  Future<List<ExchangeListing>> fetchListings() async {
    try {
      final snapshot = await _listingsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExchangeListing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirestoreExchangeException(
        'Failed to load exchange listings: $e',
      );
    }
  }

  /// Stream all exchange listings for real-time updates
  Stream<List<ExchangeListing>> streamListings() {
    try {
      return _listingsCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ExchangeListing.fromFirestore(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw FirestoreExchangeException('Failed to stream listings: $e');
    }
  }

  /// Fetch a single listing by ID
  Future<ExchangeListing?> getListing(String listingId) async {
    try {
      final doc = await _listingsCollection.doc(listingId).get();
      if (!doc.exists) return null;
      return ExchangeListing.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw FirestoreExchangeException('Failed to fetch listing: $e');
    }
  }

  /// Create a new exchange listing with image upload to Supabase Storage
  Future<ExchangeListing> createListing({
    required String name,
    required String description,
    required String price,
    required XFile image,
    required String ownerId,
  }) async {
    try {
      final parsedPrice = double.tryParse(price.trim());
      if (parsedPrice == null || parsedPrice <= 0) {
        throw FirestoreExchangeException('Enter a valid PKR price.');
      }
      if (ownerId.trim().isEmpty) {
        throw FirestoreExchangeException('Sign in to create a listing.');
      }

      final listingId = _uuid.v4();
      final imageBytes = await image.readAsBytes();
      final safeName =
          image.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = '$_storageBucket/${listingId}_$safeName';

      // Upload image to Supabase Storage
      final bucket = MarketplaceExchangeConfig.exchangeBucket;
      await _supabase.storage
          .from(bucket)
          .uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: false,
              contentType: _detectImageContentType(image.name),
            ),
          );

      // Get public URL
      final imageUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(storagePath);

      // Create document in Firestore
      final newListing = ExchangeListing(
        id: listingId,
        ownerId: ownerId.trim(),
        name: name.trim(),
        description: description.trim(),
        price: parsedPrice,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _listingsCollection.doc(listingId).set({
        'ownerId': newListing.ownerId,
        'name': newListing.name,
        'description': newListing.description,
        'price': newListing.price,
        'imageUrl': newListing.imageUrl,
        'createdAt': Timestamp.fromDate(newListing.createdAt),
      });

      return newListing;
    } on FirestoreExchangeException {
      rethrow;
    } catch (e) {
      throw FirestoreExchangeException('Failed to create listing: $e');
    }
  }

  /// Update an existing listing (only by owner)
  Future<void> updateListing({
    required String listingId,
    required String ownerId,
    String? name,
    String? description,
    String? price,
  }) async {
    try {
      final doc = await _listingsCollection.doc(listingId).get();
      if (!doc.exists) {
        throw FirestoreExchangeException('Listing not found.');
      }

      final listing = ExchangeListing.fromFirestore(doc.data()!, listingId);
      if (listing.ownerId != ownerId) {
        throw FirestoreExchangeException(
          'You can only edit your own listings.',
        );
      }

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (name != null && name.isNotEmpty) {
        updates['name'] = name.trim();
      }
      if (description != null && description.isNotEmpty) {
        updates['description'] = description.trim();
      }
      if (price != null && price.isNotEmpty) {
        final parsedPrice = double.tryParse(price.trim());
        if (parsedPrice == null || parsedPrice <= 0) {
          throw FirestoreExchangeException('Enter a valid PKR price.');
        }
        updates['price'] = parsedPrice;
      }

      await _listingsCollection.doc(listingId).update(updates);
    } on FirestoreExchangeException {
      rethrow;
    } catch (e) {
      throw FirestoreExchangeException('Failed to update listing: $e');
    }
  }

  /// Delete a listing (only by owner)
  Future<void> deleteListing({
    required String listingId,
    required String ownerId,
  }) async {
    try {
      final doc = await _listingsCollection.doc(listingId).get();
      if (!doc.exists) {
        throw FirestoreExchangeException('Listing not found.');
      }

      final listing = ExchangeListing.fromFirestore(doc.data()!, listingId);
      if (listing.ownerId != ownerId) {
        throw FirestoreExchangeException(
          'You can only delete your own listings.',
        );
      }

      // Delete image from Supabase Storage
      try {
        final bucket = MarketplaceExchangeConfig.exchangeBucket;
        final uri = Uri.parse(listing.imageUrl);
        final pathSegments = uri.path.split('/');
        if (pathSegments.length >= 2) {
          final storagePath =
              pathSegments.sublist(pathSegments.length - 2).join('/');
          await _supabase.storage.from(bucket).remove([storagePath]);
        }
      } catch (_) {
        // Ignore storage deletion errors
      }

      // Delete document
      await _listingsCollection.doc(listingId).delete();
    } on FirestoreExchangeException {
      rethrow;
    } catch (e) {
      throw FirestoreExchangeException('Failed to delete listing: $e');
    }
  }

  /// Get listings by seller (owner)
  Future<List<ExchangeListing>> getListingsBySeller(String ownerId) async {
    try {
      final snapshot = await _listingsCollection
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExchangeListing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirestoreExchangeException('Failed to fetch seller listings: $e');
    }
  }

  String _detectImageContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
