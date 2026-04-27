import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';

/// Every category starts at the same size; selection grows the circle.
const double kCategoryCircleSize = 116.0;
const double kSelectedCategoryCircleSize = 138.0;

/// Safe text area inside the circle so long labels never touch the edge.
const double _kTextMaxWidth = 82.0;

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

  // Order matches AppConstants.defaultCategories.
  static const _gradients = [
    [Color(0xFFFFB199), Color(0xFFFF6A3D)],
    [Color(0xFFC9F2A7), Color(0xFF5ABF74)],
    [Color(0xFFC7D9FF), Color(0xFF6D8FEF)],
    [Color(0xFFFFD48A), Color(0xFFEFA23A)],
    [Color(0xFFC8EAD6), Color(0xFF65B88A)],
    [Color(0xFFD5C8FF), Color(0xFF8C72E8)],
    [Color(0xFFFFC2D7), Color(0xFFE96898)],
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
    return _gradientColors(_idx(name), selected);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = priority != null;
    final idx = _idx(meta.name);
    final circleSize = isSelected ? selectedSize : size;
    final gradientColors = _gradientColors(idx, isSelected);
    final label = meta.name.replaceAll('-', '\n').toUpperCase();

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
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kTextMaxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  style: AppTheme.inter(
                    fontSize: isSelected ? 11.5 : 10.5,
                    weight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? AppTheme.onSurface.withValues(alpha: 0.9)
                        : AppTheme.onSurface.withValues(alpha: 0.68),
                    height: 1.08,
                    letterSpacing: 0.75,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: isSelected
                      ? Padding(
                          key: ValueKey(priority),
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '$priority',
                            style: AppTheme.inter(
                              fontSize: 18,
                              weight: FontWeight.w800,
                              color: AppTheme.onSurface.withValues(alpha: 0.9),
                              height: 1,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<Color> _gradientColors(int index, bool isSelected) {
    final colors = _gradients[index];
    if (isSelected) return colors;

    return [
      Color.lerp(colors[0], AppTheme.surfaceContainerHighest, 0.68)!,
      Color.lerp(colors[1], AppTheme.surfaceContainerHigh, 0.72)!,
    ];
  }
}
