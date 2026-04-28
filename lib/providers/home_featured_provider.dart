import 'package:flutter/foundation.dart';

import '../models/fragella_fragrance.dart';
import '../services/fragella_api_client.dart';

class HomeFeaturedProvider extends ChangeNotifier {
  HomeFeaturedProvider({required FragellaApiClient apiClient})
    : _apiClient = apiClient;

  final FragellaApiClient _apiClient;

  final List<FragellaFragrance> _items = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasLoaded = false;

  List<FragellaFragrance> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    await fetchFeatured();
  }

  Future<void> fetchFeatured({String query = 'perfume', int limit = 6}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _apiClient.searchFragrances(
        query: query,
        limit: limit,
      );
      _items
        ..clear()
        ..addAll(results);
    } on FragellaApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Unable to load featured perfumes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
