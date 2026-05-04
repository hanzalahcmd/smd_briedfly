/// Identifies which data source should be used to load news.
enum NewsSource {
  /// The existing hosted backend (news-curator Cloud Run service).
  remote,

  /// Gemini API — AI-curated, real-time tech news summary.
  gemini,
}

abstract class NewsEvent {}

class LoadNews extends NewsEvent {
  /// Which source to load from. Defaults to [NewsSource.remote].
  final NewsSource source;

  LoadNews({this.source = NewsSource.remote});
}
