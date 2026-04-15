import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/exchange_listing.dart';
import '../services/exchange_marketplace_service.dart';

class ExchangeListingProvider extends ChangeNotifier {
  ExchangeListingProvider({required ExchangeMarketplaceService service})
      : _service = service;

  final ExchangeMarketplaceService _service;

  final List<ExchangeListing> _items = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _errorMessage = '';
  bool _hasLoaded = false;

  List<ExchangeListing> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String get errorMessage => _errorMessage;

  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    await refreshListings();
  }

  Future<void> refreshListings() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await _service.fetchListings();
      _items
        ..clear()
        ..addAll(data);
    } on ExchangeMarketplaceException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load exchange listings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitListing({
    required String name,
    required String description,
    required String price,
    required XFile image,
  }) async {
    final normalizedName = name.trim();
    final normalizedDescription = description.trim();
    final normalizedPrice = price.trim();

    if (normalizedName.isEmpty || normalizedDescription.isEmpty) {
      _errorMessage = 'Name and description are required.';
      notifyListeners();
      return false;
    }

    final pkrPattern = RegExp(r'^\d{1,7}(\.\d{1,2})?$');
    if (!pkrPattern.hasMatch(normalizedPrice)) {
      _errorMessage = 'Enter a valid PKR amount (example: 1499 or 1499.50).';
      notifyListeners();
      return false;
    }

    final parsed = double.tryParse(normalizedPrice);
    if (parsed == null || parsed <= 0) {
      _errorMessage = 'Price must be greater than zero.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final listing = await _service.createListing(
        name: normalizedName,
        description: normalizedDescription,
        price: normalizedPrice,
        image: image,
      );
      _items.insert(0, listing);
      return true;
    } on ExchangeMarketplaceException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not upload your listing.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
