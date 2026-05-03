import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../onboarding_timing.dart';

const _kMorningColors = [
  Color(0xFFFFF6E8),
  Color(0xFFFFDFA0),
  Color(0xFFFFC060),
];
const _kEveningColors = [
  Color(0xFFFFEEE4),
  Color(0xFFFFAA78),
  Color(0xFFDD4A18),
];

class OpeningCinematicScreen extends StatefulWidget {
  const OpeningCinematicScreen({super.key});

  @override
  State<OpeningCinematicScreen> createState() => _OpeningCinematicScreenState();
}

class _OpeningCinematicScreenState extends State<OpeningCinematicScreen>
    with TickerProviderStateMixin {
  late final AnimationController _gradientCtrl;
  late final AnimationController _sequenceCtrl;

  bool _showLine1 = false;
  bool _showLine2 = false;
  bool _fadeOut = false;

  static const _line1Words = ['How', 'much', 'of', 'last', 'week'];
  final List<bool> _wordVisible = List.filled(5, false);

  @override
  void initState() {
    super.initState();

    _gradientCtrl = AnimationController(
      vsync: this,
      duration: OnboardingTiming.openingGradientCycle,
    )..repeat(reverse: true);

    _sequenceCtrl = AnimationController(vsync: this, duration: Duration.zero);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(OnboardingTiming.openingBlankHold);
    if (!mounted) return;

    // Fade in line 1 word by word
    setState(() => _showLine1 = true);
    for (int i = 0; i < _line1Words.length; i++) {
      await Future<void>.delayed(OnboardingTiming.openingLine1WordDelay);
      if (!mounted) return;
      setState(() => _wordVisible[i] = true);
    }

    await Future<void>.delayed(OnboardingTiming.openingPauseBetweenLines);
    if (!mounted) return;

    // Fade in line 2
    setState(() => _showLine2 = true);

    await Future<void>.delayed(OnboardingTiming.openingHold);
    if (!mounted) return;

    // Fade out everything
    setState(() => _fadeOut = true);

    await Future<void>.delayed(OnboardingTiming.openingFadeOut);
    if (!mounted) return;

    context.go('/onboarding/intro');
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _sequenceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientCtrl,
        builder: (context, child) {
          final t = _gradientCtrl.value;
          final colors = [
            for (int i = 0; i < 3; i++)
              Color.lerp(_kMorningColors[i], _kEveningColors[i], t)!,
          ];
          return AnimatedOpacity(
            duration: OnboardingTiming.openingFadeOut,
            opacity: _fadeOut ? 0.0 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: child,
            ),
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Line 1: word by word
                if (_showLine1)
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (int i = 0; i < _line1Words.length; i++)
                        AnimatedOpacity(
                          duration: OnboardingTiming.openingLine1FadeIn,
                          curve: Curves.easeIn,
                          opacity: _wordVisible[i] ? 1.0 : 0.0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              _line1Words[i],
                              style: AppTheme.notoSerif(
                                fontSize: 28,
                                weight: FontWeight.w400,
                                color: AppTheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 8),
                // Line 2: single fade
                AnimatedOpacity(
                  duration: OnboardingTiming.openingLine2FadeIn,
                  curve: Curves.easeIn,
                  opacity: _showLine2 ? 1.0 : 0.0,
                  child: Text(
                    'was truly yours?',
                    textAlign: TextAlign.center,
                    style: AppTheme.notoSerif(
                      fontSize: 28,
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
