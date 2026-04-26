import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';

import '../../core/theme/app_theme.dart';

class LiquidGlassActionButton extends StatelessWidget {
  const LiquidGlassActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.enabled = true,
    this.height = 56,
    this.width,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool enabled;
  final double height;
  final double? width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textColor = enabled
        ? AppTheme.onSurface.withValues(alpha: 0.9)
        : AppTheme.onSurface.withValues(alpha: 0.38);

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth =
            width ??
            (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : compact
                ? 132.0
                : 220.0);

        return LGButton.custom(
          label: label,
          width: resolvedWidth,
          height: height,
          enabled: enabled,
          useOwnLayer: true,
          shape: LiquidRoundedSuperellipse(borderRadius: height / 2),
          settings: LiquidGlassSettings(
            thickness: enabled ? 24 : 12,
            blur: 18,
            glassColor: enabled
                ? AppTheme.primaryFixed.withValues(alpha: 0.36)
                : AppTheme.surfaceContainerHigh.withValues(alpha: 0.42),
          ),
          glowColor: AppTheme.accent.withValues(alpha: 0.18),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTheme.inter(
                  fontSize: compact ? 12 : 15,
                  weight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: compact ? 1.0 : 0.2,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: textColor, size: compact ? 16 : 18),
              ],
            ],
          ),
        );
      },
    );
  }
}

class LiquidGlassCircleButton extends StatelessWidget {
  const LiquidGlassCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.enabled = true,
    this.size = 56,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppTheme.onSurface.withValues(alpha: 0.82)
        : AppTheme.onSurface.withValues(alpha: 0.34);

    return LGButton(
      icon: icon,
      label: semanticLabel,
      width: size,
      height: size,
      iconSize: size * 0.4,
      iconColor: color,
      enabled: enabled,
      useOwnLayer: true,
      shape: const LiquidOval(),
      settings: LiquidGlassSettings(
        thickness: enabled ? 22 : 12,
        blur: 18,
        glassColor: enabled
            ? AppTheme.primaryFixed.withValues(alpha: 0.3)
            : AppTheme.surfaceContainerHigh.withValues(alpha: 0.42),
      ),
      glowColor: AppTheme.accent.withValues(alpha: 0.16),
      onTap: onTap,
    );
  }
}
