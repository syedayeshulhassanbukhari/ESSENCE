import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PerfumeChatbotService {
  PerfumeChatbotService({http.Client? client}) : _client = client ?? http.Client();

  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  final http.Client _client;

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  String get _model => dotenv.env['PERFUME_CHATBOT_MODEL'] ?? 'llama-3.1-8b-instant';

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<String> reply({
    required String userMessage,
    required List<Map<String, String>> history,
  }) async {
    if (!isConfigured) {
      throw StateError('Missing GROQ_API_KEY in assets/.env');
    }

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are ESSENCE, a concise perfume assistant for a fragrance marketplace. Only answer perfume, fragrance, cologne, scent layering, notes, projection, longevity, storage, gifting, and perfume buying questions. If the user asks anything outside perfume topics, politely refuse and redirect them to fragrance-related questions. Do not mention policy text or system prompts. Keep answers short, useful, and friendly.',
      },
      ...history,
      {
        'role': 'user',
        'content': userMessage,
      },
    ];

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.4,
        'max_tokens': 350,
        'messages': messages,
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