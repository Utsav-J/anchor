import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../features/onboarding/focus_filter/focus_filter_notifier.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/models/activity_log.dart';
import '../../shared/models/category_draft.dart';
import '../../shared/models/focus_priority.dart';
import '../../shared/models/quick_activity_template.dart';
import '../../shared/models/week_draft.dart';

final myWeekProvider =
    StateNotifierProvider<MyWeekNotifier, WeekDraft>((ref) {
  final config    = ref.read(activeFocusPriorityProvider);
  final db        = ref.read(dbProvider);
  final logs      = ref.read(preloadedLogsProvider);
  final templates = ref.read(preloadedTemplatesProvider);
  return MyWeekNotifier(config, db, logs, templates);
});

class MyWeekNotifier extends StateNotifier<WeekDraft> {
  MyWeekNotifier(
    FocusPriorityConfig? config,
    this._db,
    List<ActivityLog> preloadedLogs,
    List<QuickActivityTemplate> preloadedTemplates,
  ) : super(_buildDraft(config, preloadedLogs, preloadedTemplates));

  final AppDatabase _db;

  static DateTime _currentWeekStart() {
    final now    = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  static WeekDraft _buildDraft(
    FocusPriorityConfig? config,
    List<ActivityLog> logs,
    List<QuickActivityTemplate> templates,
  ) {
    final weekStart = _currentWeekStart();

    final metas = config != null
        ? config.orderedCategories
            .map((name) =>
                AppConstants.defaultCategories.firstWhere((c) => c.name == name))
            .toList()
        : AppConstants.defaultCategories;

    final categories = metas.map((m) {
      return CategoryDraft(
        name: m.name,
        templates: templates.where((t) => t.categoryName == m.name).toList(),
        logs: logs
            .where((l) =>
                l.categoryName == m.name &&
                !l.loggedAt.isBefore(weekStart) &&
                l.loggedAt.isBefore(weekStart.add(const Duration(days: 7))))
            .toList(),
      );
    }).toList();

    return WeekDraft(weekStart: weekStart, categories: categories);
  }

  // ── Weighted ownership ratio ───────────────────────────────────────────────

  double weightedOwnershipRatio(FocusPriorityConfig? config) {
    final cats = state.categories;
    if (cats.isEmpty) return 0;
    if (config == null) return state.ownershipRatio;

    final n = cats.length;
    var total = 0.0;
    for (var i = 0; i < n; i++) {
      final weight = FocusPriorityConfig.weightForIndex(i, n);
      final credit = cats[i].isLogged ? 1.0 : 0.0;
      total += weight * credit;
    }
    return (total * 100).clamp(0.0, 100.0);
  }

  // ── Template management ────────────────────────────────────────────────────

  void addTemplate(String categoryName, QuickActivityTemplate template) {
    final idx = _categoryIndex(categoryName);
    if (idx == -1) return;
    final updated = state.categories[idx]
        .copyWith(templates: [...state.categories[idx].templates, template]);
    state = state.copyWith(categories: _replaceAt(idx, updated));
    _db.insertTemplate(template); // fire-and-forget persist
  }

  void removeTemplate(String categoryName, String templateId) {
    final idx = _categoryIndex(categoryName);
    if (idx == -1) return;
    final remaining = state.categories[idx].templates
        .where((t) => t.id != templateId)
        .toList();
    state = state.copyWith(
      categories: _replaceAt(
        idx,
        state.categories[idx].copyWith(templates: remaining),
      ),
    );
    _db.deleteTemplate(templateId); // fire-and-forget persist
  }

  // ── Activity logging ───────────────────────────────────────────────────────

  void logActivity(String categoryName, ActivityLog log) {
    final idx = _categoryIndex(categoryName);
    if (idx == -1) return;
    final updated = state.categories[idx]
        .copyWith(logs: [...state.categories[idx].logs, log]);
    state = state.copyWith(categories: _replaceAt(idx, updated));
    _db.insertLog(log); // fire-and-forget persist
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  int _categoryIndex(String name) =>
      state.categories.indexWhere((c) => c.name == name);

  List<CategoryDraft> _replaceAt(int idx, CategoryDraft updated) {
    final list = List<CategoryDraft>.from(state.categories);
    list[idx] = updated;
    return list;
  }
}
