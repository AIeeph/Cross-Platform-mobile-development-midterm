import 'dart:math';

import 'package:flutter/material.dart';

import '../data/movie_repository.dart';
import '../models/genre.dart';
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
  late Future<_HomeData> _homeFuture;
  String? _selectedGenre;
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
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
          bottomNavigationBar: const MainBottomNav(currentIndex: 0),
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
                  _SectionTitle(
                    title: 'Smart Controls',
                    subtitle: 'Mood wheel + smart filters',
                  ),
                  const SizedBox(height: 10),
                  MoodWheelPicker(
                    moods: _moodGenres.keys.toList(),
                    selectedMood: _selectedMood,
                    onChanged: (mood) {
                      setState(() {
                        _selectedMood = mood;
                      });
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
                    _SectionTitle(
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
                  _SectionTitle(
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
                  _SectionTitle(
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
                  _SectionTitle(
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
