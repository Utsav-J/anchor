import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../shared/models/activity_log.dart';
import '../../shared/models/quick_activity_template.dart';
import '../../shared/models/week_summary.dart';

part 'app_database.g.dart';

// ── Tables ────────────────────────────────────────────────────────────────────

class ActivityLogEntries extends Table {
  TextColumn get id             => text()();
  TextColumn get templateId     => text()();
  TextColumn get categoryName   => text()();
  TextColumn get activityName   => text()();
  TextColumn get emoji          => text()();
  DateTimeColumn get loggedAt   => dateTime()();
  TextColumn get postFieldsJson => text()();
  IntColumn get controlScore    => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class QuickTemplateEntries extends Table {
  TextColumn get id           => text()();
  TextColumn get categoryName => text()();
  TextColumn get activityName => text()();
  TextColumn get emoji        => text()();
  TextColumn get fieldsJson   => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class WeekSummaryEntries extends Table {
  DateTimeColumn get weekStart          => dateTime()();
  RealColumn get ownershipRatio         => real()();
  IntColumn get categoriesLogged        => integer()();
  RealColumn get averageControlScore    => real()();

  @override
  Set<Column<Object>> get primaryKey => {weekStart};
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [ActivityLogEntries, QuickTemplateEntries, WeekSummaryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Activity Logs ──────────────────────────────────────────────────────────

  Future<List<ActivityLog>> getLogsForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final rows = await (select(activityLogEntries)
          ..where(
            (t) =>
                t.loggedAt.isBiggerOrEqualValue(weekStart) &
                t.loggedAt.isSmallerThanValue(weekEnd),
          ))
        .get();
    return rows.map(_rowToLog).toList();
  }

  Future<void> insertLog(ActivityLog log) async {
    await into(activityLogEntries).insertOnConflictUpdate(
      ActivityLogEntriesCompanion.insert(
        id: log.id,
        templateId: log.templateId,
        categoryName: log.categoryName,
        activityName: log.activityName,
        emoji: log.emoji,
        loggedAt: log.loggedAt,
        postFieldsJson: jsonEncode(log.postFields),
        controlScore: log.controlScore,
      ),
    );
  }

  ActivityLog _rowToLog(ActivityLogEntry row) => ActivityLog(
        id: row.id,
        templateId: row.templateId,
        categoryName: row.categoryName,
        activityName: row.activityName,
        emoji: row.emoji,
        loggedAt: row.loggedAt,
        postFields: (jsonDecode(row.postFieldsJson) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v as int)),
        controlScore: row.controlScore,
      );

  // ── Quick Templates ────────────────────────────────────────────────────────

  Future<List<QuickActivityTemplate>> getAllTemplates() async {
    final rows = await select(quickTemplateEntries).get();
    return rows.map(_rowToTemplate).toList();
  }

  Future<void> insertTemplate(QuickActivityTemplate t) async {
    await into(quickTemplateEntries).insertOnConflictUpdate(
      QuickTemplateEntriesCompanion.insert(
        id: t.id,
        categoryName: t.categoryName,
        activityName: t.activityName,
        emoji: t.emoji,
        fieldsJson: jsonEncode(t.fields),
      ),
    );
  }

  Future<void> deleteTemplate(String id) async {
    await (delete(quickTemplateEntries)..where((t) => t.id.equals(id))).go();
  }

  QuickActivityTemplate _rowToTemplate(QuickTemplateEntry row) =>
      QuickActivityTemplate(
        id: row.id,
        categoryName: row.categoryName,
        activityName: row.activityName,
        emoji: row.emoji,
        fields: (jsonDecode(row.fieldsJson) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v as String)),
      );

  // ── Week Summaries ──────────────────────────────────────────────────────────

  Future<List<WeekSummary>> getAllWeekSummaries() async {
    final rows = await (select(weekSummaryEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.weekStart)]))
        .get();
    return rows.map(_rowToSummary).toList();
  }

  Future<void> upsertWeekSummary(WeekSummary summary) async {
    await into(weekSummaryEntries).insertOnConflictUpdate(
      WeekSummaryEntriesCompanion.insert(
        weekStart: summary.weekStart,
        ownershipRatio: summary.ownershipRatio,
        categoriesLogged: summary.categoriesLogged,
        averageControlScore: summary.averageControlScore,
      ),
    );
  }

  WeekSummary _rowToSummary(WeekSummaryEntry row) => WeekSummary(
        weekStart: row.weekStart,
        ownershipRatio: row.ownershipRatio,
        categoriesLogged: row.categoriesLogged,
        averageControlScore: row.averageControlScore,
      );
}

// ── Connection ────────────────────────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'anchor.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Overridden in [main.dart] with the real [AppDatabase] instance.
final dbProvider = Provider<AppDatabase>(
  (_) => throw UnimplementedError('dbProvider must be overridden in main'),
);

/// Pre-loaded activity logs for the current week (set before runApp).
final preloadedLogsProvider = Provider<List<ActivityLog>>((_) => const []);

/// Pre-loaded quick templates (set before runApp).
final preloadedTemplatesProvider =
    Provider<List<QuickActivityTemplate>>((_) => const []);

/// Pre-loaded week-summary history (set before runApp).
final preloadedHistoryProvider = Provider<List<WeekSummary>>((_) => const []);
