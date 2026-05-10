import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_schedule.dart';
import '../../../shared/widgets/liquid_glass_action_button.dart';
import '../onboarding_progress.dart';
import '../onboarding_timing.dart';

// ── Hour/minute helpers ───────────────────────────────────────────────────────
String _hourDisplay(int hour) {
  if (hour == 0 || hour == 24) return '12';
  if (hour == 12) return '12';
  if (hour > 12) return (hour - 12).toString().padLeft(2, '0');
  return hour.toString().padLeft(2, '0');
}

String _minDisplay(int m) => m.toString().padLeft(2, '0');

// Returns AM/PM label. Evening step forces PM unless clearly after midnight.
String _amPmLabel({required int hour, required bool isMorningStep}) {
  if (isMorningStep) return 'AM';
  if (hour == 0 || (hour > 0 && hour < 12)) return 'AM'; // past midnight
  return 'PM';
}

int _nextMin(int m) => (m + 15) % 60;
int _prevMin(int m) => (m - 15 + 60) % 60;

// ── Screen ────────────────────────────────────────────────────────────────────

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _pageController = PageController();
  int _step = 0;
  bool _skipConfirm = false;
  double _cardScale = 1.0;

  // Per-page stagger state
  bool _morningShowHeading = false;
  bool _morningShowSubtext = false;
  bool _morningShowInputs = false;
  bool _eveningShowHeading = false;
  bool _eveningShowSubtext = false;
  bool _eveningShowInputs = false;

  // Morning
  int _wakeH = 7, _wakeM = 0;
  int _leaveH = 9, _leaveM = 0;

  // Evening — defaults per design doc
  int _returnH = 18, _returnM = 0;
  int _sleepH = 23, _sleepM = 0;

  @override
  void initState() {
    super.initState();
    _scheduleStagger(isMorning: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleStagger({required bool isMorning}) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        if (isMorning) {
          _morningShowHeading = true;
        } else {
          _eveningShowHeading = true;
        }
      });
    });
    Future.delayed(const Duration(milliseconds: 430), () {
      if (!mounted) return;
      setState(() {
        if (isMorning) {
          _morningShowSubtext = true;
        } else {
          _eveningShowSubtext = true;
        }
      });
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        if (isMorning) {
          _morningShowInputs = true;
        } else {
          _eveningShowInputs = true;
        }
      });
    });
  }

  Future<void> _goToEvening() async {
    setState(() => _cardScale = 0.97);
    await Future<void>.delayed(OnboardingTiming.inputCardCompress);
    if (!mounted) return;
    setState(() {
      _cardScale = 1.0;
      _step = 1;
      _eveningShowHeading = false;
      _eveningShowSubtext = false;
      _eveningShowInputs = false;
    });
    _pageController.animateToPage(
      1,
      duration: OnboardingTiming.inputPageTransition,
      curve: Curves.easeInOutCubic,
    );
    _scheduleStagger(isMorning: false);
  }

  void _goToMorning() {
    setState(() {
      _step = 0;
      _morningShowHeading = false;
      _morningShowSubtext = false;
      _morningShowInputs = false;
    });
    _pageController.animateToPage(
      0,
      duration: OnboardingTiming.inputPageTransition,
      curve: Curves.easeInOutCubic,
    );
    _scheduleStagger(isMorning: true);
  }

  Future<void> _proceed() async {
    final schedule = UserSchedule(
      wakeTime: TimeOfDay(hour: _wakeH, minute: _wakeM),
      leaveTime: TimeOfDay(hour: _leaveH, minute: _leaveM),
      returnTime: TimeOfDay(hour: _returnH, minute: _returnM),
      sleepTime: TimeOfDay(hour: _sleepH, minute: _sleepM),
    );
    await schedule.save();
    ref.read(userScheduleProvider.notifier).state = schedule;
    await OnboardingProgress.saveStage(OnboardingStage.focus);
    if (mounted) context.go('/onboarding/narrative');
  }

  Future<void> _handleSkip() async {
    if (!_skipConfirm) {
      setState(() => _skipConfirm = true);
      return;
    }
    await OnboardingProgress.saveStage(OnboardingStage.focus);
    if (mounted) context.go('/onboarding/focus-filter');
  }

  // ── Sleep hour cycling: 20 PM → 23 PM → 0 AM → 2 AM (capped) ──────────────
  void _incSleepH() => setState(() {
    if (_sleepH == 2) return;
    _sleepH = _sleepH == 23 ? 0 : _sleepH + 1;
  });

  void _decSleepH() => setState(() {
    if (_sleepH == 20) return;
    _sleepH = _sleepH == 0 ? 23 : _sleepH - 1;
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == 1) _goToMorning();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Night image (base layer — always present)
            Positioned.fill(
              child: Image.asset(
                'assets/onboarding/image.png',
                fit: BoxFit.cover,
              ),
            ),
            // Morning image crossfades out when going to evening
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _step == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/onboarding/morning.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        _StepDots(step: _step, isNight: _step == 1),
                        const Spacer(),
                        _SkipButton(confirm: _skipConfirm, onTap: _handleSkip),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedScale(
                      scale: _cardScale,
                      duration: OnboardingTiming.inputCardCompress,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [_buildMorningPage(), _buildEveningPage()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Morning page ──────────────────────────────────────────────────────────

  Widget _buildMorningPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedEntry(
            visible: _morningShowHeading,
            child: Text(
              'Your morning',
              style: AppTheme.notoSerif(fontSize: 30, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          _AnimatedEntry(
            visible: _morningShowSubtext,
            child: Text(
              'The quiet hours before the world claims you.',
              style: AppTheme.notoSerif(
                fontSize: 14,
                color: AppTheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _AnimatedEntry(
            visible: _morningShowInputs,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTimeCard(
                  label: 'What time do you wake up?',
                  hour: _wakeH,
                  minute: _wakeM,
                  isMorningStep: true,
                  onHourInc: () => setState(() {
                    final max = _leaveH - 1;
                    _wakeH = (_wakeH < max) ? _wakeH + 1 : _wakeH;
                  }),
                  onHourDec: () => setState(
                    () => _wakeH = (_wakeH > 4) ? _wakeH - 1 : _wakeH,
                  ),
                  onMinInc: () => setState(() => _wakeM = _nextMin(_wakeM)),
                  onMinDec: () => setState(() => _wakeM = _prevMin(_wakeM)),
                ),
                const SizedBox(height: 16),
                _buildTimeCard(
                  label: 'What time do you leave for work?',
                  hour: _leaveH,
                  minute: _leaveM,
                  isMorningStep: true,
                  onHourInc: () => setState(
                    () => _leaveH = (_leaveH < 12) ? _leaveH + 1 : _leaveH,
                  ),
                  onHourDec: () => setState(() {
                    final min = _wakeH + 1;
                    _leaveH = (_leaveH > min) ? _leaveH - 1 : _leaveH;
                  }),
                  onMinInc: () => setState(() => _leaveM = _nextMin(_leaveM)),
                  onMinDec: () => setState(() => _leaveM = _prevMin(_leaveM)),
                ),
                const SizedBox(height: 36),
                LiquidGlassActionButton(
                  label: 'Next',
                  icon: Icons.arrow_forward_rounded,
                  onTap: _goToEvening,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Evening page ──────────────────────────────────────────────────────────

  Widget _buildEveningPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedEntry(
            visible: _eveningShowHeading,
            child: Text(
              'Your evening',
              style: AppTheme.notoSerif(
                fontSize: 30,
                weight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _AnimatedEntry(
            visible: _eveningShowSubtext,
            child: Text(
              'The hours the world hands back to you.',
              style: AppTheme.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _AnimatedEntry(
            visible: _eveningShowInputs,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTimeCard(
                  label: 'Get home from work',
                  hour: _returnH,
                  minute: _returnM,
                  isMorningStep: false,
                  onHourInc: () => setState(
                    () => _returnH = (_returnH < 22) ? _returnH + 1 : _returnH,
                  ),
                  onHourDec: () => setState(
                    () => _returnH = (_returnH > 12) ? _returnH - 1 : _returnH,
                  ),
                  onMinInc: () => setState(() => _returnM = _nextMin(_returnM)),
                  onMinDec: () => setState(() => _returnM = _prevMin(_returnM)),
                ),
                const SizedBox(height: 16),
                _buildTimeCard(
                  label: 'When do you go to bed?',
                  hour: _sleepH,
                  minute: _sleepM,
                  isMorningStep: false,
                  onHourInc: _incSleepH,
                  onHourDec: _decSleepH,
                  onMinInc: () => setState(() => _sleepM = _nextMin(_sleepM)),
                  onMinDec: () => setState(() => _sleepM = _prevMin(_sleepM)),
                ),
                const SizedBox(height: 36),
                Row(
                  children: [
                    LiquidGlassCircleButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: 'Back to morning',
                      onTap: _goToMorning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LiquidGlassActionButton(
                        label: 'Show me',
                        icon: Icons.play_arrow_rounded,
                        onTap: _proceed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Glass time picker card ─────────────────────────────────────────────────

  Widget _buildTimeCard({
    required String label,
    required int hour,
    required int minute,
    required bool isMorningStep,
    required VoidCallback onHourInc,
    required VoidCallback onHourDec,
    required VoidCallback onMinInc,
    required VoidCallback onMinDec,
  }) {
    final amPm = _amPmLabel(hour: hour, isMorningStep: isMorningStep);
    final isNight = !isMorningStep;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.23),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: isNight ? 0.18 : 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.inter(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  weight: FontWeight.w600,
                  color: isNight
                      ? Colors.white.withValues(alpha: 0.55)
                      : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimeBox(
                    value: _hourDisplay(hour),
                    onInc: onHourInc,
                    onDec: onHourDec,
                    isNight: isNight,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      ':',
                      style: AppTheme.notoSerif(
                        fontSize: 44,
                        weight: FontWeight.w300,
                        color: isNight
                            ? Colors.white.withValues(alpha: 0.35)
                            : AppTheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  _TimeBox(
                    value: _minDisplay(minute),
                    onInc: onMinInc,
                    onDec: onMinDec,
                    isNight: isNight,
                  ),
                  const SizedBox(width: 16),
                  _AmPmBadge(label: amPm, isNight: isNight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Staggered entry animation ─────────────────────────────────────────────────

class _AnimatedEntry extends StatelessWidget {
  const _AnimatedEntry({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      opacity: visible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        offset: visible ? Offset.zero : const Offset(0, 0.08),
        child: child,
      ),
    );
  }
}

// ── Scrollable time digit box ─────────────────────────────────────────────────

class _TimeBox extends StatefulWidget {
  const _TimeBox({
    required this.value,
    required this.onInc,
    required this.onDec,
    this.isNight = false,
  });

  final String value;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final bool isNight;

  @override
  State<_TimeBox> createState() => _TimeBoxState();
}

class _TimeBoxState extends State<_TimeBox> {
  double _drag = 0;
  static const _kThreshold = 18.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (d) {
        _drag += d.delta.dy;
        if (_drag > _kThreshold) {
          // drag down = later time = increment
          widget.onInc();
          _drag = 0;
        } else if (_drag < -_kThreshold) {
          // drag up = earlier time = decrement
          widget.onDec();
          _drag = 0;
        }
      },
      onVerticalDragEnd: (_) => _drag = 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Up = earlier time = decrement
          _ArrowTap(
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: widget.onDec,
            isNight: widget.isNight,
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: OnboardingTiming.inputDigitSwitch,
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              widget.value,
              key: ValueKey(widget.value),
              style: AppTheme.notoSerif(
                fontSize: 46,
                weight: FontWeight.w300,
                color: widget.isNight ? Colors.white : AppTheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Down = later time = increment
          _ArrowTap(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: widget.onInc,
            isNight: widget.isNight,
          ),
        ],
      ),
    );
  }
}

// ── Small private widgets ─────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, this.isNight = false});
  final int step;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (i) {
        final active = i == step;
        return AnimatedContainer(
          duration: OnboardingTiming.inputDotTransition,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? (isNight ? Colors.white : AppTheme.primary)
                : Colors.white.withValues(alpha: isNight ? 0.35 : 0.18),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.confirm, required this.onTap});
  final bool confirm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: OnboardingTiming.inputDotTransition,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: confirm ? 0.4 : 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: AnimatedSwitcher(
              duration: OnboardingTiming.inputSkipSwitch,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                confirm ? 'Jump straight into it' : 'Skip',
                key: ValueKey(confirm),
                style: AppTheme.inter(
                  fontSize: 13,
                  weight: FontWeight.w500,
                  color: confirm
                      ? AppTheme.primary
                      : AppTheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmPmBadge extends StatelessWidget {
  const _AmPmBadge({required this.label, this.isNight = false});
  final String label;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: OnboardingTiming.inputAmPmSwitch,
      child: Text(
        label,
        key: ValueKey(label),
        style: AppTheme.inter(
          fontSize: 16,
          weight: FontWeight.w600,
          color: isNight
              ? Colors.white
              : AppTheme.primary.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _ArrowTap extends StatelessWidget {
  const _ArrowTap({
    required this.icon,
    required this.onTap,
    this.isNight = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 32,
        child: Icon(
          icon,
          size: 26,
          color: isNight
              ? Colors.white.withValues(alpha: 0.45)
              : AppTheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
