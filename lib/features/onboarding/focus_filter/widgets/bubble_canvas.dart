import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';
import '../focus_filter_notifier.dart';
import 'category_bubble.dart';

/// Stable circular grid for the focus filter onboarding screen.
class BubbleCanvas extends ConsumerWidget {
  const BubbleCanvas({super.key, this.isExiting = false});

  final bool isExiting;

  static const _slotSize = kSelectedCategoryCircleSize - 6;
  static const _offsets = [
    Offset(-2, 2),
    Offset(2, -1),
    Offset(-2, -1),
    Offset(2, -2),
    Offset(-1, 2),
    Offset(2, -1),
    Offset(-2, 2),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(focusFilterProvider);
    final notifier = ref.read(focusFilterProvider.notifier);
    final categories = AppConstants.defaultCategories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 0.0;
        final contentMinHeight = minHeight > 132 ? minHeight - 132 : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 132),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: contentMinHeight),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 0,
                runSpacing: 0,
                children: [
                  for (var i = 0; i < categories.length; i++)
                    _CircleSlot(
                      key: ValueKey(categories[i].name),
                      meta: categories[i],
                      offset: _offsets[i],
                      isExiting: isExiting,
                      state: filterState,
                      notifier: notifier,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Per-category slot ────────────────────────────────────────────────────────

class _CircleSlot extends StatelessWidget {
  const _CircleSlot({
    super.key,
    required this.meta,
    required this.offset,
    required this.isExiting,
    required this.state,
    required this.notifier,
  });

  final CategoryMeta meta;
  final Offset offset;
  final bool isExiting;
  final FocusFilterState state;
  final FocusFilterNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final priority = state.priorityOf(meta.name);
    final isSelected = priority != null;
    final total = state.selected.length;

    final exitUnselected = isExiting && !isSelected;

    return AnimatedOpacity(
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
        child: SizedBox(
          width: BubbleCanvas._slotSize,
          height: BubbleCanvas._slotSize,
          child: RepaintBoundary(
            child: Center(
              child: Transform.translate(
                offset: offset,
                child: Hero(
                  tag: 'onboarding-category-${meta.name}',
                  child: CategoryBubble(
                    meta: meta,
                    priority: priority,
                    totalSelected: total,
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
