import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import '../../core/theme/app_theme.dart';
import 'nav_tab_rive_icon.dart';

class AnchorShell extends StatefulWidget {
  const AnchorShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<AnchorShell> createState() => _AnchorShellState();
}

/// Matched to [LGBottomBar] sizing in this shell.
var _kLiquidNavBarHeight = 96.0.h;
var _kLiquidNavVerticalPadding = 12.0;

class _AnchorShellState extends State<AnchorShell> {
  /// Incremented per tab on tap so [NavTabRiveIcon] replays once.
  final List<int> _tabPlaySignals = [0, 0, 0];

  void _onSelect(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _tabPlaySignals[index]++;
    });
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final iconSize = 30.sp;
    final stroke = 14.0;

    final selectedInk = AppTheme.onSurface;
    final unselectedInk = AppTheme.onSurface.withValues(alpha: 0.42);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.navigationShell.currentIndex != 0) {
          _onSelect(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        extendBody: true,
        body: Stack(
          children: [
            widget.navigationShell,
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomSafe),
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: LGBottomBar(
                    quality: LGQuality.premium,
                    isSearch: false,
                    showLabel: false,
                    barHeight: _kLiquidNavBarHeight,
                    barBorderRadius: 28,
                    horizontalPadding: 14,
                    verticalPadding: _kLiquidNavVerticalPadding,
                    blendAmount: 1,
                    iconSize: iconSize,
                    indicatorColor: AppTheme.onSurface.withValues(alpha: 0.08),
                    glassSettings: LiquidGlassSettings(
                      thickness: 26,
                      blur: 10,
                      chromaticAberration: 0.22,
                      lightIntensity: 0.5,
                      refractiveIndex: 1.52,
                      saturation: 0.62,
                      ambientStrength: 1,
                      lightAngle: 0.25 * 3.141592653589793,
                      glassColor: const Color(0x5AFFF8F6),
                    ),
                    indicatorSettings: const LiquidGlassSettings(
                      thickness: 18,
                      blur: 0,
                      chromaticAberration: 0.35,
                      lightIntensity: 1.4,
                      refractiveIndex: 1.12,
                      saturation: 1.2,
                      glassColor: Color(0x14FFFFFF),
                    ),
                    selectedIconColor: selectedInk,
                    unselectedIconColor: unselectedInk,
                    selectedLabelColor: selectedInk,
                    unselectedLabelColor: unselectedInk,
                    textStyle: AppTheme.inter(
                      fontSize: 10.sp,
                      weight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    tabs: [
                      LGBottomBarTab(
                        label: 'Home',
                        iconWidget: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            widget.navigationShell.currentIndex == 0
                                ? selectedInk
                                : unselectedInk,
                            BlendMode.srcIn,
                          ),
                          child: NavTabRiveIcon(
                            key: const ValueKey('nav-rive-home'),
                            riveIcon: RiveIcon.home,
                            color: Colors.white,
                            size: iconSize,
                            strokeWidth: stroke,
                            playSignal: _tabPlaySignals[0],
                          ),
                        ),
                      ),
                      LGBottomBarTab(
                        label: 'My Week',
                        iconWidget: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            widget.navigationShell.currentIndex == 1
                                ? selectedInk
                                : unselectedInk,
                            BlendMode.srcIn,
                          ),
                          child: NavTabRiveIcon(
                            key: const ValueKey('nav-rive-zap'),
                            riveIcon: RiveIcon.zap,
                            color: Colors.white,
                            size: iconSize,
                            strokeWidth: stroke,
                            playSignal: _tabPlaySignals[1],
                          ),
                        ),
                      ),
                      LGBottomBarTab(
                        label: 'Me',
                        iconWidget: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            widget.navigationShell.currentIndex == 2
                                ? selectedInk
                                : unselectedInk,
                            BlendMode.srcIn,
                          ),
                          child: NavTabRiveIcon(
                            key: const ValueKey('nav-rive-profile'),
                            riveIcon: RiveIcon.profile,
                            color: Colors.white,
                            size: iconSize,
                            strokeWidth: stroke,
                            playSignal: _tabPlaySignals[2],
                          ),
                        ),
                      ),
                    ],
                    selectedIndex: widget.navigationShell.currentIndex,
                    onTabSelected: _onSelect,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Approximate total height reserved by the floating liquid nav + system inset.
double navBarApproxHeight(BuildContext context) =>
    (_kLiquidNavVerticalPadding * 2 + _kLiquidNavBarHeight).h +
    MediaQuery.of(context).padding.bottom;
