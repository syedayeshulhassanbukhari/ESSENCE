import 'package:flutter/foundation.dart';

import '../models/fragella_fragrance.dart';
import '../services/fragella_api_client.dart';

class MarketplaceApiProvider extends ChangeNotifier {
  MarketplaceApiProvider({required FragellaApiClient apiClient})
      : _apiClient = apiClient;

  final FragellaApiClient _apiClient;

  final List<FragellaFragrance> _items = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasLoaded = false;
  String _lastQuery = 'fragrance';

  List<FragellaFragrance> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;

  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    await fetchCatalog();
  }

  Future<void> fetchCatalog({String query = 'fragrance', int limit = 24}) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 3) {
      _errorMessage = 'Search query must be at least 3 characters.';
      notifyListeners();
      return;
    }
    if (_isLoading && normalizedQuery == _lastQuery) {
      return;
    }
    if (!_isLoading && normalizedQuery == _lastQuery && _items.isNotEmpty) {
      return;
    }

    _lastQuery = normalizedQuery;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _apiClient.searchFragrances(
        query: normalizedQuery,
        limit: limit,
      );
      _items
        ..clear()
        ..addAll(results);
    } on FragellaApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Unable to load marketplace perfumes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
