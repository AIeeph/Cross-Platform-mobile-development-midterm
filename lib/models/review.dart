class Review {
  const Review({
    required this.author,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  final String author;
  final String comment;
  final int rating;
  final DateTime createdAt;
}
