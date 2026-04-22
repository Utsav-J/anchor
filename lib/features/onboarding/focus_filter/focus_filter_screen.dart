import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/focus_priority.dart';
import 'focus_filter_notifier.dart';
import 'widgets/bubble_canvas.dart';
import 'widgets/focus_list_panel.dart';

class FocusFilterScreen extends ConsumerWidget {
  const FocusFilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusFilterProvider);
    final notifier = ref.read(focusFilterProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FocusHeader(state: state, notifier: notifier),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: state.viewMode == FocusViewMode.bubble
                        ? const BubbleCanvas(key: ValueKey('bubble'))
                        : const FocusListPanel(key: ValueKey('list')),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomBar(state: state, notifier: notifier),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _FocusHeader extends StatelessWidget {
  const _FocusHeader({required this.state, required this.notifier});

  final FocusFilterState state;
  final FocusFilterNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isListMode = state.viewMode == FocusViewMode.list;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: [View List] left ── [Reset] right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => notifier.setViewMode(
                  isListMode ? FocusViewMode.bubble : FocusViewMode.list,
                ),
                icon: Icon(
                  isListMode
                      ? Icons.bubble_chart_outlined
                      : Icons.format_list_bulleted_rounded,
                  size: 16,
                ),
                label: Text(isListMode ? 'Bubble View' : 'View List'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.onSurface.withValues(alpha: 0.65),
                  textStyle: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w500,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                ),
              ),
              TextButton.icon(
                onPressed: notifier.reset,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.onSurface.withValues(alpha: 0.65),
                  textStyle: AppTheme.inter(
                    fontSize: 13,
                    weight: FontWeight.w500,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTheme.notoSerif(fontSize: 26, weight: FontWeight.w700),
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
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.state, required this.notifier});

  final FocusFilterState state;
  final FocusFilterNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canContinue = state.canContinue;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surface.withValues(alpha: 0),
            AppTheme.surface.withValues(alpha: 0.9),
            AppTheme.surface,
          ],
          stops: const [0, 0.3, 1],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            opacity: canContinue ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Select at least ${FocusPriorityConfig.minSelections} to continue',
                style: AppTheme.inter(
                  fontSize: 12,
                  color: AppTheme.onSurface.withValues(alpha: 0.42),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _ContinueButton(
            canContinue: canContinue,
            notifier: notifier,
            onConfirmed: (config) {
              ref.read(activeFocusPriorityProvider.notifier).state = config;
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.canContinue,
    required this.notifier,
    required this.onConfirmed,
  });

  final bool canContinue;
  final FocusFilterNotifier notifier;
  final void Function(FocusPriorityConfig config) onConfirmed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canContinue
          ? () async {
              final config = await notifier.saveAndComplete();
              if (context.mounted) onConfirmed(config);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: canContinue
              ? const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: canContinue ? null : AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
          boxShadow: canContinue
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: AppTheme.inter(
                fontSize: 16,
                weight: FontWeight.w600,
                color: canContinue
                    ? AppTheme.onPrimary
                    : AppTheme.onSurface.withValues(alpha: 0.32),
              ),
            ),
            if (canContinue) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.onPrimary,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
