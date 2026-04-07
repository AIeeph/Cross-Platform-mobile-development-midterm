class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.genre,
    required this.rating,
    required this.duration,
    required this.description,
    required this.platform,
    required this.isSeries,
    required this.isTrending,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String genre;
  final double rating;
  final String duration;
  final String description;
  final String platform;
  final bool isSeries;
  final bool isTrending;
}
