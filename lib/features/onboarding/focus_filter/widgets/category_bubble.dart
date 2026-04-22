import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';

/// Fixed blob size — every category blob is the same dimensions.
/// Selection only changes colour and adds a soft ambient glow.
const double _kBlobSize = 120.0;

/// Safe text area: the inscribed region inside the organic blob shape.
/// Using ~60 % of the bounding-box width keeps text clear of clipped edges.
const double _kTextMaxWidth = 72.0;

/// Renders a single category as a continuously-morphing organic blob.
///
/// Size is always [_kBlobSize]. Tapping a blob selects it (changes colour
/// + glow). The blob shape keeps morphing whether selected or not because
/// [Blob.animatedRandom] is configured with [loop: true].
class CategoryBubble extends StatelessWidget {
  const CategoryBubble({
    super.key,
    required this.meta,
    required this.priority,
    required this.totalSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final CategoryMeta meta;

  /// 1-based priority, or null if unselected.
  final int? priority;
  final int totalSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  // ── Per-category blob personalities ───────────────────────────────────────
  static const _edges  = [6, 5, 7, 5, 8, 6, 5];
  static const _growth = [4, 3, 5, 4, 3, 5, 4];

  static int _idx(String name) {
    const names = [
      'Creative', 'Movement', 'Reflective', 'Skill-Building',
      'Environment-Shaping', 'Future-Oriented', 'Connection',
    ];
    final i = names.indexOf(name);
    return i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = priority != null;
    final idx        = _idx(meta.name);

    final glowStrength = (isSelected && totalSelected > 0)
        ? (totalSelected - priority! + 1) / totalSelected
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        // Size is always fixed — no jump on selection.
        width: _kBlobSize,
        height: _kBlobSize,
        decoration: BoxDecoration(
          // Circular bounding-box used only to emit the glow shadow.
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(
                      alpha: 0.18 + glowStrength * 0.18,
                    ),
                    blurRadius: 26 + glowStrength * 18,
                    spreadRadius: 5 + glowStrength * 7,
                  ),
                  BoxShadow(
                    color: AppTheme.accent.withValues(
                      alpha: 0.06 + glowStrength * 0.10,
                    ),
                    blurRadius: 46 + glowStrength * 14,
                    spreadRadius: 2,
                  ),
                ]
              : const [],
        ),
        child: Blob.animatedRandom(
          size: _kBlobSize,
          edgesCount: _edges[idx],
          minGrowth: _growth[idx],
          duration: const Duration(milliseconds: 2600),
          loop: true, // continuous morphing regardless of selection
          styles: BlobStyles(
            color: isSelected
                ? AppTheme.primaryFixed.withValues(alpha: 0.62)
                : AppTheme.surfaceContainerLowest.withValues(alpha: 0.94),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kTextMaxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 280),
                    style: AppTheme.inter(
                      fontSize: 10,
                      weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.onSurface.withValues(alpha: 0.72),
                      letterSpacing: 0.8,
                    ),
                    child: Text(
                      meta.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        '$priority',
                        style: AppTheme.inter(
                          fontSize: 16,
                          weight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
