import 'package:bubble_picker/bubble_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';
import '../focus_filter_notifier.dart';
import 'category_bubble.dart';
import 'focus_category_bubble_interior.dart';

// The BubblePicker package has a hardcoded cluster center at Offset(200, 400),
// matching its default canvas Size(400, 800). We always pass this exact size and
// use OverflowBox + ClipRect so the cluster center is always at the visual center
// of whatever space is actually available.
const _kVirtualSize = Size(400, 800);

// radius formula (packages/bubble_picker fork): actualPixelRadius = data.radius * 40 + 40
// 0.9 → 76px radius (152px diameter), twice the upstream package default.
const _kCategoryBubbleRadius = 0.9;

/// Multiplier applied when a bubble is selected (returns to 1.0 when deselected).
const _kSelectedBubbleScale = 1.12;

/// Physics-based bubble canvas for focus category selection.
///
/// Uses [BubblePicker] so bubbles float with attraction/repulsion dynamics.
/// Each bubble's visual (gradient, text, priority) lives entirely in its
/// [child] widget — a Riverpod [Consumer] — so selection state updates
/// without reinitialising the physics simulation.
class BubbleCanvas extends ConsumerStatefulWidget {
  const BubbleCanvas({super.key, this.isExiting = false});

  final bool isExiting;

  @override
  ConsumerState<BubbleCanvas> createState() => _BubbleCanvasState();
}

class _BubbleCanvasState extends ConsumerState<BubbleCanvas> {
  // Propagated into each bubble's child via ValueListenableBuilder so the
  // exit animation fires without restarting the physics simulation.
  final _exitingNotifier = ValueNotifier<bool>(false);

  @override
  void didUpdateWidget(BubbleCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExiting != oldWidget.isExiting) {
      _exitingNotifier.value = widget.isExiting;
    }
  }

  @override
  void dispose() {
    _exitingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppConstants.defaultCategories;

    // OverflowBox always sizes the virtual canvas at 400×800 regardless of
    // the actual available space, and Alignment.center puts the cluster
    // centre (200, 400) exactly at the middle of the ClipRect viewport.
    return ClipRect(
      child: OverflowBox(
        maxWidth: _kVirtualSize.width,
        maxHeight: _kVirtualSize.height,
        alignment: Alignment.center,
        child: BubblePicker(
          size: _kVirtualSize,
          bubbles: [
            for (final meta in categories) _buildBubbleData(meta),
          ],
        ),
      ),
    );
  }

  BubbleData _buildBubbleData(CategoryMeta meta) {
    return BubbleData(
      // Transparent so the painter draws nothing; our child renders the circle.
      color: Colors.transparent,
      radius: _kCategoryBubbleRadius,
      // Consumer updates whenever selection state changes, independent of the
      // physics simulation's own setState cadence.
      child: ValueListenableBuilder<bool>(
        valueListenable: _exitingNotifier,
        builder: (_, isExiting, _) => Consumer(
          builder: (_, ref, _) {
            final state = ref.watch(focusFilterProvider);
            final priority = state.priorityOf(meta.name);
            return _CategoryBubbleContent(
              meta: meta,
              priority: priority,
              totalSelected: state.selected.length,
              isExiting: isExiting,
            );
          },
        ),
      ),
      onTapBubble: (_) {
        // ref.read is safe inside callbacks — always reads current state.
        final state = ref.read(focusFilterProvider);
        final notifier = ref.read(focusFilterProvider.notifier);
        if (state.priorityOf(meta.name) != null) {
          notifier.deselect(meta.name);
        } else {
          notifier.select(meta.name);
        }
      },
    );
  }
}

// ── Per-category bubble content ───────────────────────────────────────────────

class _CategoryBubbleContent extends StatelessWidget {
  const _CategoryBubbleContent({
    required this.meta,
    required this.priority,
    required this.totalSelected,
    required this.isExiting,
  });

  final CategoryMeta meta;
  final int? priority;
  final int totalSelected;
  final bool isExiting;

  @override
  Widget build(BuildContext context) {
    final isSelected = priority != null;
    final exitUnselected = isExiting && !isSelected;

    final bubbleScale = exitUnselected
        ? 0.3
        : !isSelected
            ? 1.0
            : isExiting
                ? _kSelectedBubbleScale * 1.08
                : _kSelectedBubbleScale;

    return AnimatedOpacity(
      opacity: exitUnselected ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        scale: bubbleScale,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: _CategoryBubbleCircle(
          meta: meta,
          priority: priority,
          totalSelected: totalSelected,
        ),
      ),
    );
  }
}

class _CategoryBubbleCircle extends StatelessWidget {
  const _CategoryBubbleCircle({
    required this.meta,
    required this.priority,
    required this.totalSelected,
  });

  final CategoryMeta meta;
  final int? priority;
  final int totalSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = priority != null;
    final gradientColors =
        CategoryBubble.gradientColorsFor(meta.name, selected: isSelected);

    final glowStrength = (isSelected && totalSelected > 0)
        ? (totalSelected - priority! + 1) / totalSelected
        : 0.0;

    // SizedBox.expand fills the bubble.radius*2 SizedBox that BubblePicker
    // wraps around each child.
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  CategoryBubble.liquidGradientFor(meta.name, selected: isSelected),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: gradientColors.last.withValues(
                          alpha: 0.24 + glowStrength * 0.12,
                        ),
                        blurRadius: 16 + glowStrength * 8,
                        spreadRadius: 2 + glowStrength * 3,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.onSurface.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: CategoryBubble.sphereOcclusionFor(
                    selected: isSelected,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: CategoryBubble.liquidSpecularFor(
                    meta.name,
                    selected: isSelected,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: FocusCategoryBubbleInterior(
                categoryName: meta.name,
                isSelected: isSelected,
                priority: priority,
                iconSize: isSelected ? 30 : 28,
                labelFontSize: isSelected ? 12.5 : 11.5,
                priorityFontSize: 17,
                maxLabelWidth: 108,
                iconBottomSpacing: 5,
                priorityTopSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
