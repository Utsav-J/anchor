import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';
import 'focus_category_bubble_interior.dart';

/// Every category starts at the same size; selection grows the circle.
const double kCategoryCircleSize = 116.0;
const double kSelectedCategoryCircleSize = 138.0;

/// Radial glass recipe for one focus category — picker, list, and shadows all use this.
@immutable
class CategoryGlassSpec {
  const CategoryGlassSpec({
    required this.radialCenter,
    required this.radialRadius,
    required this.colors,
    required this.stops,
  });

  final Alignment radialCenter;
  final double radialRadius;
  final List<Color> colors;
  final List<double> stops;
}

/// Renders a single category as a circular priority choice.
class CategoryBubble extends StatelessWidget {
  const CategoryBubble({
    super.key,
    required this.meta,
    required this.priority,
    required this.totalSelected,
    required this.onTap,
    required this.onLongPress,
    this.size = kCategoryCircleSize,
    this.selectedSize = kSelectedCategoryCircleSize,
  });

  final CategoryMeta meta;

  /// 1-based priority, or null if unselected.
  final int? priority;
  final int totalSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final double size;
  final double selectedSize;

  /// Single source of truth per category: bubble picker, list tiles, and glows
  /// all read from this table. Positions match CSS `circle at X% Y%` → Flutter alignment.
  static const List<CategoryGlassSpec> categoryGlassSpecs = [
    // Creative — Ethereal Dawn
    CategoryGlassSpec(
      radialCenter: Alignment(-0.5, -0.5), // 25% 25%
      radialRadius: 1.05,
      colors: [
        Color(0xFFFFCBED),
        Color(0xFFD4B3FF),
        Color(0xFF8DB3FF),
        Color(0xFFF0F4FD),
      ],
      stops: [0.0, 0.4, 0.75, 1.0],
    ),
    // Movement — Soft Rose
    CategoryGlassSpec(
      radialCenter: Alignment(-0.4, -0.4), // 30% 30%
      radialRadius: 1.04,
      colors: [
        Color(0xFFF95F9E),
        Color(0xFFFC9CB3),
        Color(0xFFFDF5F6),
        Color(0xFFFDF5F6),
      ],
      stops: [0.0, 0.45, 0.9, 1.0],
    ),
    // Reflective — Minty Aurora
    CategoryGlassSpec(
      radialCenter: Alignment(-0.5, -0.4), // 25% 30%
      radialRadius: 1.05,
      colors: [
        Color(0xFFE0C3FC),
        Color(0xFF8EC5FC),
        Color(0xFFA1FFD3),
        Color(0xFFF0F9F6),
      ],
      stops: [0.0, 0.45, 0.85, 1.0],
    ),
    // Skill-Building — Solar Flare
    CategoryGlassSpec(
      radialCenter: Alignment(-0.3, -0.3), // 35% 35%
      radialRadius: 1.03,
      colors: [
        Color(0xFFFF7B00),
        Color(0xFFFFB75E),
        Color(0xFFFEF3E5),
      ],
      stops: [0.0, 0.55, 1.0],
    ),
    // Environment-Shaping — Holographic Pearl
    CategoryGlassSpec(
      radialCenter: Alignment(-0.4, -0.6), // 30% 20%
      radialRadius: 1.06,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFE8F5C8),
        Color(0xFFE1C0E3),
        Color(0xFFA1C4FD),
      ],
      stops: [0.0, 0.3, 0.65, 1.0],
    ),
    // Future-Oriented — Sunset Peach
    CategoryGlassSpec(
      radialCenter: Alignment(-0.4, -0.5), // 30% 25%
      radialRadius: 1.05,
      colors: [
        Color(0xFFFFE1C9),
        Color(0xFFFF8C8C),
        Color(0xFFA4508B),
        Color(0xFFFFFFFF),
      ],
      stops: [0.0, 0.4, 0.85, 1.0],
    ),
    // Connection — Twilight Dream
    CategoryGlassSpec(
      radialCenter: Alignment(-0.5, -0.5), // 25% 25%
      radialRadius: 1.05,
      colors: [
        Color(0xFFFF9A9E),
        Color(0xFFFECFEF),
        Color(0xFFA18CD1),
        Color(0xFFFBC2EB),
      ],
      stops: [0.0, 0.35, 0.75, 1.0],
    ),
  ];

  static int _idx(String name) {
    const names = [
      'Creative',
      'Movement',
      'Reflective',
      'Skill-Building',
      'Environment-Shaping',
      'Future-Oriented',
      'Connection',
    ];
    final i = names.indexOf(name);
    return i == -1 ? 0 : i;
  }

  static List<Color> gradientColorsFor(String name, {required bool selected}) {
    return _glowEdgeColors(_idx(name), selected);
  }

  /// Main fill: same [CategoryGlassSpec] as everywhere else; unselected = softer via lerp.
  static Gradient liquidGradientFor(String name, {required bool selected}) {
    final spec = categoryGlassSpecs[_idx(name)];
    final surface = AppTheme.surfaceContainerLow;
    final mute = selected ? 0.0 : 0.34;
    final colors = [for (final c in spec.colors) Color.lerp(c, surface, mute)!];
    return RadialGradient(
      center: spec.radialCenter,
      radius: spec.radialRadius,
      colors: colors,
      stops: spec.stops,
    );
  }

  /// Soft ambient occlusion on the lower-right (approximates inset shadow on a sphere).
  static Gradient sphereOcclusionFor({required bool selected}) {
    return RadialGradient(
      center: const Alignment(0.58, 0.62),
      radius: 1.02,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: selected ? 0.085 : 0.052),
      ],
      stops: const [0.4, 1.0],
    );
  }

  /// Specular highlight near the CSS offset light source.
  static Gradient liquidSpecularFor(String name, {required bool selected}) {
    final spec = categoryGlassSpecs[_idx(name)];
    final c = spec.radialCenter;
    final highlightCenter = Alignment(
      (c.x * 0.72 - 0.22).clamp(-1.0, 1.0),
      (c.y * 0.72 - 0.28).clamp(-1.0, 1.0),
    );
    return RadialGradient(
      center: highlightCenter,
      radius: 0.68,
      colors: [
        Colors.white.withValues(alpha: selected ? 0.42 : 0.26),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = priority != null;
    final idx = _idx(meta.name);
    final circleSize = isSelected ? selectedSize : size;
    final gradientColors = _glowEdgeColors(idx, isSelected);
    final glowStrength = (isSelected && totalSelected > 0)
        ? (totalSelected - priority! + 1) / totalSelected
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: liquidGradientFor(meta.name, selected: isSelected),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradientColors.last.withValues(
                      alpha: 0.24 + glowStrength * 0.12,
                    ),
                    blurRadius: 24 + glowStrength * 12,
                    spreadRadius: 2 + glowStrength * 4,
                  ),
                  BoxShadow(
                    color: AppTheme.surface.withValues(alpha: 0.8),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppTheme.onSurface.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                    gradient: liquidSpecularFor(
                      meta.name,
                      selected: isSelected,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: FocusCategoryBubbleInterior(
                categoryName: meta.name,
                isSelected: isSelected,
                priority: priority,
                iconSize: isSelected ? 32 : 30,
                labelFontSize: isSelected ? 14.5 : 13.5,
                priorityFontSize: 20,
                maxLabelWidth: 102,
                iconBottomSpacing: 6,
                priorityTopSpacing: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Color> _glowEdgeColors(int index, bool selected) {
    final spec = categoryGlassSpecs[index];
    final c = spec.colors;
    final mid = c[c.length ~/ 2];
    final outer = c.last;
    if (selected) return [mid, outer];
    return [
      Color.lerp(mid, AppTheme.surfaceContainer, 0.48)!,
      Color.lerp(outer, AppTheme.surface, 0.44)!,
    ];
  }
}
