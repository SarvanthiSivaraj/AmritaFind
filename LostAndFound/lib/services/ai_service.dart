import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  final String apiKey;
  final String model;

  AiService({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
  });

  // ---------------- CHATBOT ----------------
  Future<String> sendMessage(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text']
        .toString()
        .trim();
  }

  // ---------------- LOST–FOUND MATCHING ----------------
  Future<bool> isMatch(
    Map<String, dynamic> lostItem,
    Map<String, dynamic> foundItem,
  ) async {
    final prompt = '''
You are an AI assistant for a university lost-and-found system.

Compare the LOST item and FOUND item below.
Reply ONLY with "YES" or "NO".

LOST ITEM:
Name: ${lostItem['item_name']}
Description: ${lostItem['description']}
Location: ${lostItem['location']}

FOUND ITEM:
Name: ${foundItem['item_name']}
Description: ${foundItem['description']}
Location: ${foundItem['location']}
''';

    final response = await sendMessage(prompt);

    return response.toUpperCase().contains('YES');
  }
}
