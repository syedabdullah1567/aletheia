import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Store the chat history globally so the conversation context is maintained
List<Map<String, dynamic>> chatHistory = [];

void clearChatHistory() {
  chatHistory.clear();
}

String cleanGeminiResponse(String text) {
  return text
      // Bold
      .replaceAll('**', '')
      // Italics
      .replaceAll('*', '')
      // Inline code
      .replaceAll('`', '')
      // Markdown headings
      .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
      // Bullet points
      .replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '• ');
}

Future<String> getGeminiResponse(String userInput) async {
  const String endPoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent';
  final apiKey = dotenv.env['GEMINI_API_KEY']!;

  // 1. Add the new user prompt to the history
  chatHistory.add({
    'role': 'user',
    'parts': [
      {'text': userInput},
    ],
  });

  try {
    final response = await http.post(
      Uri.parse(endPoint),
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      body: jsonEncode({
        'contents': chatHistory, // 2. Send the entire history array
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String aiText =
          data['candidates'][0]['content']['parts'][0]['text'] as String;

      // 3. Save Gemini's answer to the history so it remembers for the next turn
      chatHistory.add({
        'role': 'model',
        'parts': [
          {'text': aiText},
        ],
      });

      final cleanedText = cleanGeminiResponse(aiText);

      return cleanedText;
    } else {
      // Remove the failed user prompt so it doesn't break future requests
      chatHistory.removeLast();
      return 'Error: ${response.statusCode}\n${response.body}';
    }
  } catch (e) {
    chatHistory.removeLast();
    return 'Error: $e';
  }
}
