import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/router/app_router.dart';
import 'features/onboarding/focus_filter/focus_filter_notifier.dart';
import 'features/onboarding/onboarding_progress.dart';
import 'shared/models/focus_priority.dart';
import 'shared/models/user_schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load persisted data from SharedPreferences ────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  final config = FocusPriorityConfig.tryDecode(
    prefs.getString('anchor.focus_priorities'),
  );
  final onboardingStage = OnboardingStage.fromString(
    prefs.getString(kOnboardingStagePrefKey),
  );
  final schedule = await UserSchedule.load();

  // ── Open the SQLite database and preload current-week data ────────────────
  final db = AppDatabase();

  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(monday.year, monday.month, monday.day);

  final logs = await db.getLogsForWeek(weekStart);
  final templates = await db.getAllTemplates();
  final history = await db.getAllWeekSummaries();

  runApp(
    ProviderScope(
      overrides: [
        // Navigation
        initialLocationProvider.overrideWithValue(
          OnboardingProgress.initialLocation(
            hasFocusPriorities: config != null,
            stage: onboardingStage,
            hasSchedule: schedule != null,
          ),
        ),
        // Focus priorities (shared_preferences)
        activeFocusPriorityProvider.overrideWith((ref) => config),
        // Schedule
        userScheduleProvider.overrideWith((ref) => schedule),
        // Database
        dbProvider.overrideWithValue(db),
        // Pre-loaded data (avoids empty-flash on first frame)
        preloadedLogsProvider.overrideWithValue(logs),
        preloadedTemplatesProvider.overrideWithValue(templates),
        preloadedHistoryProvider.overrideWithValue(history),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => child ?? const SizedBox.shrink(),
        child: const AnchorApp(),
      ),
    ),
  );
}
