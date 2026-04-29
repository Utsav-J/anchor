import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

/// Rive nav icon: plays once after load, and again whenever [playSignal] changes.
class NavTabRiveIcon extends StatefulWidget {
  const NavTabRiveIcon({
    super.key,
    required this.riveIcon,
    required this.color,
    required this.size,
    required this.strokeWidth,
    required this.playSignal,
  });

  final RiveIcon riveIcon;
  final Color color;
  final double size;
  final double strokeWidth;

  /// Increment from parent on tab tap to replay the icon animation.
  final int playSignal;

  @override
  State<NavTabRiveIcon> createState() => _NavTabRiveIconState();
}

class _NavTabRiveIconState extends State<NavTabRiveIcon> {
  late RiveAsset _cfg;
  SMIBool? _activeInput;
  var _introQueued = false;

  @override
  void initState() {
    super.initState();
    _cfg = widget.riveIcon.getRiveAsset();
  }

  @override
  void didUpdateWidget(covariant NavTabRiveIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.riveIcon != oldWidget.riveIcon) {
      _cfg = widget.riveIcon.getRiveAsset();
    }
    if (widget.playSignal != oldWidget.playSignal) {
      _fireOnce();
    }
  }

  void _fireOnce() {
    final active = _activeInput;
    if (active == null) return;
    active.change(true);
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      active.change(false);
    });
  }

  void _onRiveInit(Artboard artboard) {
    final sm = _cfg.stateMachineName ?? 'State Machine 1';
    final controller =
        RiveUtil.getRiveController(artboard, stateMachineName: sm);
    _activeInput = controller.findSMI('active') as SMIBool?;
    final strokeSmi = controller.findSMI('strokeWidth') as SMINumber?;
    strokeSmi?.value = widget.strokeWidth - 1;

    artboard.forEachComponent((child) {
      if (child is! Shape) return;
      final shape = child;
      final strokeName = _cfg.shapeStrokeTitle;
      if (strokeName != null && shape.name == strokeName) {
        if (shape.strokes.isNotEmpty) {
          shape.strokes.first.paint.color = widget.color;
        }
      }
      final fillName = _cfg.shapeFillTitle;
      if (fillName != null && shape.name == fillName) {
        if (shape.fills.isNotEmpty) {
          shape.fills.first.paint.color = widget.color;
        }
      }
    });

    _activeInput?.change(false);

    if (!_introQueued) {
      _introQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fireOnce();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveAnimation.asset(
        _cfg.src,
        artboard: _cfg.artboard,
        fit: BoxFit.contain,
        onInit: _onRiveInit,
      ),
    );
  }
}
