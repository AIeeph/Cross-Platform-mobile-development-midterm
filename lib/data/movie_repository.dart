import 'dart:async';

import '../models/genre.dart';
import '../models/movie.dart';
import 'mock_movies.dart';

class MovieRepository {
  List<Movie> getAllSync() {
    return mockMovies;
  }

  Future<List<Movie>> fetchAllMovies() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return mockMovies;
  }

  Future<List<Movie>> fetchTrendingMovies() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return mockMovies.where((movie) => movie.isTrending).toList();
  }

  Future<List<Movie>> fetchRecommendedShows() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return mockMovies.where((movie) => movie.isSeries).toList();
  }

  Future<List<Genre>> fetchGenres() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final genres = <String>{};
    for (final movie in mockMovies) {
      genres.add(movie.genre);
    }

    return genres.map((name) => Genre(name: name, imageUrl: _genreImage(name))).toList();
  }

  Movie? getMovieById(String id) {
    for (final movie in mockMovies) {
      if (movie.id == id) {
        return movie;
      }
    }
    return null;
  }

  List<Movie> getSimilarMovies(Movie source) {
    return mockMovies
        .where((movie) => movie.id != source.id && movie.genre == source.genre)
        .take(4)
        .toList();
  }

  String _genreImage(String genre) {
    for (final movie in mockMovies) {
      if (movie.genre == genre) {
        return movie.imageUrl;
      }
    }
    return mockMovies.first.imageUrl;
  }
}

