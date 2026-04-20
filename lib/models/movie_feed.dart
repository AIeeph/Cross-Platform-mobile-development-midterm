import 'movie.dart';

class MovieFeed {
  const MovieFeed({
    required this.results,
    required this.offset,
    required this.number,
    required this.totalResults,
  });

  final List<Movie> results;
  final int offset;
  final int number;
  final int totalResults;

  factory MovieFeed.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List<dynamic>)
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList();

    return MovieFeed(
      results: list,
      offset: json['offset'] as int,
      number: json['number'] as int,
      totalResults: json['totalResults'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((movie) => movie.toJson()).toList(),
      'offset': offset,
      'number': number,
      'totalResults': totalResults,
    };
  }
}
