import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/news_bloc.dart';
import '../../bloc/news_event.dart';
import '../../bloc/news_state.dart';
import '../widgets/news_card.dart';
import '../widgets/share_daily_brief_sheet.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  NewsSource _activeSource = NewsSource.remote;

  @override
  void initState() {
    super.initState();
    context.read<NewsBloc>().add(LoadNews(source: _activeSource));
  }

  void _switchSource(NewsSource source) {
    if (source == _activeSource) return;
    setState(() => _activeSource = source);
    context.read<NewsBloc>().add(LoadNews(source: source));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Briefly',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            children: const <TextSpan>[
              TextSpan(
                text: '.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.lime,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none)),
          CircleAvatar(child: Icon(Icons.person_2_outlined)),
          SizedBox(width: 16),
        ],
      ),
      floatingActionButton: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          final newsCount = state is NewsLoaded ? state.news.length : 5;
          return FloatingActionButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                isDismissible: false,
                builder: (BuildContext context) {
                  return ShareDailyBriefSheet(newsCount: newsCount);
                },
              );
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.share_outlined),
          );
        },
      ),
      body: Column(
        children: [
          _SourceToggle(
            active: _activeSource,
            onChanged: _switchSource,
          ),
          Expanded(
            child: BlocBuilder<NewsBloc, NewsState>(
              builder: (context, state) {
                if (state is NewsLoading || state is NewsInitial) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        if (_activeSource == NewsSource.gemini) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Asking Gemini for the latest…',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                if (state is NewsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade400, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Error: ${state.message}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context
                                .read<NewsBloc>()
                                .add(LoadNews(source: _activeSource)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is NewsLoaded) {
                  final news = state.news;

                  final List<Map<String, dynamic>> categories = [
                    {
                      'label': 'Tech',
                      'color': Colors.lime,
                      'textColor': Colors.black,
                    },
                    {'label': 'Sports'},
                    {'label': 'Politics'},
                    {'label': 'Crypto'},
                    {'label': 'Design'},
                  ];

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<NewsBloc>()
                          .add(LoadNews(source: _activeSource));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: news.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(categories.length, (i) {
                                  final category = categories[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Chip(
                                      label: Text(
                                        category['label'],
                                        style: TextStyle(
                                          color: category['textColor'] ??
                                              Colors.white,
                                        ),
                                      ),
                                      backgroundColor: category['color'],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          );
                        } else if (index == 1) {
                          return const SizedBox(height: 8);
                        } else {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: NewsCard(
                              item: news[index - 2],
                              isGemini: state.source == NewsSource.gemini,
                            ),
                          );
                        }
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A pill-shaped segmented toggle to switch between [NewsSource.remote]
/// (the existing backend) and [NewsSource.gemini] (the Gemini AI feed).
class _SourceToggle extends StatelessWidget {
  final NewsSource active;
  final ValueChanged<NewsSource> onChanged;

  const _SourceToggle({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _Tab(
              label: 'Feed',
              icon: Icons.rss_feed,
              selected: active == NewsSource.remote,
              onTap: () => onChanged(NewsSource.remote),
            ),
            _Tab(
              label: 'AI Brief',
              icon: Icons.auto_awesome,
              selected: active == NewsSource.gemini,
              onTap: () => onChanged(NewsSource.gemini),
              selectedColor: Colors.lime,
              selectedTextColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedTextColor;

  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.selectedColor = Colors.white,
    this.selectedTextColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? selectedTextColor : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? selectedTextColor : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
