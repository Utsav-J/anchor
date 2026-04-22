import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';
import '../focus_filter_notifier.dart';
import 'category_bubble.dart';

// Must stay in sync with the constant in category_bubble.dart.
const double _kBlobSize = 120.0;

/// Floating blob canvas for the focus filter onboarding screen.
///
/// Each blob drifts on its own independent X/Y [AnimationController]s using
/// [repeat(reverse: true)] with [Curves.easeInOut] — perfectly smooth
/// oscillation with no discontinuous jumps at cycle boundaries.
///
/// All blobs are [_kBlobSize] × [_kBlobSize] so the safe-zone calculation
/// is a single constant margin.
class BubbleCanvas extends ConsumerStatefulWidget {
  const BubbleCanvas({super.key});

  @override
  ConsumerState<BubbleCanvas> createState() => _BubbleCanvasState();
}

class _BubbleCanvasState extends ConsumerState<BubbleCanvas>
    with TickerProviderStateMixin {
  final List<AnimationController> _xCtrl = [];
  final List<AnimationController> _yCtrl = [];
  final List<Animation<double>> _xAnim = [];
  final List<Animation<double>> _yAnim = [];

  // ── Layout: centre fraction of safe area, drift amplitude (px) ────────────
  // Order matches AppConstants.defaultCategories:
  //   0=Creative  1=Movement  2=Reflective  3=Skill-Building
  //   4=Environment-Shaping  5=Future-Oriented  6=Connection
  static const _cx = [0.46, 0.18, 0.08, 0.60, 0.74, 0.62, 0.12];
  static const _cy = [0.18, 0.44, 0.08, 0.04, 0.34, 0.74, 0.70];
  static const _ax = [14.0, 18.0, 12.0, 16.0, 10.0, 20.0, 14.0];
  static const _ay = [10.0, 12.0, 16.0, 14.0, 18.0, 12.0, 16.0];

  // Intentionally different X/Y durations → Lissajous-like paths.
  static const _xDur = [11, 9, 13, 8, 12, 10, 14];
  static const _yDur = [13, 12, 9, 11, 8, 14, 10];

  // Staggered starts so blobs aren't synchronised at t = 0.
  static const _xOffset = [0.00, 0.43, 0.71, 0.14, 0.57, 0.28, 0.85];
  static const _yOffset = [0.62, 0.19, 0.47, 0.88, 0.33, 0.76, 0.05];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < AppConstants.defaultCategories.length; i++) {
      final xc = AnimationController(
        vsync: this,
        duration: Duration(seconds: _xDur[i]),
        value: _xOffset[i],
      )..repeat(reverse: true);

      final yc = AnimationController(
        vsync: this,
        duration: Duration(seconds: _yDur[i]),
        value: _yOffset[i],
      )..repeat(reverse: true);

      _xAnim.add(
        Tween<double>(begin: -_ax[i], end: _ax[i]).animate(
          CurvedAnimation(parent: xc, curve: Curves.easeInOut),
        ),
      );
      _yAnim.add(
        Tween<double>(begin: -_ay[i], end: _ay[i]).animate(
          CurvedAnimation(parent: yc, curve: Curves.easeInOut),
        ),
      );
      _xCtrl.add(xc);
      _yCtrl.add(yc);
    }
  }

  @override
  void dispose() {
    for (final c in _xCtrl) {
      c.dispose();
    }
    for (final c in _yCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(focusFilterProvider);
    final notifier    = ref.read(focusFilterProvider.notifier);
    final categories  = AppConstants.defaultCategories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < categories.length; i++)
              _FloatingBlob(
                key: ValueKey(categories[i].name),
                meta: categories[i],
                cx: _cx[i],
                cy: _cy[i],
                xAnim: _xAnim[i],
                yAnim: _yAnim[i],
                state: filterState,
                notifier: notifier,
                canvasW: w,
                canvasH: h,
              ),
          ],
        );
      },
    );
  }
}

// ── Per-bubble positioned widget ─────────────────────────────────────────────

class _FloatingBlob extends StatelessWidget {
  const _FloatingBlob({
    super.key,
    required this.meta,
    required this.cx,
    required this.cy,
    required this.xAnim,
    required this.yAnim,
    required this.state,
    required this.notifier,
    required this.canvasW,
    required this.canvasH,
  });

  final CategoryMeta meta;
  final double cx;
  final double cy;
  final Animation<double> xAnim;
  final Animation<double> yAnim;
  final FocusFilterState state;
  final FocusFilterNotifier notifier;
  final double canvasW;
  final double canvasH;

  // Fixed safe margin = half blob size + a small gap so no blob clips the edge.
  static const _safeMargin = _kBlobSize / 2 + 10; // 70 px

  @override
  Widget build(BuildContext context) {
    final priority   = state.priorityOf(meta.name);
    final isSelected = priority != null;
    final total      = state.selected.length;

    final safeW  = (canvasW - _safeMargin * 2).clamp(0.0, double.infinity);
    final safeH  = (canvasH - _safeMargin * 2).clamp(0.0, double.infinity);
    final baseCx = _safeMargin + cx * safeW;
    final baseCy = _safeMargin + cy * safeH;

    return AnimatedBuilder(
      animation: Listenable.merge([xAnim, yAnim]),
      builder: (context, child) {
        // Selected blobs stop drifting and snap to their base position.
        final dx = isSelected ? 0.0 : xAnim.value;
        final dy = isSelected ? 0.0 : yAnim.value;

        final left = (baseCx + dx - _kBlobSize / 2)
            .clamp(0.0, (canvasW - _kBlobSize).clamp(0.0, double.infinity));
        final top = (baseCy + dy - _kBlobSize / 2)
            .clamp(0.0, (canvasH - _kBlobSize).clamp(0.0, double.infinity));

        return Positioned(left: left, top: top, child: child!);
      },
      child: RepaintBoundary(
        child: CategoryBubble(
          meta: meta,
          priority: priority,
          totalSelected: total,
          onTap: () {
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
            if (isSelected) notifier.deselect(meta.name);
          },
        ),
      ),
    );
  }
}
