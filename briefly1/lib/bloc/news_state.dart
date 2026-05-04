import '../data/models/news_item.dart';
import 'news_event.dart';

abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsItem> news;

  /// Tracks which source produced this loaded state so the UI can reflect it.
  final NewsSource source;

  NewsLoaded(this.news, {this.source = NewsSource.remote});
}

class NewsError extends NewsState {
  final String message;

  NewsError(this.message);
}
