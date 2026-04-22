import 'activity_log.dart';
import 'quick_activity_template.dart';

class CategoryDraft {
  const CategoryDraft({
    required this.name,
    required this.templates,
    required this.logs,
  });

  final String name;
  final List<QuickActivityTemplate> templates;
  final List<ActivityLog> logs;

  /// Counts toward the Ownership Ratio once at least one activity is logged.
  bool get isLogged => logs.isNotEmpty;

  /// Uses the last log's derived score (1–10). 0 if nothing logged yet.
  int get controlScore => logs.isEmpty ? 0 : logs.last.controlScore;

  CategoryDraft copyWith({
    List<QuickActivityTemplate>? templates,
    List<ActivityLog>? logs,
  }) =>
      CategoryDraft(
        name: name,
        templates: templates ?? this.templates,
        logs: logs ?? this.logs,
      );
}
