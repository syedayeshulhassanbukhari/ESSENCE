import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fragella_fragrance.dart';

class FragellaApiClient {
  FragellaApiClient({
    required this.apiKey,
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final String baseUrl;
  final http.Client _httpClient;

  Future<List<FragellaFragrance>> searchFragrances({
    required String query,
    int limit = 10,
  }) async {
    if (apiKey.isEmpty) {
      throw FragellaApiException('Missing API key.');
    }
    if (query.trim().length < 3) {
      throw FragellaApiException('Search query must be at least 3 characters.');
    }

    final uri = Uri.parse('$baseUrl/fragrances').replace(
      queryParameters: {
        'search': query.trim(),
        'limit': limit.toString(),
      },
    );

    final response = await _httpClient.get(
      uri,
      headers: {
        'x-api-key': apiKey,
        'accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw FragellaApiException(
        'Request failed (${response.statusCode}).',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! List) {
      throw FragellaApiException('Unexpected response format.');
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(FragellaFragrance.fromJson)
        .toList();
  }
}

class FragellaApiException implements Exception {
  FragellaApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
