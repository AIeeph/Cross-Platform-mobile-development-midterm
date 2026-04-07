import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../state/app_state.dart';
import 'watchlist_control.dart';

class MovieQuickSheet extends StatelessWidget {
  const MovieQuickSheet({
    super.key,
    required this.movie,
    required this.appState,
    required this.onOpenDetails,
  });

  final Movie movie;
  final AppState appState;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final watched = appState.isWatched(movie.id);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (movie.rating >= 8.8)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    '#1 Fan Favorite',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 220,
                  color: Colors.black,
                  child: CachedNetworkImage(
                    imageUrl: movie.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    fadeInDuration: const Duration(milliseconds: 220),
                    placeholder: (context, progress) => const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 220,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text('${movie.genre} • ${movie.duration} • ${movie.platform}'),
              const SizedBox(height: 10),
              Text(movie.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              WatchlistControl(
                onAdd: (partySize) {
                  appState.addToWatchlist(movie, partySize: partySize);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${movie.title} added to watchlist')),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => appState.toggleWatched(movie),
                  icon: Icon(watched ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  label: Text(watched ? 'Mark as Unwatched' : 'Mark as Watched'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenDetails,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Full Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
