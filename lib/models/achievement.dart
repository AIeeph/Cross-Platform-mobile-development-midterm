class Achievement {
  const Achievement({
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
  });

  final String title;
  final String description;
  final int progress;
  final int target;

  bool get unlocked => progress >= target;
}
