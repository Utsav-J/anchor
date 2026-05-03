import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/liquid_glass_action_button.dart';
import '../onboarding_progress.dart';
import '../onboarding_timing.dart';

const _kWarmGradient = [
  Color(0xFFFFF6E8),
  Color(0xFFFFDFA0),
  Color(0xFFFFC060),
];

class BrandArrivalScreen extends StatefulWidget {
  const BrandArrivalScreen({super.key});

  @override
  State<BrandArrivalScreen> createState() => _BrandArrivalScreenState();
}

class _BrandArrivalScreenState extends State<BrandArrivalScreen> {
  bool _showAnchor = false;
  bool _showTagline = false;
  bool _showCta = false;
  double _gradientBlend = 0.0;

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Start gradient fade to warm
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _gradientBlend = 1.0);

    // Show "Anchor."
    await Future<void>.delayed(OnboardingTiming.arrivalAnchorFadeIn);
    if (!mounted) return;
    setState(() => _showAnchor = true);

    await Future<void>.delayed(OnboardingTiming.arrivalAnchorHold);
    if (!mounted) return;

    // Show tagline
    setState(() => _showTagline = true);

    await Future<void>.delayed(OnboardingTiming.arrivalTaglineHold);
    if (!mounted) return;

    // Show CTA
    setState(() => _showCta = true);
  }

  Future<void> _onClaim() async {
    await OnboardingProgress.saveStage(OnboardingStage.complete);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: OnboardingTiming.arrivalGradientFade,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(
                const Color(0xFFFAF5F0),
                _kWarmGradient[0],
                _gradientBlend,
              )!,
              Color.lerp(
                const Color(0xFFFAF5F0),
                _kWarmGradient[1],
                _gradientBlend,
              )!,
              Color.lerp(
                const Color(0xFFFAF5F0),
                _kWarmGradient[2],
                _gradientBlend,
              )!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Anchor."
                  AnimatedOpacity(
                    duration: OnboardingTiming.arrivalAnchorFadeIn,
                    opacity: _showAnchor ? 1.0 : 0.0,
                    child: Text(
                      'Anchor.',
                      style: AppTheme.notoSerif(
                        fontSize: 52,
                        weight: FontWeight.w300,
                        italic: true,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // "Your time. Protected."
                  AnimatedOpacity(
                    duration: OnboardingTiming.arrivalTaglineFadeIn,
                    opacity: _showTagline ? 1.0 : 0.0,
                    child: Text(
                      'Your time. Protected.',
                      textAlign: TextAlign.center,
                      style: AppTheme.notoSerif(
                        fontSize: 20,
                        weight: FontWeight.w300,
                        color: AppTheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // CTA
                  AnimatedOpacity(
                    duration: OnboardingTiming.arrivalCtaFadeIn,
                    opacity: _showCta ? 1.0 : 0.0,
                    child: AnimatedScale(
                      scale: _showCta ? 1.0 : 0.9,
                      duration: OnboardingTiming.arrivalCtaFadeIn,
                      child: LiquidGlassActionButton(
                        label: 'Claim this week',
                        icon: Icons.arrow_forward_rounded,
                        onTap: _onClaim,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
