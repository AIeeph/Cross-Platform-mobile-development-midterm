import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../state/app_state.dart';
import 'watchlist_control.dart';

class MovieQuickSheet extends StatefulWidget {
  const MovieQuickSheet({
    super.key,
    required this.movie,
    required this.appState,
    required this.scrollController,
    required this.onOpenDetails,
  });

  final Movie movie;
  final AppState appState;
  final ScrollController scrollController;
  final VoidCallback onOpenDetails;

  @override
  State<MovieQuickSheet> createState() => _MovieQuickSheetState();
}

class _MovieQuickSheetState extends State<MovieQuickSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  bool _showPulse = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 1.25), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic));

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      }
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {
          _showPulse = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePosterDoubleTap() {
    widget.appState.toggleWatchlist(widget.movie);
    setState(() {
      _showPulse = true;
    });
    _pulseController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final watched = widget.appState.isWatched(widget.movie.id);
    final inWatchlist = widget.appState.isInWatchlist(widget.movie.id);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (widget.movie.rating >= 8.8)
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
          GestureDetector(
            onDoubleTap: _handlePosterDoubleTap,
            onLongPress: widget.onOpenDetails,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 240,
                    color: Colors.black,
                    child: CachedNetworkImage(
                      imageUrl: widget.movie.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      fadeInDuration: const Duration(milliseconds: 220),
                      placeholder: (context, progress) => const SizedBox(
                        height: 240,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 240,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
                if (_showPulse)
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          inWatchlist ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Double tap poster to toggle favourite • Long press to open details',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(widget.movie.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('${widget.movie.genre} • ${widget.movie.duration} • ${widget.movie.platform}'),
          const SizedBox(height: 10),
          Text(widget.movie.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          WatchlistControl(
            onAdd: (partySize) {
              widget.appState.addToWatchlist(widget.movie, partySize: partySize);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.movie.title} added to watchlist')),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => widget.appState.toggleWatched(widget.movie),
              icon: Icon(watched ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              label: Text(watched ? 'Mark as Unwatched' : 'Mark as Watched'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onOpenDetails,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Full Details'),
            ),
          ),
        ],
      ),
    );
  }
}
