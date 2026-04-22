import 'category_draft.dart';

class WeekDraft {
  const WeekDraft({
    required this.weekStart,
    required this.categories,
  });

  final DateTime weekStart;
  final List<CategoryDraft> categories;

  // ── Computed metrics ─────────────────────────────────────────────────────

  int get categoriesLogged => categories.where((c) => c.isLogged).length;

  double get averageControlScore {
    final logged = categories.where((c) => c.isLogged).toList();
    if (logged.isEmpty) return 0;
    return logged.map((c) => c.controlScore).reduce((a, b) => a + b) /
        logged.length;
  }

  /// Simple unweighted ratio — used as fallback when no priority config exists.
  /// Weighted ownership is computed in [MyWeekNotifier.weightedOwnershipRatio].
  double get ownershipRatio {
    if (categories.isEmpty) return 0;
    return (categoriesLogged / categories.length) *
        (averageControlScore / 10) *
        100;
  }

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  String get weekRangeLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final s = weekStart;
    final e = weekEnd;
    final sm = months[s.month - 1];
    final em = months[e.month - 1];
    if (s.month == e.month) return '$sm ${s.day} – ${e.day}, ${e.year}';
    return '$sm ${s.day} – $em ${e.day}, ${e.year}';
  }

  /// Per-day average control score across all activity logs (Mon=0…Sun=6).
  List<double> get heatmapScores {
    final scores = List.filled(7, 0.0);
    final counts = List.filled(7, 0);
    for (final cat in categories) {
      for (final log in cat.logs) {
        final d = (log.loggedAt.weekday - 1).clamp(0, 6);
        scores[d] += log.controlScore;
        counts[d]++;
      }
    }
    return List.generate(7, (i) => counts[i] > 0 ? scores[i] / counts[i] : 0);
  }

  WeekDraft copyWith({List<CategoryDraft>? categories}) => WeekDraft(
        weekStart: weekStart,
        categories: categories ?? this.categories,
      );
}
