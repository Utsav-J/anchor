import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../features/my_week/week_history_notifier.dart';
import '../../shared/models/week_summary.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(weekHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('History', style: AppTheme.notoSerif(fontSize: 20)),
      ),
      body: history.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
              itemCount: history.length,
              itemBuilder: (context, i) => _WeekTile(summary: history[i]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 52.sp,
              color: AppTheme.onSurface.withValues(alpha: 0.18),
            ),
            SizedBox(height: 16.h),
            Text(
              'No completed weeks yet',
              style: AppTheme.notoSerif(
                fontSize: 18,
                color: AppTheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your weekly ownership scores will appear here after you complete a week.',
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({required this.summary});

  final WeekSummary summary;

  @override
  Widget build(BuildContext context) {
    final pct = summary.ownershipRatio.clamp(0.0, 100.0);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: AppTheme.cardDecoration(color: AppTheme.surfaceContainerLow),
      child: Row(
        children: [
          // ── Percentage circle ──────────────────────────────────────────
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: -1.5708, // -π/2 → start from top
                endAngle:   -1.5708 + 6.2832 * (pct / 100),
                colors: [AppTheme.accent, AppTheme.primary],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceContainerLow,
              ),
              alignment: Alignment.center,
              child: Text(
                '${pct.toStringAsFixed(0)}%',
                style: AppTheme.inter(
                  fontSize: 11,
                  weight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // ── Week label and stats ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week ${summary.weekNumber}  ·  ${summary.weekRangeLabel}',
                  style: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${summary.categoriesLogged} categor${summary.categoriesLogged == 1 ? 'y' : 'ies'} logged  ·  '
                  'avg score ${summary.averageControlScore.toStringAsFixed(1)}',
                  style: AppTheme.inter(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
