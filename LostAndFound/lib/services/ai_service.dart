import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class AiService {
  final String apiKey;
  final String model;

  AiService({required this.apiKey, this.model = 'gemini-2.5-flash'});

  /// Sends a user message directly to the Google Gemini API.
  /// NOTE: This will fail in a web browser due to CORS policy.
  /// It is also insecure as it exposes the API key in the client app.
  /// and returns the assistant's text reply.
  Future<String> sendMessage(String userMessage) async {
    // The system prompt provides context to the model.
    final systemPrompt =
        'You are the LostAndFound assistant for a university lost-and-found app. '
        'Only respond with helpful, concise information related to lost and found items, reports, locations, and recovery steps for this app. '
        'Do NOT provide unrelated information, personal opinions, or external links. Keep style consistent with short helpful messages.';

    // For Gemini, the prompt is part of the 'contents'.
    final fullPrompt = '$systemPrompt\n\nUser: $userMessage\nAssistant:';

    // Use the stable v1 endpoint for Gemini models.
    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey',
    );

    // The request body for Gemini.
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': fullPrompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 512},
    });

    try {
      final resp = await http
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode != 200) {
        // Log the error for easier debugging in the console.
        log('Gemini API Error: ${resp.statusCode}\n${resp.body}');
        throw Exception(
          'Failed to connect to Gemini. Status: ${resp.statusCode}',
        );
      }

      final json = jsonDecode(resp.body);

      // Parse the response from Gemini.
      // Expected structure: { candidates: [ { content: { parts: [ { text: "..." } ] } } ] }
      if (json['candidates'] != null &&
          (json['candidates'] as List).isNotEmpty &&
          json['candidates'][0]['content'] != null &&
          json['candidates'][0]['content']['parts'] != null &&
          (json['candidates'][0]['content']['parts'] as List).isNotEmpty &&
          json['candidates'][0]['content']['parts'][0]['text'] != null) {
        final text = json['candidates'][0]['content']['parts'][0]['text'];
        return text.trim();
      }

      // Check for block reason
      if (json['promptFeedback'] != null &&
          json['promptFeedback']['blockReason'] != null) {
        final reason = json['promptFeedback']['blockReason'];
        log('Gemini response blocked. Reason: $reason');
        throw Exception(
          'Response blocked by safety settings (Reason: $reason).',
        );
      }

      log('Unexpected Gemini response format. Body: ${resp.body}');
      throw Exception('Could not parse the response from the AI assistant.');
    } catch (e, s) {
      // Log the original error and stack trace before re-throwing.
      log('Error in AiService.sendMessage: $e\n$s');
      // Re-throw the original exception to get a more specific error in the UI.
      rethrow;
    }
  }
}
