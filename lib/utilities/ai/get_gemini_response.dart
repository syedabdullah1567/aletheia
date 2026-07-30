import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String cleanGeminiResponse(String text) {
  return text.replaceAll('**', '').trim();
}

Future<String> getGeminiResponse(String userInput) async {
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    return 'Gemini API key not found.';
  }

  // Model name - ensure key is appended as a query parameter
  const String modelName = 'gemini-3.5-flash-lite';
  final String endPoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey';

  try {
    final response = await http
        .post(
          Uri.parse(endPoint),
          headers: {'Content-Type': 'application/json'},
          // body: jsonEncode({
          //   "contents": [
          //     {
          //       "parts": [
          //         {"text": userInput},
          //       ],
          //     },
          //   ],
          // }),
          body: jsonEncode({
            "systemInstruction": {
              "parts": [
                {
                  "text": """
          You are BellyLog, an AI digestive health assistant inside the Aletheia app.

          Your job is to analyze the user's BellyLog records and identify meaningful patterns.

          Rules:
          - Never diagnose diseases.
          - Never recommend medication.
          - Never claim certainty when there is insufficient evidence.
          - Base every observation only on the provided data.
          - If no obvious pattern exists, clearly state that.
          - Mention possible food-symptom relationships only when supported by the data.
          - End with 2-3 practical observations the user can monitor over the next few days.
          - Keep the response under 300 words.
          - Respond in plain English.
          - Do not use Markdown, headings, tables or code blocks.
          - You may use only bullet points and text formatting of the form that could be understood by a very basic flutter text display
          """,
                },
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
            "generationConfig": {
              "temperature": 0.2,
              "topP": 0.9,
              "maxOutputTokens": 500,
            },
            "safetySettings": [
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
          return "Invalid request formatting.";
        case 401:
        case 403:
          return "Invalid Gemini API key or access denied.";
        case 429:
          return "Too many requests. Please try again shortly.";
        case 500:
        case 503:
          return "Gemini is temporarily unavailable.";
        default:
          return "Request failed (${response.statusCode}).";
      }
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final candidates = data["candidates"] as List?;

    if (candidates == null || candidates.isEmpty) {
      return "No response received.";
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final finishReason = candidate["finishReason"];

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
