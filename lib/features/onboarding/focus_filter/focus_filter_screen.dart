import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../onboarding_progress.dart';
import '../../../shared/models/focus_priority.dart';
import '../../../shared/widgets/liquid_glass_action_button.dart';
import 'focus_filter_notifier.dart';
import 'widgets/bubble_canvas.dart';
import 'widgets/focus_list_panel.dart';

/// Visual top inset for [FocusListPanel] so content clears the floating glass header.
const double _kFocusListTopInset = 118;

class FocusFilterScreen extends ConsumerStatefulWidget {
  const FocusFilterScreen({super.key});

  @override
  ConsumerState<FocusFilterScreen> createState() => _FocusFilterScreenState();
}

class _FocusFilterScreenState extends ConsumerState<FocusFilterScreen> {
  bool _isContinuing = false;

  Future<void> _continueToQuickies(FocusFilterNotifier notifier) async {
    if (_isContinuing) return;

    setState(() => _isContinuing = true);
    await Future<void>.delayed(const Duration(milliseconds: 430));

    final config = await notifier.saveAndComplete();
    if (!mounted) return;

    ref.read(activeFocusPriorityProvider.notifier).state = config;
    await OnboardingProgress.saveStage(OnboardingStage.quickies);
    if (!mounted) return;

    context.go('/onboarding/quickies');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusFilterProvider);
    final notifier = ref.read(focusFilterProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: state.viewMode == FocusViewMode.bubble
                    ? BubbleCanvas(
                        key: const ValueKey('bubble'),
                        isExiting: _isContinuing,
                      )
                    : Padding(
                        key: const ValueKey('list'),
                        padding: const EdgeInsets.only(
                          top: _kFocusListTopInset,
                        ),
                        child: const FocusListPanel(),
                      ),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _FocusHeaderGlass(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomBar(
                state: state,
                notifier: notifier,
                isContinuing: _isContinuing,
                onContinue: () => _continueToQuickies(notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header (frosted glass over bubble layer) ──────────────────────────────────

class _FocusHeaderGlass extends StatelessWidget {
  const _FocusHeaderGlass();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.35),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppTheme.notoSerif(
                      fontSize: 26,
                      weight: FontWeight.w700,
                    ),
                    children: [
                      const TextSpan(text: 'Set Your '),
                      TextSpan(
                        text: 'Focus',
                        style: AppTheme.notoSerif(
                          fontSize: 26,
                          weight: FontWeight.w700,
                          italic: true,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to rank your priorities. Skip the ones you want to rest on.',
                  style: AppTheme.inter(
                    fontSize: 13,
                    color: AppTheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.state,
    required this.notifier,
    required this.isContinuing,
    required this.onContinue,
  });

  final FocusFilterState state;
  final FocusFilterNotifier notifier;
  final bool isContinuing;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canContinue = state.canContinue;
    final isListMode = state.viewMode == FocusViewMode.list;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      child: Row(
        children: [
          LiquidGlassCircleButton(
            icon: isListMode
                ? Icons.bubble_chart_outlined
                : Icons.format_list_bulleted_rounded,
            semanticLabel: isListMode ? 'Show bubbles' : 'Show list',
            onTap: () => notifier.setViewMode(
              isListMode ? FocusViewMode.bubble : FocusViewMode.list,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ContinueButton(
              selectedCount: state.selected.length,
              canContinue: canContinue,
              isContinuing: isContinuing,
              onContinue: onContinue,
            ),
          ),
          const SizedBox(width: 12),
          LiquidGlassCircleButton(
            icon: Icons.refresh_rounded,
            semanticLabel: 'Reset focus selections',
            onTap: notifier.reset,
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.selectedCount,
    required this.canContinue,
    required this.isContinuing,
    required this.onContinue,
  });

  final int selectedCount;
  final bool canContinue;
  final bool isContinuing;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassActionButton(
      label: _label,
      enabled: canContinue && !isContinuing,
      icon: canContinue ? Icons.arrow_forward_rounded : null,
      onTap: onContinue,
    );
  }

  String get _label {
    if (isContinuing) return 'Preparing Quickies';

    final remaining = FocusPriorityConfig.minSelections - selectedCount;
    if (remaining <= 0) return 'Continue';
    if (remaining == FocusPriorityConfig.minSelections) {
      return 'Select at least 3 to continue';
    }
    return '$remaining more';
  }
}
