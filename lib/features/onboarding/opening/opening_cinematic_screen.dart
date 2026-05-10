import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/liquid_glass_action_button.dart';
import '../onboarding_timing.dart';

class OpeningCinematicScreen extends StatefulWidget {
  const OpeningCinematicScreen({super.key});

  @override
  State<OpeningCinematicScreen> createState() => _OpeningCinematicScreenState();
}

class _OpeningCinematicScreenState extends State<OpeningCinematicScreen> {
  bool _showLine1 = false;
  bool _showLine2 = false;
  bool _showButton = false;
  bool _fadeOut = false;

  static const _line1Words = ['How', 'much', 'of', 'last', 'week'];
  final List<bool> _wordVisible = List.filled(5, false);

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(OnboardingTiming.openingBlankHold);
    if (!mounted) return;

    setState(() => _showLine1 = true);
    for (int i = 0; i < _line1Words.length; i++) {
      await Future<void>.delayed(OnboardingTiming.openingLine1WordDelay);
      if (!mounted) return;
      setState(() => _wordVisible[i] = true);
    }

    await Future<void>.delayed(OnboardingTiming.openingPauseBetweenLines);
    if (!mounted) return;

    setState(() => _showLine2 = true);

    await Future<void>.delayed(OnboardingTiming.openingHold);
    if (!mounted) return;

    setState(() => _showButton = true);
  }

  Future<void> _onContinue() async {
    setState(() => _fadeOut = true);
    await Future<void>.delayed(OnboardingTiming.openingFadeOut);
    if (!mounted) return;
    context.go('/onboarding/intro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/onboarding/screen0.png', fit: BoxFit.cover),
          AnimatedOpacity(
            duration: OnboardingTiming.openingFadeOut,
            opacity: _fadeOut ? 0.0 : 1.0,
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 52),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      opacity: _showButton ? 1.0 : 0.0,
                      child: LiquidGlassCircleButton(
                        icon: Icons.arrow_forward_rounded,
                        semanticLabel: 'Continue to setup',
                        onTap: _onContinue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
