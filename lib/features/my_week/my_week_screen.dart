import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/constants/app_constants.dart';
import '../my_week/my_week_notifier.dart';
import '../my_week/week_history_notifier.dart';
import '../onboarding/focus_filter/focus_filter_notifier.dart';
import 'widgets/category_card_widget.dart';

class MyWeekScreen extends ConsumerStatefulWidget {
  const MyWeekScreen({super.key});

  @override
  ConsumerState<MyWeekScreen> createState() => _MyWeekScreenState();
}

class _MyWeekScreenState extends ConsumerState<MyWeekScreen> {
  List<bool> _expanded = [];

  @override
  Widget build(BuildContext context) {
    final week = ref.watch(myWeekProvider);
    final notifier = ref.read(myWeekProvider.notifier);
    final config = ref.watch(activeFocusPriorityProvider);
    final history = ref.watch(weekHistoryProvider);

    // Ensure _expanded matches the current number of categories.
    if (_expanded.length != week.categories.length) {
      _expanded = List.filled(week.categories.length, false);
    }

    final ratio = notifier.weightedOwnershipRatio(config);
    final prevRatio =
        history.isNotEmpty ? history.first.ownershipRatio : null;
    final trendDelta = prevRatio != null ? ratio - prevRatio : null;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _MyWeekTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // ── Current cycle header ──────────────────────────────
                    _CycleHeader(
                      label: week.weekRangeLabel,
                      completed: week.categoriesLogged,
                      total: week.categories.length,
                    ),
                    SizedBox(height: 24.h),

                    // ── Stats card ────────────────────────────────────────
                    _StatsCard(
                      ratio: ratio,
                      trendDelta: trendDelta,
                      categoriesLogged: week.categoriesLogged,
                    ),
                    SizedBox(height: 32.h),

                    // ── Daily Pulse label ─────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Daily Pulse',
                          style: AppTheme.notoSerif(
                            fontSize: 22,
                            italic: true,
                          ),
                        ),
                        const Spacer(),
                        _TodayChip(),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Divider(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    SizedBox(height: 16.h),

                    // ── Category cards (only the user's selected categories) ──
                    for (int i = 0; i < week.categories.length; i++) ...[
                      CategoryCardWidget(
                        meta: AppConstants.defaultCategories.firstWhere(
                          (m) => m.name == week.categories[i].name,
                          orElse: () => AppConstants.defaultCategories.first,
                        ),
                        draft: week.categories[i],
                        isExpanded: _expanded[i],
                        onToggle: () =>
                            setState(() => _expanded[i] = !_expanded[i]),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // ── Footer quote ──────────────────────────────────────
                    SizedBox(height: 24.h),
                    Center(
                      child: Text(
                        AppConstants.footerQuote,
                        textAlign: TextAlign.center,
                        style: AppTheme.notoSerif(
                          fontSize: 13,
                          italic: true,
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                          height: 1.6,
                        ),
                      ),
                    ),
                    // Extra clearance for floating glassmorphic nav bar
                    SizedBox(height: 88.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _MyWeekTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      child: Row(
        children: [
          Icon(
            Icons.menu,
            color: AppTheme.onSurface.withValues(alpha: 0.55),
            size: 24.sp,
          ),
          const Spacer(),
          Text('My Week', style: AppTheme.notoSerif(fontSize: 22)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/history'),
            child: Text(
              'History',
              style: AppTheme.notoSerif(
                fontSize: 15,
                italic: true,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final label =
        '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.inter(
              fontSize: 11,
              color: AppTheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.expand_more,
            size: 14.sp,
            color: AppTheme.onSurface.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

// ── Cycle header ──────────────────────────────────────────────────────────────

class _CycleHeader extends StatelessWidget {
  const _CycleHeader({
    required this.label,
    required this.completed,
    required this.total,
  });
  final String label;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT CYCLE',
          style: AppTheme.inter(
            fontSize: 10,
            letterSpacing: 1.2,
            color: AppTheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    AppTheme.notoSerif(fontSize: 22, weight: FontWeight.w500),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                  Text(
                    '$completed/$total Completed',
                  style: AppTheme.notoSerif(
                    fontSize: 15,
                    italic: true,
                    color: AppTheme.accent,
                  ),
                ),
                SizedBox(height: 6.h),
                SizedBox(
                  width: 120.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? completed / total : 0,
                      minHeight: 5,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.ratio,
    required this.trendDelta,
    required this.categoriesLogged,
  });

  final double ratio;
  final double? trendDelta;
  final int categoriesLogged;

  @override
  Widget build(BuildContext context) {
    final pct = (ratio / 100).clamp(0.0, 1.0);
    final trendText = _trendText(trendDelta);
    final trendColor = _trendColor(trendDelta);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ownership Ratio',
                  style: AppTheme.inter(
                      fontSize: 14, weight: FontWeight.w500),
                ),
                SizedBox(height: 6.h),
                Text(
                  categoriesLogged == 0
                      ? 'Log your first activity below.'
                      : 'You are controlling ${ratio.toStringAsFixed(0)}% of your time this week.',
                  style: AppTheme.inter(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                if (trendDelta != null)
                  Row(
                    children: [
                      Text(
                        trendText,
                        style: AppTheme.inter(
                          fontSize: 20,
                          weight: FontWeight.w700,
                          color: trendColor,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'vs last week',
                        style: AppTheme.inter(
                            fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  )
                else
                  Text(
                    '— first week',
                    style: AppTheme.inter(
                        fontSize: 12, color: AppTheme.textMuted),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          CircularPercentIndicator(
            radius: 52.r,
            lineWidth: 7.w,
            percent: pct,
            backgroundColor: AppTheme.surfaceContainerLow,
            linearGradient: const LinearGradient(
              colors: [Color(0xFFB02F00), Color(0xFFFF5924)],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            center: Text(
              '${ratio.toStringAsFixed(0)}%',
              style: AppTheme.notoSerif(fontSize: 18, weight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _trendText(double? delta) {
    if (delta == null) return '';
    if (delta.abs() < 0.5) return '—';
    return '${delta > 0 ? '↑' : '↓'} ${delta.abs().toStringAsFixed(1)}%';
  }

  Color _trendColor(double? delta) {
    if (delta == null || delta.abs() < 0.5) return AppTheme.textMuted;
    return delta > 0
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);
  }
}
