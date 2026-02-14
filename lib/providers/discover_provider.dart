import 'package:flutter/foundation.dart';

import '../models/fragella_fragrance.dart';
import '../services/fragella_api_client.dart';

class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({required FragellaApiClient apiClient})
      : _apiClient = apiClient;

  final FragellaApiClient _apiClient;

  final List<FragellaFragrance> _results = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _lastQuery = '';

  List<FragellaFragrance> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;

  Future<void> search({required String query, int limit = 10}) async {
    _lastQuery = query;
    _errorMessage = '';
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiClient.searchFragrances(
        query: query,
        limit: limit,
      );
      _results
        ..clear()
        ..addAll(data);
    } on FragellaApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
