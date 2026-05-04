import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';
import '../data/models/news_item.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository repository;
  List<NewsItem>? _geminiCache; // add this

  NewsBloc({required this.repository}) : super(NewsInitial()) {
    on<LoadNews>(_onLoadNews);
  }

  Future<void> _onLoadNews(
    LoadNews event,
    Emitter<NewsState> emit,
  ) async {
    // If we already have cached Gemini results, just re-emit them
    if (event.source == NewsSource.gemini && _geminiCache != null) {
      emit(NewsLoaded(_geminiCache!, source: NewsSource.gemini));
      return;
    }

    emit(NewsLoading());
    try {
      final news = switch (event.source) {
        NewsSource.gemini => await repository.getGeminiTechNews(),
        NewsSource.remote => await repository.getTechNews(),
      };

      if (event.source == NewsSource.gemini) {
        _geminiCache = news; // store it
      }

      emit(NewsLoaded(news, source: event.source));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
}
