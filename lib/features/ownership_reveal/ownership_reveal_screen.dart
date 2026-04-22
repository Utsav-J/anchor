import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/theme/app_theme.dart';
import '../../features/my_week/my_week_notifier.dart';
import '../../features/my_week/week_history_notifier.dart';
import '../../features/onboarding/focus_filter/focus_filter_notifier.dart';
import '../../shared/models/week_summary.dart';

class OwnershipRevealScreen extends ConsumerWidget {
  const OwnershipRevealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week     = ref.watch(myWeekProvider);
    final config   = ref.watch(activeFocusPriorityProvider);
    final notifier = ref.read(myWeekProvider.notifier);
    final ratio    = notifier.weightedOwnershipRatio(config);
    final pct      = (ratio / 100).clamp(0.0, 1.0);
    final total    = week.categories.length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Ownership Reveal',
            style: AppTheme.notoSerif(fontSize: 18)),
        actions: [
          TextButton.icon(
            onPressed: () => _archiveWeek(context, ref, ratio, week.categoriesLogged),
            icon: const Icon(Icons.archive_outlined, size: 18),
            label: const Text('Archive Week'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accent,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260.r,
                  height: 260.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accent.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                      radius: 0.6,
                    ),
                  ),
                ),
                CircularPercentIndicator(
                  radius: 112.r,
                  lineWidth: 11.w,
                  percent: pct,
                  backgroundColor: AppTheme.surfaceContainerHigh,
                  linearGradient: const LinearGradient(
                    colors: [Color(0xFFB02F00), Color(0xFFFF5924)],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${ratio.toStringAsFixed(0)}%',
                        style: AppTheme.notoSerif(
                            fontSize: 52, weight: FontWeight.w300),
                      ),
                      Text(
                        'PERSONAL AGENCY',
                        style: AppTheme.inter(
                          fontSize: 9,
                          letterSpacing: 1.8,
                          color: AppTheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'You reclaimed time in ${week.categoriesLogged} of $total '
              'categor${total == 1 ? 'y' : 'ies'} this week.',
              textAlign: TextAlign.center,
              style: AppTheme.notoSerif(
                  fontSize: 18,
                  color: AppTheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Future<void> _archiveWeek(
    BuildContext context,
    WidgetRef ref,
    double ratio,
    int categoriesLogged,
  ) async {
    final week = ref.read(myWeekProvider);
    final avgScore = week.categories.isEmpty
        ? 0.0
        : week.categories.map((c) => c.controlScore).reduce((a, b) => a + b) /
            week.categories.length;

    final summary = WeekSummary(
      weekStart: week.weekStart,
      ownershipRatio: ratio,
      categoriesLogged: categoriesLogged,
      averageControlScore: avgScore,
    );

    await ref.read(weekHistoryProvider.notifier).addWeek(summary);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Week archived to history'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
