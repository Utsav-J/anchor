import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/constants/app_constants.dart';
import '../focus_filter/focus_filter_notifier.dart';
import '../focus_filter/widgets/category_bubble.dart';
import '../onboarding_timing.dart';
import '../quickies/quick_activity_catalog.dart';
import '../quickies/quickies_onboarding_notifier.dart';

class OnboardingRevealScreen extends ConsumerStatefulWidget {
  const OnboardingRevealScreen({super.key});

  @override
  ConsumerState<OnboardingRevealScreen> createState() =>
      _OnboardingRevealScreenState();
}

class _OnboardingRevealScreenState
    extends ConsumerState<OnboardingRevealScreen>
    with TickerProviderStateMixin {
  late final AnimationController _circleCtrl;
  late final Animation<double> _fillAnim;

  final List<_FlyingItem> _items = [];
  int _revealedCount = 0;
  bool _showText1 = false;
  bool _showText2 = false;

  static const _targetPercent = 0.80;

  @override
  void initState() {
    super.initState();

    _circleCtrl = AnimationController(
      vsync: this,
      duration: OnboardingTiming.revealCircleDraw,
    );
    _fillAnim = Tween<double>(begin: 0, end: _targetPercent).animate(
      CurvedAnimation(parent: _circleCtrl, curve: Curves.easeInOut),
    );

    _buildItems();
    _runSequence();
  }

  void _buildItems() {
    // Use quickie activity labels if available, fall back to category names
    final quickiesState = ref.read(quickiesOnboardingProvider);
    final focusConfig = ref.read(activeFocusPriorityProvider);
    final fallbackState = ref.read(focusFilterProvider);
    final categoryNames =
        focusConfig?.orderedCategories ?? fallbackState.selected;

    if (quickiesState.selectedOptionIds.isNotEmpty) {
      for (final id in quickiesState.selectedOptionIds.take(6)) {
        final option = QuickActivityCatalog.optionById(id);
        _items.add(_FlyingItem(
          label: option.label,
          emoji: option.emoji,
          categoryName: option.categoryName,
        ));
      }
    } else {
      for (final name in categoryNames.take(5)) {
        final meta = AppConstants.defaultCategories
            .where((m) => m.name == name)
            .firstOrNull;
        _items.add(_FlyingItem(
          label: name,
          emoji: meta?.defaultEmoji ?? '✨',
          categoryName: name,
        ));
      }
    }
  }

  Future<void> _runSequence() async {
    // Stagger items flying in, then start circle fill
    for (int i = 0; i < _items.length; i++) {
      await Future<void>.delayed(OnboardingTiming.revealItemStagger);
      if (!mounted) return;
      setState(() => _revealedCount = i + 1);
    }

    // Start the circle filling
    await Future<void>.delayed(OnboardingTiming.revealItemFlyIn);
    if (!mounted) return;
    _circleCtrl.forward();

    // Wait for circle to finish, then show text
    await Future<void>.delayed(OnboardingTiming.revealCircleDraw);
    if (!mounted) return;

    await Future<void>.delayed(OnboardingTiming.revealTextDelay);
    if (!mounted) return;
    setState(() => _showText1 = true);

    await Future<void>.delayed(OnboardingTiming.revealTextDelay);
    if (!mounted) return;
    setState(() => _showText2 = true);

    // Auto-advance
    await Future<void>.delayed(
      OnboardingTiming.revealAutoAdvance -
          OnboardingTiming.revealCircleDraw -
          OnboardingTiming.revealTextDelay * 2,
    );
    if (!mounted) return;
    context.go('/onboarding/arrival');
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusConfig = ref.watch(activeFocusPriorityProvider);
    final fallbackState = ref.watch(focusFilterProvider);
    final categoryNames =
        focusConfig?.orderedCategories ?? fallbackState.selected;
    final p1 = categoryNames.isNotEmpty ? categoryNames.first : 'Creative';
    final p1Colors = CategoryBubble.gradientColorsFor(p1, selected: true);

    return Scaffold(
      body: Container(
        color: const Color(0xFFFAF5F0),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flying items + circle
                  SizedBox(
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // The ownership circle
                        AnimatedBuilder(
                          animation: _fillAnim,
                          builder: (context, _) => CircularPercentIndicator(
                            radius: 100,
                            lineWidth: 10,
                            percent: _fillAnim.value,
                            backgroundColor: AppTheme.surfaceContainerHigh,
                            linearGradient: const LinearGradient(
                              colors: [
                                Color(0xFFB02F00),
                                Color(0xFFFF5924),
                              ],
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            center: Text(
                              '${(_fillAnim.value * 100).toStringAsFixed(0)}%',
                              style: AppTheme.notoSerif(
                                fontSize: 42,
                                weight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                        // Flying items
                        for (int i = 0; i < _items.length; i++)
                          if (i < _revealedCount)
                            _FlyingItemWidget(
                              item: _items[i],
                              index: i,
                              total: _items.length,
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedOpacity(
                    duration: OnboardingTiming.revealTextFadeIn,
                    opacity: _showText1 ? 1.0 : 0.0,
                    child: Text(
                      'This is your starting point.',
                      textAlign: TextAlign.center,
                      style: AppTheme.notoSerif(
                        fontSize: 20,
                        weight: FontWeight.w400,
                        color: AppTheme.onSurface.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedOpacity(
                    duration: OnboardingTiming.revealTextFadeIn,
                    opacity: _showText2 ? 1.0 : 0.0,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${(_targetPercent * 100).toStringAsFixed(0)}% owned. Enough to start ',
                            style: AppTheme.notoSerif(
                              fontSize: 18,
                              weight: FontWeight.w300,
                              color: AppTheme.onSurface.withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: p1,
                            style: AppTheme.notoSerif(
                              fontSize: 18,
                              weight: FontWeight.w500,
                              italic: true,
                              color: p1Colors.first,
                              height: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                            style: AppTheme.notoSerif(
                              fontSize: 18,
                              weight: FontWeight.w300,
                              color: AppTheme.onSurface.withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data class for items flying into the circle ──────────────────────────────

class _FlyingItem {
  const _FlyingItem({
    required this.label,
    required this.emoji,
    required this.categoryName,
  });
  final String label;
  final String emoji;
  final String categoryName;
}

// ── Animated widget for a single flying item ─────────────────────────────────

class _FlyingItemWidget extends StatefulWidget {
  const _FlyingItemWidget({
    required this.item,
    required this.index,
    required this.total,
  });
  final _FlyingItem item;
  final int index;
  final int total;

  @override
  State<_FlyingItemWidget> createState() => _FlyingItemWidgetState();
}

class _FlyingItemWidgetState extends State<_FlyingItemWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: OnboardingTiming.revealItemFlyIn,
    )..forward();
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle =
        (widget.index / widget.total) * 2 * math.pi - math.pi / 2;
    const startRadius = 160.0;

    final colors = CategoryBubble.gradientColorsFor(
      widget.item.categoryName,
      selected: true,
    );

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final t = _progress.value;
        final radius = startRadius * (1 - t);
        final x = math.cos(angle) * radius;
        final y = math.sin(angle) * radius;
        final opacity = t < 0.3 ? t / 0.3 : (t > 0.7 ? (1 - t) / 0.3 : 1.0);
        final scale = 1.0 - t * 0.5;

        return Transform.translate(
          offset: Offset(x, y),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.item.emoji,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
