import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class AnchorShell extends StatefulWidget {
  const AnchorShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<AnchorShell> createState() => _AnchorShellState();
}

class _AnchorShellState extends State<AnchorShell>
    with TickerProviderStateMixin {
  late final List<AnimationController> _bounce;
  late final List<Animation<double>> _bounceAnim;

  // ── Tab definitions ────────────────────────────────────────────────────────

  static const _tabs = [
    _NavSpec(
      label: 'Home',
      outlinedIcon: Icons.home_outlined,
      filledIcon: Icons.home_rounded,
    ),
    _NavSpec(
      label: 'My Week',
      outlinedIcon: Icons.calendar_view_week_outlined,
      filledIcon: Icons.calendar_view_week_rounded,
    ),
    _NavSpec(
      label: 'Me',
      outlinedIcon: Icons.person_outline_rounded,
      filledIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _bounce = List.generate(
      _tabs.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _bounceAnim = _bounce.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 1.35)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 35),
        TweenSequenceItem(
            tween: Tween(begin: 1.35, end: 0.90)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 30),
        TweenSequenceItem(
            tween: Tween(begin: 0.90, end: 1.0)
                .chain(CurveTween(curve: Curves.elasticOut)),
            weight: 35),
      ]).animate(ctrl);
    }).toList();

    // Mark the initial tab as selected (no animation, just set value)
    _bounce[widget.navigationShell.currentIndex].value = 1.0;
  }

  @override
  void didUpdateWidget(AnchorShell old) {
    super.didUpdateWidget(old);
    final idx = widget.navigationShell.currentIndex;
    if (old.navigationShell.currentIndex != idx) {
      _bounce[idx].forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _bounce) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSelect(int index) {
    HapticFeedback.selectionClick();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Never allow the default system back to exit the app
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.navigationShell.currentIndex != 0) {
          _onSelect(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        // extendBody lets content flow behind the floating nav for the blur
        extendBody: true,
        body: Stack(
          children: [
            widget.navigationShell,
            Align(
              alignment: Alignment.bottomCenter,
              child: _GlassmorphicNav(
                tabs: _tabs,
                selectedIndex: widget.navigationShell.currentIndex,
                bounceAnims: _bounceAnim,
                onSelect: _onSelect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glassmorphic bottom nav ───────────────────────────────────────────────────

class _GlassmorphicNav extends StatelessWidget {
  const _GlassmorphicNav({
    required this.tabs,
    required this.selectedIndex,
    required this.bounceAnims,
    required this.onSelect,
  });

  final List<_NavSpec> tabs;
  final int selectedIndex;
  final List<Animation<double>> bounceAnims;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            // Warm translucent white tinted with surface colour
            color: const Color(0xD0FFF8F6),
            border: const Border(
              top: BorderSide(
                color: Color(0x50FFFFFF),
                width: 1,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14121C2B),
                blurRadius: 32,
                offset: Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            8.w,
            10.h,
            8.w,
            (bottomInset + 8).h,
          ),
          child: Row(
            children: [
              for (int i = 0; i < tabs.length; i++)
                _NavSection(
                  spec: tabs[i],
                  isSelected: i == selectedIndex,
                  isHome: i == 0,
                  bounceAnim: bounceAnims[i],
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav section (full 1/3 of the bar as a tap target) ─────────────────────────

class _NavSection extends StatelessWidget {
  const _NavSection({
    required this.spec,
    required this.isSelected,
    required this.isHome,
    required this.bounceAnim,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool isSelected;
  final bool isHome;
  final Animation<double> bounceAnim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        // opaque so the full Expanded area is tappable, not just the label
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 56.h,
          child: Center(
            child: AnimatedBuilder(
              animation: bounceAnim,
              builder: (context, child) => Transform.scale(
                scale: bounceAnim.value,
                child: child,
              ),
              child: _buildPill(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(BuildContext context) {
    if (isSelected && isHome) {
      // Home active: dark → bright gradient pill
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB02F00), Color(0xFFFF5924)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _IconLabel(
          spec: spec,
          isSelected: true,
          iconColor: Colors.white,
          labelColor: Colors.white,
        ),
      );
    }

    if (isSelected) {
      // Other active tabs: warm light-orange pill
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(32),
        ),
        child: _IconLabel(
          spec: spec,
          isSelected: true,
          iconColor: AppTheme.primary,
          labelColor: AppTheme.primary,
        ),
      );
    }

    // Inactive: just icon + label, muted
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 9.h),
      child: _IconLabel(
        spec: spec,
        isSelected: false,
        iconColor: AppTheme.onSurface.withValues(alpha: 0.35),
        labelColor: AppTheme.onSurface.withValues(alpha: 0.35),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({
    required this.spec,
    required this.isSelected,
    required this.iconColor,
    required this.labelColor,
  });

  final _NavSpec spec;
  final bool isSelected;
  final Color iconColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated icon switch (outlined ↔ filled with scale+fade)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: Tween<double>(begin: 0.55, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOut),
            ),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            isSelected ? spec.filledIcon : spec.outlinedIcon,
            key: ValueKey(isSelected),
            color: iconColor,
            size: 22.sp,
          ),
        ),
        SizedBox(height: 2.h),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: labelColor,
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.3,
          ),
          child: Text(spec.label.toUpperCase()),
        ),
      ],
    );
  }
}

class _NavSpec {
  const _NavSpec({
    required this.label,
    required this.outlinedIcon,
    required this.filledIcon,
  });

  final String label;
  final IconData outlinedIcon;
  final IconData filledIcon;
}

// Keep this accessible for screens that need the nav height for bottom padding
// Approximate: 56h content + system bottom inset (varies per device)
double navBarApproxHeight(BuildContext context) =>
    56.h + MediaQuery.of(context).padding.bottom + 10.h;
