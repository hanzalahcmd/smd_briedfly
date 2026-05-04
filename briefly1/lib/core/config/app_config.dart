/// Central configuration for Briefly.
///
/// Replace [geminiApiKey] with your actual key before running.
/// Get a free key at: https://aistudio.google.com/app/apikey
class AppConfig {
  AppConfig._();

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}
