import 'package:flutter/material.dart';

import '../data/movie_repository.dart';
import '../state/app_state.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/movie_card.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({
    super.key,
    required this.repository,
    required this.appState,
    required this.onOpenMovie,
  });

  final MovieRepository repository;
  final AppState appState;
  final ValueChanged<String> onOpenMovie;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final allMovies = repository.getAllSync();
        final watchlist = appState.watchlistItems(allMovies);

        return Scaffold(
          appBar: AppBar(title: const Text('Favourites Movies')),
          bottomNavigationBar: MainBottomNav(
            currentIndex: 1,
            onSelectedTab: appState.setSelectedTabIndex,
          ),
          body: watchlist.isEmpty
              ? const Center(
                  child: Text('Your favourites list is empty'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: watchlist.length,
                  itemBuilder: (context, index) {
                    final movie = watchlist[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () => onOpenMovie(movie.id),
                      subtitle: 'Group size: ${appState.partySizeFor(movie.id)}',
                      trailing: IconButton(
                        onPressed: () => appState.removeFromWatchlist(movie),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

