import 'package:flutter_dotenv/flutter_dotenv.dart';

class ContextService {
  static String get userContext {
    final rawContext = dotenv.env['BELLYLOG'] ?? '';
    // Replaces explicit '\n' text from .env into real newline line breaks
    return rawContext.replaceAll(r'\n', '\n');
  }
}
