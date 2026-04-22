class WeekSummary {
  const WeekSummary({
    required this.weekStart,
    required this.ownershipRatio,
    required this.categoriesLogged,
    required this.averageControlScore,
  });

  final DateTime weekStart;
  final double ownershipRatio;
  final int categoriesLogged;
  final double averageControlScore;

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  String get weekRangeLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final s = weekStart;
    final e = weekEnd;
    final sm = months[s.month - 1];
    final em = months[e.month - 1];
    if (s.month == e.month) return '$sm ${s.day} – ${e.day}';
    return '$sm ${s.day} – $em ${e.day}';
  }

  /// ISO week number (approximate).
  int get weekNumber {
    final thursday = weekStart.add(Duration(days: 3));
    final jan4 = DateTime(thursday.year, 1, 4);
    final firstThursday = jan4.subtract(Duration(days: jan4.weekday - 1 + 3));
    return 1 + thursday.difference(firstThursday).inDays ~/ 7;
  }
}
