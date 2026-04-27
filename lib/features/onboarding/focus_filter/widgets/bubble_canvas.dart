import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';
import '../focus_filter_notifier.dart';
import 'category_bubble.dart';

/// Freeform circle canvas for the focus filter onboarding screen.
class BubbleCanvas extends ConsumerWidget {
  const BubbleCanvas({super.key, this.isExiting = false});

  final bool isExiting;

  static const _positions = [
    Offset(0.08, 0.02),
    Offset(0.63, 0.04),
    Offset(0.31, 0.24),
    Offset(0.67, 0.38),
    Offset(0.05, 0.50),
    Offset(0.55, 0.67),
    Offset(0.23, 0.79),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(focusFilterProvider);
    final notifier = ref.read(focusFilterProvider.notifier);
    final categories = AppConstants.defaultCategories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final baseSize = _circleSizeFor(width, height);
        final selectedSize = baseSize * 1.15;
        final safeHeight = (height - 56).clamp(0.0, double.infinity);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < categories.length; i++)
              _CircleSlot(
                key: ValueKey(categories[i].name),
                meta: categories[i],
                position: _positions[i],
                circleSize: baseSize,
                selectedCircleSize: selectedSize,
                canvasSize: Size(width, safeHeight),
                isExiting: isExiting,
                state: filterState,
                notifier: notifier,
              ),
          ],
        );
      },
    );
  }

  static double _circleSizeFor(double width, double height) {
    final byWidth = width * 0.31;
    final byHeight = height * 0.19;
    return byWidth.clamp(96.0, byHeight.clamp(96.0, 118.0)).toDouble();
  }
}

// ── Per-category slot ────────────────────────────────────────────────────────

class _CircleSlot extends StatelessWidget {
  const _CircleSlot({
    super.key,
    required this.meta,
    required this.position,
    required this.circleSize,
    required this.selectedCircleSize,
    required this.canvasSize,
    required this.isExiting,
    required this.state,
    required this.notifier,
  });

  final CategoryMeta meta;
  final Offset position;
  final double circleSize;
  final double selectedCircleSize;
  final Size canvasSize;
  final bool isExiting;
  final FocusFilterState state;
  final FocusFilterNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final priority = state.priorityOf(meta.name);
    final isSelected = priority != null;
    final total = state.selected.length;

    final exitUnselected = isExiting && !isSelected;
    final maxLeft = (canvasSize.width - selectedCircleSize).clamp(
      0.0,
      double.infinity,
    );
    final maxTop = (canvasSize.height - selectedCircleSize).clamp(
      0.0,
      double.infinity,
    );
    final left = (position.dx * maxLeft).clamp(0.0, maxLeft);
    final top = (position.dy * maxTop).clamp(0.0, maxTop);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      child: AnimatedOpacity(
        opacity: exitUnselected ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: exitUnselected
              ? 0.3
              : isExiting
              ? 1.08
              : 1.0,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: RepaintBoundary(
            child: SizedBox(
              width: selectedCircleSize,
              height: selectedCircleSize,
              child: Center(
                child: Hero(
                  tag: 'onboarding-category-${meta.name}',
                  child: CategoryBubble(
                    meta: meta,
                    priority: priority,
                    totalSelected: total,
                    size: circleSize,
                    selectedSize: selectedCircleSize,
                    onTap: () {
                      if (isExiting) return;
                      if (isSelected) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: const Text('Long press to deselect'),
                              duration: const Duration(milliseconds: 1500),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.onSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                      } else {
                        notifier.select(meta.name);
                      }
                    },
                    onLongPress: () {
                      if (isExiting) return;
                      if (isSelected) {
                        notifier.deselect(meta.name);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
