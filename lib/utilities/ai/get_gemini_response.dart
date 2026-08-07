import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String cleanGeminiResponse(String text) {
  return text.replaceAll('**', '').trim();
}

Future<String> getGeminiResponse(
  String systemInstruction,
  String userInput,
  double temp,
  double topP,
  double maxOutputTokens,
) async {
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    return 'Gemini API key not found.';
  }

  const String modelName = 'gemini-3.6-flash';
  final String endPoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey';

  try {
    final response = await http
        .post(
          Uri.parse(endPoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            // 1. Fixed snake_case key
            "system_instruction": {
              "parts": [
                {"text": systemInstruction},
              ],
            },
            "contents": [
              {
                "role": "user",
                "parts": [
                  {"text": userInput},
                ],
              },
            ],
            // 2. Fixed snake_case key
            "generation_config": {
              "temperature": temp,
              "topP": topP,
              "maxOutputTokens": maxOutputTokens,
            },
            // 3. Fixed snake_case key
            "safety_settings": [
              {
                "category": "HARM_CATEGORY_HARASSMENT",
                "threshold": "BLOCK_ONLY_HIGH",
              },
              {
                "category": "HARM_CATEGORY_HATE_SPEECH",
                "threshold": "BLOCK_ONLY_HIGH",
              },
              {
                "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                "threshold": "BLOCK_ONLY_HIGH",
              },
              {
                "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                "threshold": "BLOCK_ONLY_HIGH",
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          return "Invalid request formatting. (${response.body})";
        case 401:
        case 403:
          return "Invalid Gemini API key or access denied.";
        case 429:
          return "Too many requests. Please try again shortly.";
        case 500:
        case 503:
          return "Gemini is temporarily unavailable.";
        default:
          return "Request failed (${response.statusCode}): ${response.body}";
      }
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final candidates = data["candidates"] as List?;

    if (candidates == null || candidates.isEmpty) {
      return "No response received.";
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final finishReason = candidate["finishReason"];

    // print("Finish reason: $finishReason");

    if (finishReason == "SAFETY") {
      return "The response was blocked by Gemini's safety filters.";
    }

    final content = candidate["content"] as Map<String, dynamic>?;
    if (content == null) {
      return "No response received.";
    }

    final parts = content["parts"] as List?;
    if (parts == null || parts.isEmpty) {
      return "No response received.";
    }

    final aiText = parts.first["text"] as String?;
    if (aiText == null || aiText.isEmpty) {
      return "No text produced by Gemini.";
    }

    return cleanGeminiResponse(aiText);
  } on TimeoutException {
    return "The request timed out. Please try again.";
  } catch (e) {
    return "Unexpected error: $e";
  }
}
