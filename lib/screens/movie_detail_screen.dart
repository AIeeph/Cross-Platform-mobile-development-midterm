import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/movie_repository.dart';
import '../models/movie.dart';
import '../models/review.dart';
import '../state/app_state.dart';
import '../widgets/movie_card.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.repository,
    required this.appState,
    required this.onOpenMovie,
  });

  final Movie movie;
  final MovieRepository repository;
  final AppState appState;
  final ValueChanged<String> onOpenMovie;

  Future<void> _openReviewDialog(BuildContext context) async {
    final commentController = TextEditingController();
    int rating = 5;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: rating,
                    items: List<DropdownMenuItem<int>>.generate(
                      5,
                      (index) {
                        final value = index + 1;
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value stars'),
                        );
                      },
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() {
                          rating = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Rating'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Your review',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final comment = commentController.text.trim();
                    if (comment.isEmpty) {
                      return;
                    }
                    appState.addReview(movieId: movie.id, comment: comment, rating: rating);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  void _openPosterViewer(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => _PosterViewerDialog(imageUrl: movie.imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final similarMovies = repository.getSimilarMovies(movie);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final inWatchlist = appState.isInWatchlist(movie.id);
        final watched = appState.isWatched(movie.id);
        final reviews = appState.reviewsFor(movie.id);

        double avg = 0;
        if (reviews.isNotEmpty) {
          avg = reviews.fold<int>(0, (sum, review) => sum + review.rating) / reviews.length;
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(movie.title),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () => _openPosterViewer(context),
                        child: CachedNetworkImage(
                          imageUrl: movie.imageUrl,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          fadeInDuration: const Duration(milliseconds: 220),
                          placeholder: (context, progress) =>
                              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.40),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 52,
                        right: 16,
                        child: Icon(Icons.zoom_in_outlined, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${movie.genre} • ${movie.duration} • ${movie.platform}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(movie.description, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => appState.toggleWatchlist(movie),
                          icon: Icon(inWatchlist ? Icons.check : Icons.bookmark_add_outlined),
                          label: Text(inWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => appState.toggleWatched(movie),
                          icon: Icon(watched ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          label: Text(watched ? 'Mark as Unwatched' : 'Mark as Watched'),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Text(
                            'Reviews',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (reviews.isNotEmpty)
                            Text('Avg ${avg.toStringAsFixed(1)}', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openReviewDialog(context),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Write a Review'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (reviews.isEmpty)
                        const Text('No reviews yet')
                      else
                        ...reviews.map((review) => _ReviewTile(review: review)),
                      const SizedBox(height: 18),
                      Text(
                        'Similar ${movie.isSeries ? 'Shows' : 'Movies'}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final similar = similarMovies[index];
                      return MovieCard(
                        movie: similar,
                        onTap: () => onOpenMovie(similar.id),
                      );
                    },
                    childCount: similarMovies.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2.3,
                    mainAxisSpacing: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context).formatShortDate(review.createdAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(review.author, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 8),
                Text('• $date', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text('${review.rating}/5'),
              ],
            ),
            const SizedBox(height: 6),
            Text(review.comment),
          ],
        ),
      ),
    );
  }
}

class _PosterViewerDialog extends StatefulWidget {
  const _PosterViewerDialog({required this.imageUrl});

  final String imageUrl;

  @override
  State<_PosterViewerDialog> createState() => _PosterViewerDialogState();
}

class _PosterViewerDialogState extends State<_PosterViewerDialog>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _zoomController;
  Animation<Matrix4>? _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )
      ..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final current = _transformationController.value;
    final isZoomed = current != Matrix4.identity();
    final target = isZoomed
        ? Matrix4.identity()
        : (Matrix4.identity()..scaleByDouble(2.2, 2.2, 2.2, 1));

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: target,
    ).animate(CurvedAnimation(parent: _zoomController, curve: Curves.easeOutCubic));

    _zoomController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          GestureDetector(
            onDoubleTap: _toggleZoom,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1,
              maxScale: 4,
              boundaryMargin: const EdgeInsets.all(24),
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          Positioned(
            top: 38,
            right: 14,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          const Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Pinch to zoom • Drag to pan • Double tap to toggle zoom',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
