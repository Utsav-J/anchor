import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import 'focus_filter_category_icons.dart';

/// Icon above label stack shared by bubble picker and list-mode circles.
class FocusCategoryBubbleInterior extends StatelessWidget {
  const FocusCategoryBubbleInterior({
    super.key,
    required this.categoryName,
    required this.isSelected,
    this.priority,
    required this.iconSize,
    required this.labelFontSize,
    required this.priorityFontSize,
    this.maxLabelWidth = 104,
    this.iconBottomSpacing = 6,
    this.priorityTopSpacing = 4,
  });

  final String categoryName;
  final bool isSelected;
  final int? priority;
  final double iconSize;
  final double labelFontSize;
  final double priorityFontSize;
  final double maxLabelWidth;
  final double iconBottomSpacing;
  final double priorityTopSpacing;

  @override
  Widget build(BuildContext context) {
    final ink = isSelected ? Colors.black : AppTheme.textMuted;
    final label = categoryName.replaceAll('-', '\n').toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _categoryIcon(
          categoryName: categoryName,
          size: iconSize,
          ink: ink,
          isSelected: isSelected,
        ),
        SizedBox(height: iconBottomSpacing),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxLabelWidth),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            style: AppTheme.notoSerif(
              fontSize: labelFontSize,
              weight: FontWeight.w400,
              color: ink,
              height: 1.12,
              letterSpacing: 0.4,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
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
                  padding: EdgeInsets.only(top: priorityTopSpacing),
                  child: Text(
                    '$priority',
                    style: AppTheme.notoSerif(
                      fontSize: priorityFontSize,
                      weight: FontWeight.w500,
                      color: Colors.black,
                      height: 1,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Black icons → [ink] via srcIn. [Future-Oriented] is multi-color; opacity when unselected.
  static Widget _categoryIcon({
    required String categoryName,
    required double size,
    required Color ink,
    required bool isSelected,
  }) {
    final path = FocusFilterCategoryIcons.svgPath(categoryName);
    if (categoryName == 'Future-Oriented') {
      final child = SvgPicture.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
      if (!isSelected) {
        return Opacity(
          opacity: 0.38,
          child: child,
        );
      }
      return child;
    }
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
    );
  }
}
