import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/live_title.dart';

class LiveCatalogService {
  const LiveCatalogService();

  Future<List<LiveTitle>> fetchLiveTrending() async {
    final uri = Uri.parse('https://api.tvmaze.com/shows?page=1');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Live catalog request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.take(12).map((raw) {
      final item = raw as Map<String, dynamic>;
      final image = item['image'] as Map<String, dynamic>?;
      final ratingMap = item['rating'] as Map<String, dynamic>?;
      final rating = (ratingMap?['average'] as num?)?.toDouble() ?? 0.0;
      final summaryRaw = (item['summary'] as String?) ?? '';
      final summary = summaryRaw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      final genres = (item['genres'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();

      return LiveTitle(
        id: item['id'].toString(),
        name: (item['name'] as String?) ?? 'Unknown',
        imageUrl: (image?['original'] as String?) ?? (image?['medium'] as String?) ?? '',
        genres: genres,
        rating: rating,
        summary: summary,
        kind: (item['type'] as String?) ?? 'Show',
      );
    }).toList(growable: false);
  }
}

