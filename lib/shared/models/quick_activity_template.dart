class QuickActivityTemplate {
  const QuickActivityTemplate({
    required this.id,
    required this.categoryName,
    required this.activityName,
    required this.emoji,
    required this.fields,
  });

  final String id;
  final String categoryName;
  final String activityName;
  final String emoji;
  /// Category-specific enum selections, e.g. {'depthLevel': 'Focused'}.
  final Map<String, String> fields;

  static String generateId(String categoryName) =>
      '${categoryName}_${DateTime.now().millisecondsSinceEpoch}';
}
