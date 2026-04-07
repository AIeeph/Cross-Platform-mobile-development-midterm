import 'package:flutter/material.dart';

import '../data/movie_repository.dart';
import '../models/watch_plan.dart';
import '../state/app_state.dart';

class WatchPlannerScreen extends StatefulWidget {
  const WatchPlannerScreen({
    super.key,
    required this.appState,
    required this.repository,
  });

  final AppState appState;
  final MovieRepository repository;

  @override
  State<WatchPlannerScreen> createState() => _WatchPlannerScreenState();
}

class _WatchPlannerScreenState extends State<WatchPlannerScreen> {
  final Set<int> _selectedSegment = <int>{0};
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDate: _selectedDate ?? now,
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _submit() {
    final watchlist = widget.appState.watchlistItems(widget.repository.getAllSync());
    if (watchlist.isEmpty || _nameController.text.trim().isEmpty || _selectedDate == null || _selectedTime == null) {
      return;
    }

    final time = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    widget.appState.submitPlan(
      WatchPlan(
        viewerName: _nameController.text.trim(),
        watchMode: _selectedSegment.first == 0 ? 'Solo Night' : 'Watch Party',
        date: _selectedDate!,
        time: time,
        movieTitles: watchlist.map((movie) => movie.title).toList(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Watch plan saved')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = widget.appState.watchlistItems(widget.repository.getAllSync());
    final dateText = _selectedDate == null
        ? 'Select date'
        : MaterialLocalizations.of(context).formatShortDate(_selectedDate!);
    final timeText = _selectedTime == null ? 'Select time' : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Watch Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Plan Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(value: 0, label: Text('Solo Night'), icon: Icon(Icons.home_outlined)),
                ButtonSegment<int>(value: 1, label: Text('Watch Party'), icon: Icon(Icons.groups_outlined)),
              ],
              selected: _selectedSegment,
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedSegment
                    ..clear()
                    ..addAll(selection);
                });
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Viewer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(dateText),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time_outlined),
                    label: Text(timeText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Watchlist', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (watchlist.isEmpty)
              const Text('No titles added yet')
            else
              ...watchlist.map(
                (movie) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(movie.title),
                  subtitle: Text('Group size: ${widget.appState.partySizeFor(movie.id)}'),
                  trailing: IconButton(
                    onPressed: () => widget.appState.removeFromWatchlist(movie),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
