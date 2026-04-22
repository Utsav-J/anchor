import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';
import '../focus_filter_notifier.dart';

/// List-mode view for the focus filter screen.
///
/// "Current Focus" uses [ReorderableListView] so the user can long-press
/// and drag tiles to re-order their priorities.
/// "Resting" shows unselected categories that can be tapped to add.
class FocusListPanel extends ConsumerWidget {
  const FocusListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusFilterProvider);
    final notifier = ref.read(focusFilterProvider.notifier);
    final all = AppConstants.defaultCategories;

    final selected = state.selected
        .map((name) => all.firstWhere((c) => c.name == name))
        .toList();
    final resting =
        all.where((c) => !state.selected.contains(c.name)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      children: [
        if (selected.isNotEmpty) ...[
          _sectionLabel('Current Focus'),
          const SizedBox(height: 10),
          // ReorderableListView needs a fixed height or shrinkWrap.
          // We use shrinkWrap inside a NeverScrollableScrollPhysics so it
          // sits flush within the outer ListView.
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            proxyDecorator: (child, index, animation) => Material(
              elevation: 6,
              shadowColor: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              child: child,
            ),
            onReorder: notifier.reorder,
            children: selected.asMap().entries.map((entry) {
              return _RankedCard(
                key: ValueKey(entry.value.name),
                meta: entry.value,
                rank: entry.key + 1,
                onRemove: () => notifier.deselect(entry.value.name),
              );
            }).toList(),
          ),
        ],
        if (resting.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionLabel('Resting'),
          const SizedBox(height: 10),
          ...resting.map(
            (meta) => _RestingCard(
              key: ValueKey('resting_${meta.name}'),
              meta: meta,
              onAdd: () => notifier.select(meta.name),
            ),
          ),
        ],
        const SizedBox(height: 140),
      ],
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          text.toUpperCase(),
          style: AppTheme.inter(
            fontSize: 11,
            weight: FontWeight.w500,
            color: AppTheme.onSurface.withValues(alpha: 0.45),
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _RankedCard extends StatelessWidget {
  const _RankedCard({
    super.key,
    required this.meta,
    required this.rank,
    required this.onRemove,
  });

  final CategoryMeta meta;
  final int rank;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E121C2B),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag handle — hints the user this row is reorderable
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.drag_handle_rounded,
              size: 18,
              color: AppTheme.onSurface.withValues(alpha: 0.25),
            ),
          ),
          _RankBadge(rank: rank),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.name,
                  style:
                      AppTheme.inter(fontSize: 15, weight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  meta.subtitle,
                  style: AppTheme.inter(
                    fontSize: 12,
                    color: AppTheme.onSurface.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: AppTheme.onSurface.withValues(alpha: 0.28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: AppTheme.inter(
          fontSize: 12,
          weight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

class _RestingCard extends StatelessWidget {
  const _RestingCard({super.key, required this.meta, required this.onAdd});

  final CategoryMeta meta;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: AppTheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.name,
                    style: AppTheme.inter(
                      fontSize: 15,
                      weight: FontWeight.w500,
                      color: AppTheme.onSurface.withValues(alpha: 0.60),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta.subtitle,
                    style: AppTheme.inter(
                      fontSize: 12,
                      color: AppTheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
