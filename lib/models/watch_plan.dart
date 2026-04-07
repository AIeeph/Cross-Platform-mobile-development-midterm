class WatchPlan {
  const WatchPlan({
    required this.viewerName,
    required this.watchMode,
    required this.date,
    required this.time,
    required this.movieTitles,
  });

  final String viewerName;
  final String watchMode;
  final DateTime date;
  final DateTime time;
  final List<String> movieTitles;
}
