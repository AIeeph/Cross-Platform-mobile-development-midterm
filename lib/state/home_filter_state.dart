import 'dart:async';

import '../models/movie.dart';

class HomeFilterState {
  HomeFilterState(this._source) {
    _queryController.stream.listen(_onQueryChanged);
    _resultsController.add(_source);
  }

  final List<Movie> _source;
  final StreamController<String> _queryController = StreamController<String>();
  final StreamController<List<Movie>> _resultsController = StreamController<List<Movie>>.broadcast();

  Stream<List<Movie>> get results => _resultsController.stream;

  void search(String query) {
    _queryController.add(query);
  }

  void _onQueryChanged(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      _resultsController.add(_source);
      return;
    }

    final filtered = _source.where((movie) => movie.title.toLowerCase().contains(normalized)).toList(growable: false);
    _resultsController.add(filtered);
  }

  void dispose() {
    _queryController.close();
    _resultsController.close();
  }
}

