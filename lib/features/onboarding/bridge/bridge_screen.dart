import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../focus_filter/focus_filter_notifier.dart';
import '../focus_filter/widgets/category_bubble.dart';
import '../onboarding_timing.dart';

const _kCategoryLines = <String, String>{
  'Creative': 'Oooh, Creative.\nLooks like we have an artist in our hands.',
  'Movement': 'Movement!\nSomeone who knows the body keeps score.',
  'Reflective': 'Reflective.\nA thinker. The world needs more of those.',
  'Skill-Building': 'Skill-Building!\nAlways leveling up. We respect that.',
  'Environment-Shaping':
      'Environment-Shaping.\nYou build the spaces that build you.',
  'Future-Oriented': 'Future-Oriented!\nAlways three moves ahead.',
  'Connection': 'Connection.\nBecause people are the whole point.',
};

class BridgeScreen extends ConsumerStatefulWidget {
  const BridgeScreen({super.key});

  @override
  ConsumerState<BridgeScreen> createState() => _BridgeScreenState();
}

class _BridgeScreenState extends ConsumerState<BridgeScreen>
    with SingleTickerProviderStateMixin {
  bool _showLine1 = false;
  bool _showLine2 = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: OnboardingTiming.bridgeCategoryPulse,
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Fire confetti on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Left burst
      Confetti.launch(
        context,
        options: const ConfettiOptions(
          particleCount: 60,
          spread: 55,
          x: 0.25,
          y: 0.2,
          angle: 60,
          startVelocity: 35,
          gravity: 0.8,
          scalar: 0.9,
          colors: [
            Color(0xFFFFAA78),
            Color(0xFFFF5924),
            Color(0xFFB02F00),
            Color(0xFFFFDFA0),
            Color(0xFFFFC060),
          ],
        ),
      );
      // Right burst
      Confetti.launch(
        context,
        options: const ConfettiOptions(
          particleCount: 60,
          spread: 55,
          x: 0.75,
          y: 0.2,
          angle: 120,
          startVelocity: 35,
          gravity: 0.8,
          scalar: 0.9,
          colors: [
            Color(0xFFFFAA78),
            Color(0xFFFF5924),
            Color(0xFFB02F00),
            Color(0xFFFFDFA0),
            Color(0xFFFFC060),
          ],
        ),
      );
    });

    await Future<void>.delayed(OnboardingTiming.bridgeLine1FadeIn);
    if (!mounted) return;
    setState(() => _showLine1 = true);

    // Pulse the category name
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());

    await Future<void>.delayed(OnboardingTiming.bridgeLine2Delay);
    if (!mounted) return;
    setState(() => _showLine2 = true);

    await Future<void>.delayed(
      OnboardingTiming.bridgeAutoAdvance - OnboardingTiming.bridgeLine2Delay,
    );
    if (!mounted) return;
    context.go('/onboarding/quickies');
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusConfig = ref.watch(activeFocusPriorityProvider);
    final fallbackState = ref.watch(focusFilterProvider);
    final selected =
        focusConfig?.orderedCategories ?? fallbackState.selected;
    final p1 = selected.isNotEmpty ? selected.first : 'Creative';
    final cheerfulLine = _kCategoryLines[p1] ?? _kCategoryLines['Creative']!;
    final gradientColors =
        CategoryBubble.gradientColorsFor(p1, selected: true);

    return Scaffold(
      body: Container(
        color: const Color(0xFFFAF5F0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cheerful line with category in gradient+italic
                AnimatedOpacity(
                  duration: OnboardingTiming.bridgeLine1FadeIn,
                  opacity: _showLine1 ? 1.0 : 0.0,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, child) {
                      final scale = 1.0 + _pulseCtrl.value * 0.04;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => LinearGradient(
                        colors: gradientColors,
                      ).createShader(bounds),
                      child: Text(
                        cheerfulLine,
                        textAlign: TextAlign.center,
                        style: AppTheme.notoSerif(
                          fontSize: 24,
                          weight: FontWeight.w500,
                          italic: true,
                          height: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedOpacity(
                  duration: OnboardingTiming.bridgeLine2FadeIn,
                  opacity: _showLine2 ? 1.0 : 0.0,
                  child: Text(
                    'What does that look like for you?',
                    textAlign: TextAlign.center,
                    style: AppTheme.notoSerif(
                      fontSize: 20,
                      weight: FontWeight.w300,
                      color: AppTheme.onSurface.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
