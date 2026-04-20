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

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'].toString(),
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      genre: json['genre'] as String,
      rating: (json['rating'] as num).toDouble(),
      duration: json['duration'] as String,
      description: json['description'] as String,
      platform: json['platform'] as String,
      isSeries: json['isSeries'] as bool,
      isTrending: json['isTrending'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'genre': genre,
      'rating': rating,
      'duration': duration,
      'description': description,
      'platform': platform,
      'isSeries': isSeries,
      'isTrending': isTrending,
    };
  }
}
