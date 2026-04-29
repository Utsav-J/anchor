import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/models/week_summary.dart';
import '../my_week/my_week_notifier.dart';
import '../my_week/week_history_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(myWeekProvider);
    final history = ref.watch(weekHistoryProvider);

    final ratio = week.ownershipRatio;
    final heatmap = week.heatmapScores;
    final lastFour = history.take(4).toList();
    final prevRatio = history.isNotEmpty ? history.first.ownershipRatio : null;
    final trendDelta = prevRatio != null ? (ratio - prevRatio) : null;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _HomeTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 28.h),

                    // ── Week label ─────────────────────────────────────────
                    Text(
                      week.weekRangeLabel,
                      style: AppTheme.inter(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        color: AppTheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Current Ownership',
                      style: AppTheme.notoSerif(
                        fontSize: 15,
                        color: AppTheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // ── Hero ring ─────────────────────────────────────────
                    _OwnershipHero(ratio: ratio, trendDelta: trendDelta),
                    SizedBox(height: 28.h),

                    // ── CTA ───────────────────────────────────────────────
                    _buildCta(week.categoriesLogged, context),
                    SizedBox(height: 40.h),

                    // ── Daily Pulse heatmap ───────────────────────────────
                    _SectionHeader(left: 'Daily Pulse', right: 'LAST 7 DAYS'),
                    SizedBox(height: 14.h),
                    _HeatmapRow(scores: heatmap),
                    SizedBox(height: 40.h),

                    // ── Last 4 weeks ──────────────────────────────────────
                    _SectionHeader(left: 'Last 4 weeks at a glance'),
                    SizedBox(height: 14.h),
                    _LastFourGrid(weeks: lastFour),
                    SizedBox(height: 40.h),

                    // ── Privacy footer ────────────────────────────────────
                    _PrivacyFooter(),
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

// ── Top app bar ──────────────────────────────────────────────────────────────

class _HomeTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Anchor',
            style: AppTheme.notoSerif(
              fontSize: 22,
              italic: true,
              weight: FontWeight.w500,
            ),
          ),
          // const Spacer(),
        ],
      ),
    );
  }
}

// ── Hero section ─────────────────────────────────────────────────────────────

class _OwnershipHero extends StatelessWidget {
  const _OwnershipHero({required this.ratio, required this.trendDelta});

  final double ratio;
  final double? trendDelta;

  @override
  Widget build(BuildContext context) {
    final pct = (ratio / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        // Glow + ring
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
                      fontSize: 52,
                      weight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 2.h),
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

        SizedBox(height: 20.h),

        // "of this week felt like yours"
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTheme.notoSerif(
              fontSize: 17,
              color: AppTheme.onSurface.withValues(alpha: 0.55),
              height: 1.5,
            ),
            children: [
              const TextSpan(text: '...of this week '),
              TextSpan(
                text: 'felt like yours',
                style: AppTheme.notoSerif(
                  fontSize: 17,
                  italic: true,
                  weight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),

        // Trend badge
        if (trendDelta != null) ...[
          SizedBox(height: 10.h),
          _TrendBadge(delta: trendDelta!),
        ],
      ],
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.delta});
  final double delta;

  @override
  Widget build(BuildContext context) {
    final isUp = delta > 0;
    final isFlat = delta.abs() < 0.5;
    final arrow = isFlat ? '—' : (isUp ? '↑' : '↓');
    final color = isFlat
        ? AppTheme.textMuted
        : (isUp ? const Color(0xFF2E7D32) : const Color(0xFFC62828));
    final label = isFlat
        ? 'same as last week'
        : '${delta.abs().toStringAsFixed(1)}%  vs last week';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$arrow ',
          style: AppTheme.inter(
            fontSize: 16,
            weight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.inter(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

// ── CTA button ───────────────────────────────────────────────────────────────

Widget _buildCta(int categoriesLogged, BuildContext context) {
  if (categoriesLogged > 0) {
    return Column(
      children: [
        _OrangePillButton(
          label: 'View This Week\'s Summary',
          icon: Icons.bar_chart_rounded,
          onTap: () => context.push('/ownership-reveal'),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () => context.go('/my-week'),
          child: Text(
            'Continue Check-in',
            style: AppTheme.notoSerif(
              fontSize: 14,
              italic: true,
              color: AppTheme.accent,
            ),
          ),
        ),
      ],
    );
  }

  return _OrangePillButton(
    label: 'Do This Week\'s Check-in',
    icon: Icons.arrow_forward,
    onTap: () => context.go('/my-week'),
  );
}

class _OrangePillButton extends StatelessWidget {
  const _OrangePillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB02F00), Color(0xFFFF5924)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.inter(
                fontSize: 15,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10.w),
            Icon(icon, color: Colors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.left, this.right});
  final String left;
  final String? right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          left,
          style: AppTheme.notoSerif(fontSize: 20, weight: FontWeight.w500),
        ),
        const Spacer(),
        if (right != null)
          Text(
            right!,
            style: AppTheme.inter(
              fontSize: 10,
              letterSpacing: 0.8,
              color: AppTheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
      ],
    );
  }
}

// ── 7-day heatmap ─────────────────────────────────────────────────────────────

class _HeatmapRow extends StatelessWidget {
  const _HeatmapRow({required this.scores});
  final List<double> scores; // 0.0–10.0 per day

  static const _labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0=Mon…6=Sun

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final score = scores[i];
          final isEmpty = score == 0;
          final isToday = i == today;

          Color fill;
          if (isEmpty) {
            fill = AppTheme.surfaceContainerLow;
          } else {
            fill = AppTheme.accent.withValues(
              alpha: (score / 10).clamp(0.15, 1.0),
            );
          }

          return Column(
            children: [
              Text(
                _labels[i],
                style: AppTheme.inter(
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: isToday
                      ? AppTheme.accent
                      : AppTheme.onSurface.withValues(alpha: 0.38),
                  weight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(8.r),
                  border: isToday
                      ? Border.all(
                          color: AppTheme.accent.withValues(alpha: 0.5),
                          width: 1.5,
                        )
                      : null,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Last 4 weeks grid ─────────────────────────────────────────────────────────

class _LastFourGrid extends StatelessWidget {
  const _LastFourGrid({required this.weeks});
  final List<WeekSummary> weeks;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.1,
      children: [
        for (int i = 0; i < 4; i++)
          i < weeks.length ? _WeekCard(summary: weeks[i]) : _WeekCardEmpty(),
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.summary});
  final WeekSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${summary.ownershipRatio.toStringAsFixed(0)}%',
            style: AppTheme.notoSerif(fontSize: 32, weight: FontWeight.w400),
          ),
          SizedBox(height: 4.h),
          Text(
            'WEEK ${summary.weekNumber}',
            style: AppTheme.inter(
              fontSize: 10,
              letterSpacing: 0.8,
              color: AppTheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            summary.weekRangeLabel,
            style: AppTheme.inter(
              fontSize: 9,
              color: AppTheme.onSurface.withValues(alpha: 0.45),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeekCardEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '—',
            style: AppTheme.notoSerif(
              fontSize: 28,
              color: AppTheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'NO DATA YET',
            style: AppTheme.inter(
              fontSize: 9,
              letterSpacing: 0.8,
              color: AppTheme.onSurface.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Privacy footer ────────────────────────────────────────────────────────────

class _PrivacyFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 14.sp,
            color: AppTheme.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            'Your data lives only on this phone',
            style: AppTheme.inter(
              fontSize: 11,
              color: AppTheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
