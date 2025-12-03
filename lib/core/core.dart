// File: /home/lamkien/Flutter/Projects/ontn/lib/core/core.dart
//
// Tiny helper to send arbitrary JSON payloads to a Gemini-like REST endpoint.
// Configure the endpoint and API key as needed (do NOT hardcode secrets in source).

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiClient {
  final String apiKey;
  final Uri endpoint;

  /// Default endpoint targets a Gemini-style "generate" method.
  /// Replace with the exact URL your provider documents if different.
  GeminiClient({required this.apiKey, Uri? endpoint})
    : endpoint =
          endpoint ??
          Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta2/models/gemini-2.5-flash:generateText',
          );

  /// Send arbitrary JSON payload and get parsed JSON response.
  /// The [jsonPayload] is sent as the request body.
  Future<Map<String, dynamic>> generateFromJson(
    Map<String, dynamic> jsonPayload,
  ) async {
    final resp = await http.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
        // For Google GenAI use a Bearer token (OAuth) or API key depending on your setup.
        // If using an API key in query param, adapt the URL instead.
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(jsonPayload),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'response': decoded};
    } else {
      throw HttpException(
        'Request failed (${resp.statusCode}): ${resp.body}',
        uri: endpoint,
      );
    }
  }
}


// Example usage (async context):
// final apiKey = Platform.environment['GENAI_API_KEY'] ?? 'YOUR_API_KEY';
// final client = GeminiClient(apiKey: apiKey);
// final payload = {
//   "instances": [
//     {"content": "Viết đoạn JSON mô tả một sản phẩm ví dụ bằng tiếng Việt"}
//   ],
//   "parameters": {"temperature": 0.2}
// };
// final result = await client.generateFromJson(payload);
// print(result);