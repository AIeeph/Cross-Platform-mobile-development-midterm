import 'package:flutter/material.dart';

class WatchlistControl extends StatefulWidget {
  const WatchlistControl({
    super.key,
    required this.onAdd,
  });

  final ValueChanged<int> onAdd;

  @override
  State<WatchlistControl> createState() => _WatchlistControlState();
}

class _WatchlistControlState extends State<WatchlistControl> {
  int _partySize = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            setState(() {
              if (_partySize > 1) {
                _partySize--;
              }
            });
          },
          tooltip: 'Decrease group size',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Text(
            'Group: $_partySize',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _partySize++;
            });
          },
          tooltip: 'Increase group size',
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => widget.onAdd(_partySize),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: const Text('Add to Watchlist'),
        ),
      ],
    );
  }
}
