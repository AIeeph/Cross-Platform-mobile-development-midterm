import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_reviews.dart';
import '../models/achievement.dart';
import '../models/movie.dart';
import '../models/review.dart';
import '../models/watch_plan.dart';

class AppState extends ChangeNotifier {
  AppState({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences {
    _restorePreferences();
  }

  static const _prefSelectedTabKey = 'selectedTabIndex';
  static const _prefSearchHistoryKey = 'searchHistory';
  static const _prefMoodKey = 'selectedMood';

  final SharedPreferences _sharedPreferences;

  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoggedIn = false;
  String _username = '';
  int _selectedTabIndex = 0;
  final List<String> _recentSearches = <String>[];
  String? _savedMood;

  final Set<String> _watchlist = <String>{};
  final Set<String> _watched = <String>{};
  final Map<String, DateTime> _watchedAtByMovie = <String, DateTime>{};
  final Map<String, int> _watchedGenreCounts = <String, int>{};
  final Map<String, int> _watchPartySizes = <String, int>{};
  final List<WatchPlan> _plans = <WatchPlan>[];
  bool _hideWatched = false;
  String? _lastWatchedId;
  final Map<String, List<Review>> _reviews = {
    for (final entry in mockReviews.entries) entry.key: List<Review>.from(entry.value),
  };

  ThemeMode get themeMode => _themeMode;
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  int get selectedTabIndex => _selectedTabIndex;
  List<String> get recentSearches => List<String>.unmodifiable(_recentSearches);
  String? get savedMood => _savedMood;

  int get watchlistCount => _watchlist.length;
  int get watchedCount => _watched.length;
  int get watchedGenresCount => _watchedGenreCounts.values.where((count) => count > 0).length;
  int get currentStreakDays => _computeCurrentStreak();
  int get longestStreakDays => _computeLongestStreak();
  List<Achievement> get achievements => _buildAchievements();
  int get totalReviewsCount => _reviews.values.fold<int>(0, (sum, items) => sum + items.length);
  List<WatchPlan> get plans => List<WatchPlan>.unmodifiable(_plans);
  bool get hideWatched => _hideWatched;
  String? get lastWatchedId => _lastWatchedId;

  void _restorePreferences() {
    _selectedTabIndex = _sharedPreferences.getInt(_prefSelectedTabKey) ?? 0;
    final history = _sharedPreferences.getStringList(_prefSearchHistoryKey) ?? <String>[];
    _recentSearches
      ..clear()
      ..addAll(history);
    _savedMood = _sharedPreferences.getString(_prefMoodKey);
  }

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    _sharedPreferences.setInt(_prefSelectedTabKey, index);
    notifyListeners();
  }

  void addRecentSearch(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }

    _recentSearches.remove(normalized);
    _recentSearches.insert(0, normalized);

    if (_recentSearches.length > 8) {
      _recentSearches.removeRange(8, _recentSearches.length);
    }

    _sharedPreferences.setStringList(_prefSearchHistoryKey, _recentSearches);
    notifyListeners();
  }

  void setSavedMood(String? mood) {
    _savedMood = mood;
    if (mood == null) {
      _sharedPreferences.remove(_prefMoodKey);
    } else {
      _sharedPreferences.setString(_prefMoodKey, mood);
    }
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  bool login({required String username, required String password}) {
    final trimmed = username.trim();
    if (trimmed.isEmpty || password.trim().length < 4) {
      return false;
    }
    _username = trimmed;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _username = '';
    notifyListeners();
  }

  bool isInWatchlist(String movieId) {
    return _watchlist.contains(movieId);
  }

  bool isWatched(String movieId) {
    return _watched.contains(movieId);
  }

  int partySizeFor(String movieId) {
    return _watchPartySizes[movieId] ?? 1;
  }

  List<Movie> watchlistItems(List<Movie> allMovies) {
    return allMovies.where((movie) => _watchlist.contains(movie.id)).toList();
  }

  void addToWatchlist(Movie movie, {int partySize = 1}) {
    _watchlist.add(movie.id);
    _watchPartySizes[movie.id] = partySize;
    notifyListeners();
  }

  void removeFromWatchlist(Movie movie) {
    _watchlist.remove(movie.id);
    _watchPartySizes.remove(movie.id);
    notifyListeners();
  }

  void toggleWatchlist(Movie movie) {
    if (_watchlist.contains(movie.id)) {
      removeFromWatchlist(movie);
    } else {
      addToWatchlist(movie);
    }
  }

  void toggleWatched(Movie movie) {
    if (_watched.contains(movie.id)) {
      _watched.remove(movie.id);
      _watchedAtByMovie.remove(movie.id);
      _decrementGenreCount(movie.genre);
      if (_lastWatchedId == movie.id) {
        _lastWatchedId = null;
      }
    } else {
      _watched.add(movie.id);
      _watchedAtByMovie[movie.id] = DateTime.now();
      _incrementGenreCount(movie.genre);
      _lastWatchedId = movie.id;
    }
    notifyListeners();
  }

  void toggleHideWatched() {
    _hideWatched = !_hideWatched;
    notifyListeners();
  }

  void clearWatchlist() {
    _watchlist.clear();
    _watchPartySizes.clear();
    notifyListeners();
  }

  void submitPlan(WatchPlan plan) {
    _plans.insert(0, plan);
    clearWatchlist();
  }

  List<Review> reviewsFor(String movieId) {
    return List<Review>.unmodifiable(_reviews[movieId] ?? <Review>[]);
  }

  void addReview({
    required String movieId,
    required String comment,
    required int rating,
  }) {
    final author = _username.isEmpty ? 'Guest' : _username;
    final list = _reviews.putIfAbsent(movieId, () => <Review>[]);
    list.insert(
      0,
      Review(
        author: author,
        comment: comment.trim(),
        rating: rating,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void _incrementGenreCount(String genre) {
    _watchedGenreCounts[genre] = (_watchedGenreCounts[genre] ?? 0) + 1;
  }

  void _decrementGenreCount(String genre) {
    final current = _watchedGenreCounts[genre] ?? 0;
    if (current <= 1) {
      _watchedGenreCounts.remove(genre);
    } else {
      _watchedGenreCounts[genre] = current - 1;
    }
  }

  int _computeCurrentStreak() {
    if (_watchedAtByMovie.isEmpty) {
      return 0;
    }

    final days = _watchedAtByMovie.values.map(_startOfDay).toSet();
    var cursor = _startOfDay(DateTime.now());
    var streak = 0;

    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _computeLongestStreak() {
    if (_watchedAtByMovie.isEmpty) {
      return 0;
    }

    final sortedDays = _watchedAtByMovie.values.map(_startOfDay).toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    var best = 1;
    var run = 1;
    for (var i = 1; i < sortedDays.length; i++) {
      final diff = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      if (diff == 1) {
        run++;
        if (run > best) {
          best = run;
        }
      } else {
        run = 1;
      }
    }
    return best;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Achievement> _buildAchievements() {
    return [
      Achievement(
        title: 'First Watch',
        description: 'Watch your first title',
        progress: watchedCount,
        target: 1,
      ),
      Achievement(
        title: 'Movie Explorer',
        description: 'Watch 5 titles',
        progress: watchedCount,
        target: 5,
      ),
      Achievement(
        title: 'Genre Hopper',
        description: 'Watch 4 different genres',
        progress: watchedGenresCount,
        target: 4,
      ),
      Achievement(
        title: 'Streak Starter',
        description: '3-day watching streak',
        progress: currentStreakDays,
        target: 3,
      ),
      Achievement(
        title: 'Streak Master',
        description: '7-day longest streak',
        progress: longestStreakDays,
        target: 7,
      ),
    ];
  }
}
