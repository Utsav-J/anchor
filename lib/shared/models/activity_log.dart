class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.templateId,
    required this.categoryName,
    required this.activityName,
    required this.emoji,
    required this.loggedAt,
    required this.postFields,
    required this.controlScore,
  });

  final String id;
  final String templateId;
  final String categoryName;
  final String activityName;
  final String emoji;
  final DateTime loggedAt;

  /// Raw post-field values, e.g. {'before': 2, 'after': 4} or {'value': 3}.
  final Map<String, int> postFields;

  /// 1–10 score derived from postFields. Feeds the Ownership Ratio formula.
  final int controlScore;

  static String generateId(String categoryName) =>
      '${categoryName}_log_${DateTime.now().millisecondsSinceEpoch}';

  // ── Score derivation ──────────────────────────────────────────────────────

  /// Derives a 1–10 control score from the raw post-fields for a given category.
  /// Keep this function here so it is the single source of truth.
  static int deriveControlScore(
    String categoryName,
    Map<String, int> postFields,
  ) {
    switch (categoryName) {
      // Dual-slider categories: use 'after' mood value (1–5 → × 2 = 2–10)
      case 'Creative':
      case 'Environment-Shaping':
        final after = postFields['after'] ?? 3;
        return (after * 2).clamp(1, 10);

      // Single 5-point slider: value × 2
      case 'Movement':
      case 'Connection':
        final val = postFields['value'] ?? 3;
        return (val * 2).clamp(1, 10);

      // 3-option pill: None→2, Partial/Slight/Some→5, Significant/Full/Clear→9
      case 'Reflective':
      case 'Skill-Building':
      case 'Future-Oriented':
        final level = postFields['value'] ?? 0;
        return level == 0 ? 2 : level == 1 ? 5 : 9;

      default:
        return 5;
    }
  }
}
