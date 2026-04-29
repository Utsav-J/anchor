import 'dart:math' as math;

import 'package:bubble_picker/bubble_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/liquid_glass_action_button.dart';
import '../focus_filter/focus_filter_notifier.dart';
import '../focus_filter/widgets/category_bubble.dart';
import '../onboarding_progress.dart';
import 'quick_activity_catalog.dart';
import 'quickies_onboarding_notifier.dart';

// Same virtual canvas as BubbleCanvas so physics feel identical on both screens.
const _kVirtualSize = Size(400, 800);

// radius formula: actualPixelRadius = data.radius * 20 + 20
// 0.8 → 36px radius (72px diameter)
const _kActivityBubbleRadius = 0.8;

class QuickiesOnboardingScreen extends ConsumerWidget {
  const QuickiesOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusConfig = ref.watch(activeFocusPriorityProvider);
    final fallbackFocusState = ref.watch(focusFilterProvider);
    final selectedNames =
        focusConfig?.orderedCategories ?? fallbackFocusState.selected;
    final categories = QuickActivityCatalog.categoriesFor(selectedNames);
    final quickiesState = ref.watch(quickiesOnboardingProvider);
    final quickiesNotifier = ref.read(quickiesOnboardingProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 42, 24, 132),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTheme.notoSerif(
                              fontSize: 34,
                              weight: FontWeight.w700,
                              height: 1.08,
                            ),
                            children: [
                              const TextSpan(text: 'Choose your '),
                              TextSpan(
                                text: 'quickies',
                                style: AppTheme.notoSerif(
                                  fontSize: 34,
                                  weight: FontWeight.w700,
                                  italic: true,
                                  color: AppTheme.primary,
                                  height: 1.08,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap a focus bubble to pick quick activities.',
                          textAlign: TextAlign.center,
                          style: AppTheme.inter(
                            fontSize: 14,
                            height: 1.35,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: quickiesState.feedbackMessage == null
                              ? const SizedBox(height: 0)
                              : Padding(
                                  key: ValueKey(quickiesState.feedbackMessage),
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    quickiesState.feedbackMessage!,
                                    textAlign: TextAlign.center,
                                    style: AppTheme.inter(
                                      fontSize: 13,
                                      weight: FontWeight.w800,
                                      color: AppTheme.primary,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 36),
                        Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 14,
                          children: [
                            for (var i = 0; i < categories.length; i++)
                              _QuickiesCategoryCircle(
                                category: categories[i],
                                priority: i + 1,
                                totalSelected: categories.length,
                                onTap: () => quickiesNotifier.openCategory(
                                  categories[i].name,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _QuickiesBottomBar(
                selectedCount: quickiesState.selectedOptionIds.length,
                onFinish: () => _finishOnboarding(context, ref),
                onSkip: () => _skipOnboarding(context),
              ),
            ),
            if (quickiesState.openCategoryName != null)
              _ExpandedCategoryPanel(
                category: categories.firstWhere(
                  (c) => c.name == quickiesState.openCategoryName,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishOnboarding(BuildContext context, WidgetRef ref) async {
    final templates =
        ref.read(quickiesOnboardingProvider.notifier).selectedTemplates();
    final db = ref.read(dbProvider);

    for (final template in templates) {
      await db.insertTemplate(template);
    }

    ref.read(onboardingQuickTemplatesProvider.notifier).state = templates;
    await OnboardingProgress.saveStage(OnboardingStage.complete);

    if (context.mounted) {
      context.go('/home');
    }
  }

  Future<void> _skipOnboarding(BuildContext context) async {
    await OnboardingProgress.saveStage(OnboardingStage.complete);
    if (context.mounted) {
      context.go('/home');
    }
  }
}

// ── Category circles (main screen) ───────────────────────────────────────────

class _QuickiesCategoryCircle extends StatelessWidget {
  const _QuickiesCategoryCircle({
    required this.category,
    required this.priority,
    required this.totalSelected,
    required this.onTap,
  });

  final QuickActivityCategory category;
  final int priority;
  final int totalSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = AppConstants.defaultCategories.firstWhere(
      (m) => m.name == category.name,
    );

    return Hero(
      tag: 'onboarding-category-${category.name}',
      child: CategoryBubble(
        meta: meta,
        priority: priority,
        totalSelected: totalSelected,
        onTap: onTap,
        onLongPress: onTap,
      ),
    );
  }
}

// ── Expanded activity selection panel ─────────────────────────────────────────

class _ExpandedCategoryPanel extends ConsumerStatefulWidget {
  const _ExpandedCategoryPanel({required this.category});

  final QuickActivityCategory category;

  @override
  ConsumerState<_ExpandedCategoryPanel> createState() =>
      _ExpandedCategoryPanelState();
}

class _ExpandedCategoryPanelState
    extends ConsumerState<_ExpandedCategoryPanel> {
  @override
  Widget build(BuildContext context) {
    final quickiesState = ref.watch(quickiesOnboardingProvider);
    final notifier = ref.read(quickiesOnboardingProvider.notifier);

    // Count how many activities from this category are selected.
    final allOptions =
        QuickActivityCatalog.optionsForCategory(widget.category.name);
    final selectedCount =
        allOptions.where((o) => quickiesState.isSelected(o.id)).length;

    final gradientColors = CategoryBubble.gradientColorsFor(
      widget.category.name,
      selected: true,
    );

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                children: [
                  ClipPath(
                    clipper: _CircleRevealClipper(progress: value),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.96 + value * 0.04,
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  ),
                ],
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
                  child: Row(
                    children: [
                      LiquidGlassActionButton(
                        compact: true,
                        height: 38,
                        width: 104,
                        label: 'Close',
                        icon: Icons.close_rounded,
                        onTap: notifier.closeCategory,
                      ),
                      const Spacer(),
                      LiquidGlassCircleButton(
                        icon: Icons.check_rounded,
                        semanticLabel:
                            'Save ${widget.category.name} quickies',
                        enabled: selectedCount > 0,
                        size: 42,
                        onTap: () => _saveCategorySelection(
                          ref,
                          widget.category.name,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category title + description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        widget.category.name,
                        textAlign: TextAlign.center,
                        style: AppTheme.notoSerif(
                          fontSize: 36,
                          weight: FontWeight.w700,
                          italic: true,
                          color: AppTheme.primary,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.category.headline,
                        textAlign: TextAlign.center,
                        style: AppTheme.inter(
                          fontSize: 14,
                          height: 1.4,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.category.prompt,
                        textAlign: TextAlign.center,
                        style: AppTheme.inter(
                          fontSize: 11,
                          weight: FontWeight.w600,
                          color: AppTheme.onSurface.withValues(alpha: 0.5),
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),

                // Activity bubbles (BubblePicker) — fills remaining space.
                // Same virtual canvas & OverflowBox trick as BubbleCanvas so
                // the physics feel identical to the focus-filter screen.
                Expanded(
                  child: ClipRect(
                    child: OverflowBox(
                      maxWidth: _kVirtualSize.width,
                      maxHeight: _kVirtualSize.height,
                      alignment: Alignment.center,
                      child: BubblePicker(
                        size: _kVirtualSize,
                        bubbles: [
                          for (final option in allOptions)
                            _buildActivityBubble(
                              option,
                              widget.category.name,
                              notifier,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BubbleData _buildActivityBubble(
    QuickActivityOption option,
    String categoryName,
    QuickiesOnboardingNotifier notifier,
  ) {
    return BubbleData(
      color: Colors.transparent,
      radius: _kActivityBubbleRadius,
      child: Consumer(
        builder: (_, ref, _) {
          final isSelected =
              ref.watch(quickiesOnboardingProvider).isSelected(option.id);
          return _ActivityBubbleContent(
            option: option,
            categoryName: categoryName,
            isSelected: isSelected,
          );
        },
      ),
      onTapBubble: (_) => notifier.toggleOption(option.id),
    );
  }

  Future<void> _saveCategorySelection(
    WidgetRef ref,
    String categoryName,
  ) async {
    final notifier = ref.read(quickiesOnboardingProvider.notifier);
    final templates = notifier.selectedTemplatesForCategory(categoryName);
    final db = ref.read(dbProvider);

    for (final template in templates) {
      await db.insertTemplate(template);
    }

    final existing = ref.read(onboardingQuickTemplatesProvider);
    final byId = {
      for (final t in existing) t.id: t,
      for (final t in templates) t.id: t,
    };
    ref.read(onboardingQuickTemplatesProvider.notifier).state =
        byId.values.toList(growable: false);

    notifier.saveOpenCategorySelection();
  }
}

// ── Activity bubble visual ────────────────────────────────────────────────────

class _ActivityBubbleContent extends StatelessWidget {
  const _ActivityBubbleContent({
    required this.option,
    required this.categoryName,
    required this.isSelected,
  });

  final QuickActivityOption option;
  final String categoryName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        CategoryBubble.gradientColorsFor(categoryName, selected: isSelected);

    return SizedBox.expand(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? gradientColors.last.withValues(alpha: 0.22)
                  : AppTheme.onSurface.withValues(alpha: 0.04),
              blurRadius: isSelected ? 18 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 15, height: 1),
                ),
                const SizedBox(height: 3),
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.inter(
                    fontSize: 7.5,
                    weight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: AppTheme.onSurface.withValues(
                      alpha: isSelected ? 0.9 : 0.7,
                    ),
                    height: 1.15,
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 10,
                      color: AppTheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _QuickiesBottomBar extends StatelessWidget {
  const _QuickiesBottomBar({
    required this.selectedCount,
    required this.onFinish,
    required this.onSkip,
  });

  final int selectedCount;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surface.withValues(alpha: 0),
            AppTheme.surface.withValues(alpha: 0.92),
            AppTheme.surface,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              selectedCount == 0
                  ? 'Add a few quick activities or skip for now'
                  : '$selectedCount quick activities selected',
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                fontSize: 12,
                color: AppTheme.onSurface.withValues(alpha: 0.48),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: LiquidGlassActionButton(
                  label: 'Finish Onboarding',
                  icon: Icons.arrow_forward_rounded,
                  onTap: onFinish,
                ),
              ),
              const SizedBox(width: 12),
              LiquidGlassCircleButton(
                icon: Icons.skip_next_rounded,
                semanticLabel: 'Skip quickies onboarding',
                onTap: onSkip,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Circle reveal clipper ─────────────────────────────────────────────────────

class _CircleRevealClipper extends CustomClipper<Path> {
  const _CircleRevealClipper({required this.progress});

  final double progress;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height * 0.34);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    return Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: maxRadius * progress),
      );
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}
