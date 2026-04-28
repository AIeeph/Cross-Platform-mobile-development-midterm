import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/movie_repository.dart';
import '../models/genre.dart';
import '../models/live_title.dart';
import '../models/movie.dart';
import '../state/app_state.dart';
import '../widgets/genre_card.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/mood_wheel_picker.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_quick_sheet.dart';
import 'watch_planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.appState,
    required this.onOpenMovie,
    required this.onOpenGenre,
  });

  final MovieRepository repository;
  final AppState appState;
  final ValueChanged<String> onOpenMovie;
  final ValueChanged<String> onOpenGenre;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double drawerWidth = 390;
  static const Map<String, List<String>> _moodGenres = {
    'Exciting': ['Action', 'Sci-Fi', 'Fantasy'],
    'Smart': ['Drama', 'Crime', 'Mystery'],
    'Fun': ['Comedy', 'Romance'],
  };

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Random _random = Random();
  final TextEditingController _searchController = TextEditingController();
  final StreamController<String> _searchStreamController = StreamController<String>.broadcast();

  late Future<_HomeData> _homeFuture;
  late Future<List<LiveTitle>> _liveTitlesFuture;
  String? _selectedGenre;
  String? _selectedMood;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.appState.savedMood;
    _homeFuture = _loadHomeData();
    _liveTitlesFuture = widget.repository.fetchLiveTrendingTitles();
    _searchStreamController.stream.listen(_onSearchStreamChanged);
  }

  @override
  void dispose() {
    _searchStreamController.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<_HomeData> _loadHomeData() async {
    final results = await Future.wait([
      widget.repository.fetchTrendingMovies(),
      widget.repository.fetchGenres(),
      widget.repository.fetchRecommendedShows(),
      widget.repository.fetchAllMovies(),
    ]);

    return _HomeData(
      trending: results[0] as List<Movie>,
      genres: results[1] as List<Genre>,
      recommended: results[2] as List<Movie>,
      allMovies: results[3] as List<Movie>,
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _onSearchStreamChanged(String value) {
    final query = value.trim();
    setState(() {
      _searchQuery = query;
    });
    if (query.isNotEmpty) {
      widget.appState.addRecentSearch(query);
    }
  }

  void _startSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      return;
    }
    _searchController.text = query;
    _searchStreamController.add(query);
  }

  Future<void> _showBottomSheet(Movie movie) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          snap: true,
          initialChildSize: 0.58,
          minChildSize: 0.34,
          maxChildSize: 0.94,
          snapSizes: const [0.34, 0.58, 0.94],
          builder: (context, scrollController) {
            return MovieQuickSheet(
              movie: movie,
              appState: widget.appState,
              scrollController: scrollController,
              onOpenDetails: () {
                Navigator.of(context).pop();
                widget.onOpenMovie(movie.id);
              },
            );
          },
        );
      },
    );
    if (mounted) {
      setState(() {});
    }
  }

  List<Movie> _applyFilters(List<Movie> source) {
    var result = source;

    if (_selectedGenre != null) {
      result = result.where((movie) => movie.genre == _selectedGenre).toList();
    }

    if (_selectedMood != null) {
      final allowedGenres = _moodGenres[_selectedMood!] ?? <String>[];
      result = result.where((movie) => allowedGenres.contains(movie.genre)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((movie) => movie.title.toLowerCase().contains(q)).toList();
    }

    if (widget.appState.hideWatched) {
      result = result.where((movie) => !widget.appState.isWatched(movie.id)).toList();
    }

    return result;
  }

  void _surpriseMe(List<Movie> pool) {
    if (pool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No movies available for current filters')),
      );
      return;
    }
    final picked = pool[_random.nextInt(pool.length)];
    _showBottomSheet(picked);
  }

  Future<void> _openLiveTitleSheet(LiveTitle title) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.45, 0.7, 0.95],
          builder: (context, scrollController) {
            return SafeArea(
              top: false,
              child: Material(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: title.imageUrl.isEmpty
                          ? const SizedBox(
                              height: 260,
                              child: ColoredBox(
                                color: Colors.black12,
                                child: Center(child: Icon(Icons.image_not_supported_outlined, size: 36)),
                              ),
                            )
                          : Image.network(title.imageUrl, height: 260, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 12),
                    Text(title.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(title.kind)),
                        Chip(label: Text('Rating ${title.rating.toStringAsFixed(1)}')),
                        ...title.genres.take(3).map((genre) => Chip(label: Text(genre))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title.summary.isEmpty ? 'No description available for this title yet.' : title.summary,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: SizedBox(
            width: drawerWidth,
            child: WatchPlannerScreen(
              appState: widget.appState,
              repository: widget.repository,
            ),
          ),
          appBar: AppBar(
            title: Text(widget.appState.username.isEmpty ? 'Streamy' : 'Streamy • ${widget.appState.username}'),
            actions: [
              IconButton(
                onPressed: widget.appState.toggleTheme,
                icon: Icon(
                  widget.appState.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
              ),
            ],
          ),
          bottomNavigationBar: MainBottomNav(
            currentIndex: 0,
            onSelectedTab: widget.appState.setSelectedTabIndex,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openDrawer,
            icon: const Icon(Icons.playlist_add_check_circle_outlined),
            label: Text('Planner (${widget.appState.watchlistCount})'),
          ),
          body: FutureBuilder<_HomeData>(
            future: _homeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('Unable to load content'));
              }

              final data = snapshot.data!;
              final trending = _applyFilters(data.trending);
              final recommended = _applyFilters(data.recommended);
              final library = _applyFilters(data.allMovies);

              Movie? lastWatched;
              if (widget.appState.lastWatchedId != null) {
                for (final movie in data.allMovies) {
                  if (movie.id == widget.appState.lastWatchedId) {
                    lastWatched = movie;
                    break;
                  }
                }
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _SectionTitle(
                    title: 'Search & Preferences',
                    subtitle: 'Stream search with saved history',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Search by movie title',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) => _searchStreamController.add(value),
                          onSubmitted: _startSearch,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _startSearch(_searchController.text),
                        icon: const Icon(Icons.search),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.history),
                        onSelected: _startSearch,
                        itemBuilder: (context) {
                          final history = widget.appState.recentSearches;
                          if (history.isEmpty) {
                            return const [PopupMenuItem(value: '', child: Text('No history yet'))];
                          }
                          return history.map((item) => PopupMenuItem(value: item, child: Text(item))).toList();
                        },
                      ),
                    ],
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Active search: "$_searchQuery"'),
                  ],
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    title: 'Smart Controls',
                    subtitle: 'Mood and filter controls',
                  ),
                  const SizedBox(height: 10),
                  MoodWheelPicker(
                    moods: _moodGenres.keys.toList(),
                    selectedMood: _selectedMood,
                    onChanged: (mood) {
                      setState(() {
                        _selectedMood = mood;
                      });
                      widget.appState.setSavedMood(mood);
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Hide watched'),
                        selected: widget.appState.hideWatched,
                        onSelected: (_) => widget.appState.toggleHideWatched(),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.casino_outlined, size: 18),
                        label: const Text('Surprise Me'),
                        onPressed: () => _surpriseMe(library),
                      ),
                    ],
                  ),
                  if (lastWatched != null) ...[
                    const SizedBox(height: 16),
                    const _SectionTitle(
                      title: 'Continue Watching',
                      subtitle: 'Resume your last watched title',
                    ),
                    MovieCard(
                      movie: lastWatched,
                      subtitle: 'Tap to continue',
                      trailing: const Icon(Icons.play_arrow_outlined),
                      onTap: () => widget.onOpenMovie(lastWatched!.id),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    title: 'Live Spotlight',
                    subtitle: 'Live titles from remote feed',
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<LiveTitle>>(
                    future: _liveTitlesFuture,
                    builder: (context, liveSnapshot) {
                      if (liveSnapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!liveSnapshot.hasData || liveSnapshot.data!.isEmpty) {
                        return const Text('Live feed is temporarily unavailable');
                      }

                      final liveTitles = liveSnapshot.data!;
                      return SizedBox(
                        height: 250,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: liveTitles.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final title = liveTitles[index];
                            return SizedBox(
                              width: 240,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _openLiveTitleSheet(title),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: title.imageUrl.isEmpty
                                            ? const ColoredBox(
                                                color: Colors.black12,
                                                child: Center(child: Icon(Icons.image_not_supported_outlined)),
                                              )
                                            : Image.network(title.imageUrl, width: double.infinity, fit: BoxFit.cover),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          title.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    title: 'Trending Movies',
                    subtitle: 'Tap any card for quick actions',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: trending.isEmpty
                        ? const Center(child: Text('No trending titles for current filters'))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: trending.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final movie = trending[index];
                              return SizedBox(
                                width: 300,
                                child: MovieCard(
                                  movie: movie,
                                  onTap: () => _showBottomSheet(movie),
                                  trailing: widget.appState.isWatched(movie.id)
                                      ? const Icon(Icons.visibility_outlined, size: 18)
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    title: 'Genres',
                    subtitle: 'Open dedicated category screens',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.genres.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final genre = data.genres[index];
                        final isSelected = genre.name == _selectedGenre;

                        return GenreCard(
                          genre: genre,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedGenre = isSelected ? null : genre.name;
                            });
                            widget.onOpenGenre(genre.name);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(
                    title: 'Recommended Shows',
                    subtitle: _selectedGenre == null ? 'Top picks for you' : 'Filtered by $_selectedGenre',
                  ),
                  const SizedBox(height: 8),
                  if (recommended.isEmpty)
                    const Text('No recommendations for current filters')
                  else
                    ...recommended.map(
                      (movie) => MovieCard(
                        movie: movie,
                        onTap: () => _showBottomSheet(movie),
                        trailing: widget.appState.isWatched(movie.id)
                            ? const Icon(Icons.visibility_outlined, size: 18)
                            : null,
                      ),
                    ),
                  const SizedBox(height: 8),
                  const _SectionTitle(
                    title: 'Library',
                    subtitle: 'All movies and series',
                  ),
                  const SizedBox(height: 8),
                  if (library.isEmpty)
                    const Text('No titles for current filters')
                  else
                    ...library.map(
                      (movie) => MovieCard(
                        movie: movie,
                        onTap: () => _showBottomSheet(movie),
                        trailing: widget.appState.isWatched(movie.id)
                            ? const Icon(Icons.visibility_outlined, size: 18)
                            : null,
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.trending,
    required this.genres,
    required this.recommended,
    required this.allMovies,
  });

  final List<Movie> trending;
  final List<Genre> genres;
  final List<Movie> recommended;
  final List<Movie> allMovies;
}


