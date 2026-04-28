class LiveTitle {
  const LiveTitle({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.genres,
    required this.rating,
    required this.summary,
    required this.kind,
  });

  final String id;
  final String name;
  final String imageUrl;
  final List<String> genres;
  final double rating;
  final String summary;
  final String kind;
}

