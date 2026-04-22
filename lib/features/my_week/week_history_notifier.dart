import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../shared/models/week_summary.dart';

final weekHistoryProvider =
    StateNotifierProvider<WeekHistoryNotifier, List<WeekSummary>>((ref) {
  final db      = ref.read(dbProvider);
  final initial = ref.read(preloadedHistoryProvider);
  return WeekHistoryNotifier(db, initial);
});

class WeekHistoryNotifier extends StateNotifier<List<WeekSummary>> {
  WeekHistoryNotifier(this._db, List<WeekSummary> initial) : super(initial);

  final AppDatabase _db;

  Future<void> addWeek(WeekSummary summary) async {
    await _db.upsertWeekSummary(summary);
    // Reload from DB to stay consistent (newest-first, dedup by weekStart).
    state = await _db.getAllWeekSummaries();
  }
}
