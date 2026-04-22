import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/models/focus_priority.dart';
import '../onboarding/focus_filter/focus_filter_notifier.dart';

/// Profile screen for managing the user's focus priorities.
///
/// Shows currently active categories with drag-to-reorder, plus
/// unselected categories that can be added. Saving updates both
/// SharedPreferences and [activeFocusPriorityProvider] so changes
/// are reflected immediately in My Week.
///
/// Past week scores remain frozen with the weights that were active
/// at the time they were recorded. ⓘ badge explains this to the user.
class ManageFocusScreen extends ConsumerStatefulWidget {
  const ManageFocusScreen({super.key});

  @override
  ConsumerState<ManageFocusScreen> createState() => _ManageFocusScreenState();
}

class _ManageFocusScreenState extends ConsumerState<ManageFocusScreen> {
  late List<String> _selected;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(activeFocusPriorityProvider);
    _selected = config != null
        ? List<String>.from(config.orderedCategories)
        : AppConstants.defaultCategories.map((c) => c.name).toList();
  }

  List<CategoryMeta> get _selectedMeta => _selected
      .map((name) =>
          AppConstants.defaultCategories.firstWhere((c) => c.name == name))
      .toList();

  List<CategoryMeta> get _restingMeta => AppConstants.defaultCategories
      .where((c) => !_selected.contains(c.name))
      .toList();

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _selected.removeAt(oldIndex);
      _selected.insert(newIndex, item);
      _dirty = true;
    });
  }

  void _add(String name) {
    if (_selected.contains(name)) return;
    setState(() {
      _selected.add(name);
      _dirty = true;
    });
  }

  void _remove(String name) {
    if (_selected.length <= FocusPriorityConfig.minSelections) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Keep at least ${FocusPriorityConfig.minSelections} categories.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() {
      _selected.remove(name);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    final config = FocusPriorityConfig(
      orderedCategories: List.unmodifiable(_selected),
      setAt: DateTime.now(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'anchor.focus_priorities',
      jsonEncode(config.toJson()),
    );
    ref.read(activeFocusPriorityProvider.notifier).state = config;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Focus updated'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.accent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _dirty = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'My Focus',
          style: AppTheme.notoSerif(fontSize: 20, italic: true),
        ),
        actions: [
          // Info button explaining frozen past scores
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              color: AppTheme.onSurface.withValues(alpha: 0.45),
              size: 20,
            ),
            tooltip:
                'Past weeks keep the weights that were active at the time.',
            onPressed: () => _showHistoryNote(context),
          ),
          if (_dirty)
            TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: AppTheme.inter(
                  fontSize: 15,
                  weight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _sectionLabel('Active Categories'),
          const SizedBox(height: 4),
          Text(
            'Long press and drag to reorder. P1 carries the most weight.',
            style: AppTheme.inter(
              fontSize: 12,
              color: AppTheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 12),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            proxyDecorator: (child, index, animation) => Material(
              elevation: 6,
              shadowColor: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              child: child,
            ),
            onReorder: _reorder,
            children: _selectedMeta.asMap().entries.map((e) {
              return _ActiveTile(
                key: ValueKey(e.value.name),
                meta: e.value,
                rank: e.key + 1,
                total: _selected.length,
                onRemove: () => _remove(e.value.name),
              );
            }).toList(),
          ),
          if (_restingMeta.isNotEmpty) ...[
            const SizedBox(height: 28),
            _sectionLabel('Not Active'),
            const SizedBox(height: 4),
            Text(
              'Tap to add to your daily pulse.',
              style: AppTheme.inter(
                fontSize: 12,
                color: AppTheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 12),
            ..._restingMeta.map(
              (meta) => _RestingTile(
                key: ValueKey('resting_${meta.name}'),
                meta: meta,
                onAdd: () => _add(meta.name),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: AppTheme.inter(
          fontSize: 11,
          weight: FontWeight.w500,
          color: AppTheme.onSurface.withValues(alpha: 0.45),
          letterSpacing: 1.2,
        ),
      );

  void _showHistoryNote(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'About past scores',
          style: AppTheme.notoSerif(fontSize: 18, italic: true),
        ),
        content: Text(
          'Past week ownership scores are frozen with the priority weights '
          'that were active at the time they were recorded. '
          'Changes you make here only affect future weeks.',
          style: AppTheme.inter(
            fontSize: 14,
            color: AppTheme.onSurface.withValues(alpha: 0.75),
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Got it',
              style: AppTheme.inter(
                fontSize: 14,
                weight: FontWeight.w600,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tiles ──────────────────────────────────────────────────────────────────────

class _ActiveTile extends StatelessWidget {
  const _ActiveTile({
    super.key,
    required this.meta,
    required this.rank,
    required this.total,
    required this.onRemove,
  });

  final CategoryMeta meta;
  final int rank;
  final int total;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final weight = FocusPriorityConfig.weightForIndex(rank - 1, total);
    final pct = (weight * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D121C2B),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_handle_rounded,
            size: 18,
            color: AppTheme.onSurface.withValues(alpha: 0.22),
          ),
          const SizedBox(width: 10),
          Container(
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
          ),
          const SizedBox(width: 12),
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
                    fontSize: 11,
                    color: AppTheme.onSurface.withValues(alpha: 0.48),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pct% weight',
              style: AppTheme.inter(
                fontSize: 11,
                weight: FontWeight.w500,
                color: AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppTheme.onSurface.withValues(alpha: 0.28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestingTile extends StatelessWidget {
  const _RestingTile({super.key, required this.meta, required this.onAdd});

  final CategoryMeta meta;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                  color: AppTheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: AppTheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(width: 12),
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
                      fontSize: 11,
                      color: AppTheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Add',
              style: AppTheme.inter(
                fontSize: 13,
                weight: FontWeight.w500,
                color: AppTheme.accent.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
