import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fragella_fragrance.dart';

class FragellaApiClient {
  FragellaApiClient({
    this.apiKey = '',
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Only needed when calling Fragella directly; the `/api` proxy adds it server-side.
  final String apiKey;
  final String baseUrl;
  final http.Client _httpClient;

  Future<List<FragellaFragrance>> searchFragrances({
    required String query,
    int limit = 10,
  }) async {
    if (query.trim().length < 3) {
      throw FragellaApiException('Search query must be at least 3 characters.');
    }

    final uri = Uri.parse('$baseUrl/fragrances').replace(
      queryParameters: {
        'search': query.trim(),
        'limit': limit.toString(),
      },
    );

    print('[FragellaAPI] Requesting: $uri');
    
    final response = await _httpClient.get(
      uri,
      headers: {
        if (apiKey.isNotEmpty) 'x-api-key': apiKey,
        'Accept': 'application/json',
      },
    );

    print('[FragellaAPI] Response status: ${response.statusCode}');
    print('[FragellaAPI] Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

    if (response.statusCode != 200) {
      print('[FragellaAPI] Error details - Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 429) {
        throw FragellaApiException(
          'Rate limit reached (429). Please wait a few seconds and try again.',
        );
      }
      if (response.statusCode == 401) {
        throw FragellaApiException(
          'Authentication failed (401). Invalid or expired API key. Verify FRAGELLA_API_KEY in the server environment.',
        );
      }
      if (response.statusCode == 403) {
        throw FragellaApiException(
          'Access forbidden (403). API key lacks required permissions or domain not authorized.',
        );
      }
      if (response.statusCode == 400) {
        throw FragellaApiException(
          'Invalid request (400). Check query parameters and request format.',
        );
      }
      throw FragellaApiException(
        'Request failed (${response.statusCode}). ${response.body}',
      );
    }

    try {
      final payload = jsonDecode(response.body);
      
      // Handle both List and Map responses
      if (payload is List) {
        print('[FragellaAPI] Received ${payload.length} fragrances');
        return payload
            .whereType<Map<String, dynamic>>()
            .map(FragellaFragrance.fromJson)
            .toList();
      } else if (payload is Map<String, dynamic>) {
        // If response is wrapped in an object, try to extract the data array
        final data = payload['data'] ?? payload['results'] ?? payload['fragrances'];
        if (data is List) {
          print('[FragellaAPI] Received ${data.length} fragrances from nested data');
          return data
              .whereType<Map<String, dynamic>>()
              .map(FragellaFragrance.fromJson)
              .toList();
        }
      }
      
      throw FragellaApiException('Unexpected response format: expected List or Map with data.');
    } catch (e) {
      if (e is FragellaApiException) rethrow;
      throw FragellaApiException('Failed to parse response: $e');
    }
  }
}

/// Exception thrown when Fragella API calls fail.
/// 
/// Authentication troubleshooting:
/// - Verify FRAGELLA_API_KEY is set in the Vercel project environment
/// - Ensure x-api-key header is being sent in all requests
/// - Check that API key has proper permissions
/// - Verify Content-Type and Accept headers are application/json
class FragellaApiException implements Exception {
  FragellaApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
