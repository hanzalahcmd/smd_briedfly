import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/news_item.dart';

/// Data source that calls the Gemini API directly and returns a curated
/// list of the latest tech news stories as [NewsItem] objects.
class GeminiNewsDataSource {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiNewsDataSource({required this.apiKey}) {
  _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: apiKey,
    systemInstruction: Content.system(
      'You are an expert tech news reporter. Give a brief, to the point summary '
      'in bullet points only. No long paragraphs. No intros. No conclusions. '
      'Each bullet is one short sentence max.',
    )
  );
}

Future<List<NewsItem>> fetchNews() async {
  final response = await _model.generateContent([
    Content.text('Latest tech news summary in the last 24 hours.'),
  ]);
  final text = response.text ?? '';
  if (text.isEmpty) throw Exception('Gemini returned an empty response.');
  return _parse(text);
}

  List<NewsItem> _parse(String raw) {
  final items = <NewsItem>[];

  for (final line in raw.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    // Strip leading bullet characters
    final cleaned = trimmed
        .replaceAll(RegExp(r'^[\*\-•>\d+\.]+\s*'), '')
        .replaceAll('**', '')
        .trim();

    if (cleaned.isEmpty) continue;

    // Split on first colon or dash to separate headline from body
    final separators = RegExp(r'[:–—-]');
    final match = separators.firstMatch(cleaned);

    if (match != null) {
      final headline = cleaned.substring(0, match.start).trim();
      final body = cleaned.substring(match.end).trim();
      if (headline.isNotEmpty) {
        items.add(NewsItem(
          headline: headline,
          body: body.isEmpty ? 'Read more about this story.' : body,
        ));
      }
    } else {
      // No separator found, treat whole line as headline
      items.add(NewsItem(
        headline: cleaned,
        body: 'Read more about this story.',
      ));
    }
  }

  return items;
}
}
