import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class AiService {
  final String apiKey;
  final String model;

  AiService({required this.apiKey, this.model = 'gemini-2.5-flash'});

  /// Sends a user message directly to the Google Gemini API.
  /// NOTE: This will fail in a web browser due to CORS policy.
  /// It is also insecure as it exposes the API key in the client app for production.
  /// and returns the assistant's text reply.
  Future<String> sendMessage(String prompt) async {
    // Use the stable v1 endpoint for Gemini models.
    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 50},
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

  /// Checks if a lost item and a found item are a likely match.
  Future<bool> isMatch(
    Map<String, dynamic> lostItem,
    Map<String, dynamic> foundItem,
  ) async {
    final String prompt =
        '''
You are an intelligent matching assistant for a university's lost and found app.
Your task is to determine if a 'FOUND' item is a likely match for a 'LOST' item based on their details.
Consider the item name, description, and location. A perfect location match is not required, but it adds to the likelihood.
Respond with only one word: "MATCH" if it's a probable match, or "NO_MATCH" if it is not.

---
LOST Item Details:
Name: ${lostItem['item_name'] ?? 'N/A'}
Description: ${lostItem['description'] ?? 'N/A'}
Location Last Seen: ${lostItem['location'] ?? 'N/A'}
---
FOUND Item Details:
Name: ${foundItem['item_name'] ?? 'N/A'}
Description: ${foundItem['description'] ?? 'N/A'}
Location Found: ${foundItem['location'] ?? 'N/A'}
---

Based on these details, is it a likely match?
''';

    try {
      final response = await sendMessage(prompt);
      return response.trim().toUpperCase() == 'MATCH';
    } catch (e) {
      log('Error during AI match check: $e');
      return false; // Don't create a notification if AI fails
    }
  }
}
