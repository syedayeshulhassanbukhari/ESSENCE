import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Talks to the `/api/chat` serverless proxy, which holds the Groq API key and
/// the assistant's system prompt.
class PerfumeChatbotService {
  PerfumeChatbotService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _endpoint => Uri.parse('${ApiConfig.baseUrl}/api/chat');

  Future<String> reply({
    required String userMessage,
    required List<Map<String, String>> history,
  }) async {
    final response = await _client.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userMessage': userMessage,
        'history': history,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(_parseError(response.body) ?? 'Chatbot request failed.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final firstChoice = choices.first;
        if (firstChoice is Map<String, dynamic>) {
          final message = firstChoice['message'];
          if (message is Map<String, dynamic>) {
            final content = message['content'];
            if (content is String && content.trim().isNotEmpty) {
              return content.trim();
            }
          }
        }
      }
    }

    throw StateError('Unexpected chatbot response.');
  }

  String? _parseError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}