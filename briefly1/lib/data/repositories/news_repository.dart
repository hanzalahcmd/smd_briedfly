import '../datasources/gemini_news_data_source.dart';
import '../datasources/news_remote_data_source.dart';
import '../models/news_item.dart';

/// Repository that mediates between the two available data sources:
/// - [remoteDataSource]: the existing hosted backend
/// - [geminiDataSource]: direct Gemini API call for AI-curated news
class NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final GeminiNewsDataSource geminiDataSource;

  NewsRepository({
    required this.remoteDataSource,
    required this.geminiDataSource,
  });

  /// Fetches news from the existing hosted backend.
  Future<List<NewsItem>> getTechNews() {
    return remoteDataSource.fetchNews();
  }

  /// Fetches a Gemini-curated tech news summary directly from the Gemini API.
  Future<List<NewsItem>> getGeminiTechNews() {
    return geminiDataSource.fetchNews();
  }
}
