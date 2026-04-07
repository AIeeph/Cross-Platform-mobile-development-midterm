import 'package:flutter/material.dart';

import '../data/movie_repository.dart';
import '../widgets/movie_card.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({
    super.key,
    required this.genre,
    required this.repository,
    required this.onOpenMovie,
  });

  final String genre;
  final MovieRepository repository;
  final ValueChanged<String> onOpenMovie;

  @override
  Widget build(BuildContext context) {
    final movies = repository.getAllSync().where((movie) => movie.genre == genre).toList();

    return Scaffold(
      appBar: AppBar(title: Text(genre)),
      body: movies.isEmpty
          ? Center(child: Text('No titles in $genre'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return MovieCard(
                  movie: movie,
                  onTap: () => onOpenMovie(movie.id),
                );
              },
            ),
    );
  }
}
