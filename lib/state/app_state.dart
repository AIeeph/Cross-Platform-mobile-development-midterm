import 'package:flutter/material.dart';

import '../data/mock_reviews.dart';
import '../models/movie.dart';
import '../models/review.dart';
import '../models/watch_plan.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoggedIn = false;
  String _username = '';
  final Set<String> _watchlist = <String>{};
  final Set<String> _watched = <String>{};
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
  int get watchlistCount => _watchlist.length;
  int get watchedCount => _watched.length;
  int get totalReviewsCount =>
      _reviews.values.fold<int>(0, (sum, items) => sum + items.length);
  List<WatchPlan> get plans => List<WatchPlan>.unmodifiable(_plans);
  bool get hideWatched => _hideWatched;
  String? get lastWatchedId => _lastWatchedId;

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
      if (_lastWatchedId == movie.id) {
        _lastWatchedId = null;
      }
    } else {
      _watched.add(movie.id);
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
}
