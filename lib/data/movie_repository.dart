import 'dart:async';

import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_feed.dart';
import 'mock_movies.dart';

class MovieRepository {
  final MovieFeed _feed = MovieFeed.fromJson(mockMovieFeedJson);

  List<Movie> get _movies => _feed.results;

  List<Movie> getAllSync() {
    return _movies;
  }

  Future<List<Movie>> fetchAllMovies() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return _movies;
  }

  Future<List<Movie>> fetchTrendingMovies() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _movies.where((movie) => movie.isTrending).toList();
  }

  Future<List<Movie>> fetchRecommendedShows() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return _movies.where((movie) => movie.isSeries).toList();
  }

  Future<List<Genre>> fetchGenres() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final genres = <String>{};
    for (final movie in _movies) {
      genres.add(movie.genre);
    }

    return genres.map((name) => Genre(name: name, imageUrl: _genreImage(name))).toList();
  }

  Movie? getMovieById(String id) {
    for (final movie in _movies) {
      if (movie.id == id) {
        return movie;
      }
    }
    return null;
  }

  List<Movie> getSimilarMovies(Movie source) {
    return _movies
        .where((movie) => movie.id != source.id && movie.genre == source.genre)
        .take(4)
        .toList();
  }

  String _genreImage(String genre) {
    for (final movie in _movies) {
      if (movie.genre == genre) {
        return movie.imageUrl;
      }
    }
    return _movies.first.imageUrl;
  }
}

