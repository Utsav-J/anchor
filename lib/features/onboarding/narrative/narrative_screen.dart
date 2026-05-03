import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_schedule.dart';
import '../../../shared/widgets/liquid_glass_action_button.dart';
import '../onboarding_timing.dart';

// ── Beat types ────────────────────────────────────────────────────────────────

enum _BeatType {
  morningContext,
  morningWindow,
  morningFlip,
  eveningContext,
  eveningWindow,
  eveningWork,
  eveningRoutine,
  total,
  mirror,
  turn,
}

class _Beat {
  const _Beat(this.type, this.duration);
  final _BeatType type;
  final Duration duration;
}

// ── Precomputed values from the user's schedule ───────────────────────────────

class _NarrativeData {
  _NarrativeData(UserSchedule s) {
    morningWindow = s.morningWindowHours;
    eveningWindow = s.eveningWindowHours;
    morningOwned = s.morningOwnedHours;
    eveningAfterWork = s.eveningAfterWorkHours;
    eveningOwned = s.eveningOwnedHours;
    daily = s.dailyOwnedHours;
    weekly = s.weeklyOwnedHours;
    hasMorning = s.hasMorningWindow;
    wakeLabel = _label(s.wakeTime);
    leaveLabel = _label(s.leaveTime);
    returnLabel = _label(s.returnTime);
    sleepLabel = _label(s.sleepTime);
  }

  late final int morningWindow, eveningWindow;
  late final int morningOwned, eveningAfterWork, eveningOwned;
  late final int daily, weekly;
  late final bool hasMorning;
  late final String wakeLabel, leaveLabel, returnLabel, sleepLabel;

  static String _label(TimeOfDay t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    final minStr =
        t.minute == 0 ? '' : ':${t.minute.toString().padLeft(2, '0')}';
    return '$h$minStr $ampm';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class NarrativeScreen extends ConsumerStatefulWidget {
  const NarrativeScreen({super.key});

  @override
  ConsumerState<NarrativeScreen> createState() => _NarrativeScreenState();
}

class _NarrativeScreenState extends ConsumerState<NarrativeScreen> {
  late final _NarrativeData _data;
  late final List<_Beat> _beats;

  int _beatIndex = 0;
  int _currentNumber = 0;
  bool _skipConfirm = false;
  Timer? _beatTimer;

  @override
  void initState() {
    super.initState();
    final schedule =
        ref.read(userScheduleProvider) ?? UserSchedule.defaults;
    _data = _NarrativeData(schedule);
    _beats = _buildBeats();
    _currentNumber = _data.hasMorning
        ? _data.morningWindow
        : _data.eveningWindow;
    _scheduleNext();
  }

  List<_Beat> _buildBeats() => [
        if (_data.hasMorning) ...[
          _Beat(_BeatType.morningContext, OnboardingTiming.beatMorningContext),
          _Beat(_BeatType.morningWindow, OnboardingTiming.beatMorningWindow),
          _Beat(_BeatType.morningFlip, OnboardingTiming.beatMorningFlip),
        ],
        _Beat(_BeatType.eveningContext, OnboardingTiming.beatEveningContext),
        _Beat(_BeatType.eveningWindow, OnboardingTiming.beatEveningWindow),
        _Beat(_BeatType.eveningWork, OnboardingTiming.beatEveningWork),
        _Beat(_BeatType.eveningRoutine, OnboardingTiming.beatEveningRoutine),
        _Beat(_BeatType.total, OnboardingTiming.beatTotal),
        _Beat(_BeatType.mirror, OnboardingTiming.beatMirror),
        // Turn does not auto-advance — user taps CTA
        const _Beat(_BeatType.turn, Duration(days: 1)),
      ];

  void _scheduleNext() {
    if (_beatIndex >= _beats.length - 1) return;
    _beatTimer = Timer(_beats[_beatIndex].duration, () {
      if (!mounted) return;
      final next = _beatIndex + 1;
      final nextType = _beats[next].type;

      int? newNumber;
      switch (nextType) {
        case _BeatType.morningWindow:
          newNumber = _data.morningWindow;
        case _BeatType.morningFlip:
          newNumber = _data.morningOwned;
        case _BeatType.eveningWindow:
          newNumber = _data.eveningWindow;
        case _BeatType.eveningWork:
          newNumber = _data.eveningAfterWork;
        case _BeatType.eveningRoutine:
          newNumber = _data.eveningOwned;
        default:
          break;
      }

      setState(() {
        _beatIndex = next;
        if (newNumber != null) _currentNumber = newNumber;
      });
      _scheduleNext();
    });
  }

  void _handleSkip() {
    if (!_skipConfirm) {
      setState(() => _skipConfirm = true);
      return;
    }
    _beatTimer?.cancel();
    context.go('/onboarding/focus-filter');
  }

  void _onTurnTap() {
    _beatTimer?.cancel();
    context.go('/onboarding/focus-filter');
  }

  @override
  void dispose() {
    _beatTimer?.cancel();
    super.dispose();
  }

  _BeatType get _currentType => _beats[_beatIndex].type;
  bool get _isMirror => _currentType == _BeatType.mirror;
  bool get _isTurn => _currentType == _BeatType.turn;
  bool get _showSkip => !_isTurn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cream background
          Container(color: const Color(0xFFFAF5F0)),
          // Mirror dim overlay (8% black)
          AnimatedOpacity(
            duration: OnboardingTiming.mirrorDimOverlay,
            curve: Curves.easeInOut,
            opacity: _isMirror ? 1.0 : 0.0,
            child: Container(
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                if (_showSkip)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 20, 0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: _SkipButton(
                        confirm: _skipConfirm,
                        onTap: _handleSkip,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 14),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: OnboardingTiming.narrativeBeatFade,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: _buildBeatContent(key: ValueKey(_beatIndex)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeatContent({required Key key}) {
    return switch (_currentType) {
      _BeatType.morningContext => _ContextBeat(
          key: key,
          line1: 'You woke up at ${_data.wakeLabel}.',
          line2: 'Left for work at ${_data.leaveLabel}.',
        ),
      _BeatType.morningWindow => _NumberBeat(
          key: key,
          number: _currentNumber,
          supporting: 'hours in the morning.',
        ),
      _BeatType.morningFlip => _FlipBeat(
          key: key,
          number: _currentNumber,
          supporting: 'Getting ready. Commuting.',
          extraLine: _buildMorningFlipExtra(),
        ),
      _BeatType.eveningContext => _ContextBeat(
          key: key,
          line1: 'You got home at ${_data.returnLabel}.',
          line2: 'You sleep at ${_data.sleepLabel}.',
        ),
      _BeatType.eveningWindow => _NumberBeat(
          key: key,
          number: _currentNumber,
          supporting: 'hours in the evening.',
        ),
      _BeatType.eveningWork => _FlipBeat(
          key: key,
          number: _currentNumber,
          supporting: 'Work still bleeds in.',
        ),
      _BeatType.eveningRoutine => _FlipBeat(
          key: key,
          number: _currentNumber,
          supporting: 'Getting fresh. Making food.',
        ),
      _BeatType.total => _TotalBeat(key: key, data: _data),
      _BeatType.mirror => _MirrorBeat(key: key),
      _BeatType.turn => _TurnBeat(key: key, onTap: _onTurnTap),
    };
  }

  Widget _buildMorningFlipExtra() {
    final n = _data.morningOwned;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$n ${n == 1 ? 'hour' : 'hours'}. ',
            style: AppTheme.notoSerif(
              fontSize: 16,
              color: AppTheme.onSurface.withValues(alpha: 0.45),
              height: 1.4,
            ),
          ),
          TextSpan(
            text: 'Maybe',
            style: AppTheme.notoSerif(
              fontSize: 16,
              italic: true,
              color: AppTheme.primary,
              height: 1.4,
            ),
          ),
          TextSpan(
            text: ' yours.',
            style: AppTheme.notoSerif(
              fontSize: 16,
              color: AppTheme.onSurface.withValues(alpha: 0.45),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Context beat (two lines fading in) ────────────────────────────────────────

class _ContextBeat extends StatefulWidget {
  const _ContextBeat({
    super.key,
    required this.line1,
    required this.line2,
  });
  final String line1, line2;

  @override
  State<_ContextBeat> createState() => _ContextBeatState();
}

class _ContextBeatState extends State<_ContextBeat> {
  bool _show1 = false, _show2 = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 50)).then((_) {
      if (mounted) setState(() => _show1 = true);
    });
    final delay = OnboardingTiming.narrativeLineFadeIn +
        OnboardingTiming.narrativeLinePause;
    Future<void>.delayed(delay).then((_) {
      if (mounted) setState(() => _show2 = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              duration: OnboardingTiming.narrativeLineFadeIn,
              opacity: _show1 ? 1.0 : 0.0,
              child: Text(
                widget.line1,
                textAlign: TextAlign.center,
                style: AppTheme.notoSerif(
                  fontSize: 22,
                  weight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              duration: OnboardingTiming.narrativeLineFadeIn,
              opacity: _show2 ? 1.0 : 0.0,
              child: Text(
                widget.line2,
                textAlign: TextAlign.center,
                style: AppTheme.notoSerif(
                  fontSize: 22,
                  weight: FontWeight.w300,
                  color: AppTheme.onSurface.withValues(alpha: 0.65),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Number beat (large number scales up + supporting text) ────────────────────

class _NumberBeat extends StatefulWidget {
  const _NumberBeat({
    super.key,
    required this.number,
    required this.supporting,
  });
  final int number;
  final String supporting;

  @override
  State<_NumberBeat> createState() => _NumberBeatState();
}

class _NumberBeatState extends State<_NumberBeat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: OnboardingTiming.narrativeNumberScaleUp,
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
    Future<void>.delayed(
      OnboardingTiming.narrativeNumberScaleUp +
          OnboardingTiming.narrativeNumberTextDelay,
    ).then((_) {
      if (mounted) setState(() => _showText = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Text(
                '${widget.number}',
                style: AppTheme.notoSerif(
                  fontSize: 96,
                  weight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: OnboardingTiming.narrativeNumberTextDelay,
              opacity: _showText ? 1.0 : 0.0,
              child: Text(
                widget.supporting,
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  fontSize: 16,
                  color: AppTheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Flip beat (number flips down + supporting text) ───────────────────────────

class _FlipBeat extends StatefulWidget {
  const _FlipBeat({
    super.key,
    required this.number,
    required this.supporting,
    this.extraLine,
  });
  final int number;
  final String supporting;
  final Widget? extraLine;

  @override
  State<_FlipBeat> createState() => _FlipBeatState();
}

class _FlipBeatState extends State<_FlipBeat> {
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(
      OnboardingTiming.narrativeFlipDown + OnboardingTiming.narrativeFlipTextDelay,
    ).then((_) {
      if (mounted) setState(() => _showText = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: OnboardingTiming.narrativeFlipDown,
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                '${widget.number}',
                key: ValueKey(widget.number),
                style: AppTheme.notoSerif(
                  fontSize: 96,
                  weight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: OnboardingTiming.narrativeFlipTextDelay,
              opacity: _showText ? 1.0 : 0.0,
              child: Text(
                widget.supporting,
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  fontSize: 16,
                  color: AppTheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ),
            if (widget.extraLine != null) ...[
              const SizedBox(height: 6),
              AnimatedOpacity(
                duration: OnboardingTiming.narrativeFlipTextDelay,
                opacity: _showText ? 1.0 : 0.0,
                child: widget.extraLine!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Total beat (sequential equation reveal) ───────────────────────────────────

class _TotalBeat extends StatefulWidget {
  const _TotalBeat({super.key, required this.data});
  final _NarrativeData data;

  @override
  State<_TotalBeat> createState() => _TotalBeatState();
}

class _TotalBeatState extends State<_TotalBeat> {
  int _phase = 0;
  // Phase 0: nothing
  // Phase 1-5: sequential equation elements
  // Phase 6: "Every day."
  // Phase 7: weekly total

  @override
  void initState() {
    super.initState();
    _advancePhases();
  }

  Future<void> _advancePhases() async {
    final stagger = OnboardingTiming.totalElementStagger;
    final elements = widget.data.hasMorning ? 5 : 3;
    // Show equation elements one by one
    for (int i = 1; i <= elements; i++) {
      await Future<void>.delayed(stagger);
      if (!mounted) return;
      setState(() => _phase = i);
    }
    // "Every day."
    await Future<void>.delayed(OnboardingTiming.totalEveryDayDelay);
    if (!mounted) return;
    setState(() => _phase = elements + 1);
    // Weekly total
    await Future<void>.delayed(OnboardingTiming.totalWeeklyDelay);
    if (!mounted) return;
    setState(() => _phase = elements + 2);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final numStyle = AppTheme.notoSerif(
      fontSize: 48,
      weight: FontWeight.w300,
    );
    final opStyle = AppTheme.inter(
      fontSize: 28,
      weight: FontWeight.w300,
      color: AppTheme.onSurface.withValues(alpha: 0.4),
    );

    // Build equation elements based on whether morning exists
    final List<_EquationElement> eqElements;
    if (d.hasMorning) {
      eqElements = [
        _EquationElement(Text('${d.morningOwned}', style: numStyle)),
        _EquationElement(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('+', style: opStyle),
        )),
        _EquationElement(Text('${d.eveningOwned}', style: numStyle)),
        _EquationElement(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('=', style: opStyle),
        )),
        _EquationElement(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${d.daily}',
              style: AppTheme.notoSerif(
                fontSize: 48,
                weight: FontWeight.w400,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'hours.',
              style: AppTheme.inter(
                fontSize: 16,
                color: AppTheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        )),
      ];
    } else {
      eqElements = [
        _EquationElement(Text('${d.eveningOwned}', style: numStyle)),
        _EquationElement(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('=', style: opStyle),
        )),
        _EquationElement(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${d.daily}',
              style: AppTheme.notoSerif(
                fontSize: 48,
                weight: FontWeight.w400,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'hours.',
              style: AppTheme.inter(
                fontSize: 16,
                color: AppTheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        )),
      ];
    }

    final everyDayPhase = eqElements.length + 1;
    final weeklyPhase = eqElements.length + 2;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Equation row — each element fades in sequentially
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                for (int i = 0; i < eqElements.length; i++)
                  AnimatedOpacity(
                    duration: OnboardingTiming.totalElementStagger,
                    opacity: _phase > i ? 1.0 : 0.0,
                    child: eqElements[i].widget,
                  ),
              ],
            ),
            // "Every day."
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _phase >= everyDayPhase ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Every day.',
                  style: AppTheme.notoSerif(
                    fontSize: 20,
                    italic: true,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Weekly total — large, rust color
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _phase >= weeklyPhase ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                      text: '${d.weekly}',
                      style: AppTheme.notoSerif(
                        fontSize: 52,
                        weight: FontWeight.w300,
                        color: AppTheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' hours\nacross the week.',
                      style: AppTheme.notoSerif(
                        fontSize: 18,
                        weight: FontWeight.w300,
                        color: AppTheme.onSurface.withValues(alpha: 0.6),
                        height: 1.6,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquationElement {
  const _EquationElement(this.widget);
  final Widget widget;
}

// ── Mirror beat (phone silhouette + text drift) ───────────────────────────────

class _MirrorBeat extends StatefulWidget {
  const _MirrorBeat({super.key});

  @override
  State<_MirrorBeat> createState() => _MirrorBeatState();
}

class _MirrorBeatState extends State<_MirrorBeat>
    with TickerProviderStateMixin {
  bool _show1 = false, _show2 = false;
  late final AnimationController _phoneDrift;
  late final Animation<double> _driftProgress;

  @override
  void initState() {
    super.initState();
    _phoneDrift = AnimationController(
      vsync: this,
      duration: OnboardingTiming.mirrorPhoneDrift,
    );
    _driftProgress = CurvedAnimation(
      parent: _phoneDrift,
      curve: Curves.easeInOut,
    );

    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      if (mounted) {
        setState(() => _show1 = true);
        _phoneDrift.forward();
      }
    });
    final pauseDelay = OnboardingTiming.mirrorLine1FadeIn +
        OnboardingTiming.mirrorPause;
    Future<void>.delayed(pauseDelay).then((_) {
      if (mounted) setState(() => _show2 = true);
    });
  }

  @override
  void dispose() {
    _phoneDrift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Phone silhouette with text drifting in
            SizedBox(
              height: 180,
              child: AnimatedBuilder(
                animation: _driftProgress,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _PhoneSilhouettePainter(
                      progress: _driftProgress.value,
                      opacity: _show1 ? 1.0 : 0.0,
                    ),
                    size: const Size(100, 180),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            AnimatedOpacity(
              duration: OnboardingTiming.mirrorLine1FadeIn,
              opacity: _show1 ? 1.0 : 0.0,
              child: Text(
                'You already know where\nmost of it goes.',
                textAlign: TextAlign.center,
                style: AppTheme.notoSerif(
                  fontSize: 22,
                  weight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              duration: OnboardingTiming.mirrorLine2FadeIn,
              opacity: _show2 ? 1.0 : 0.0,
              child: Text(
                'You feel it by Thursday.',
                textAlign: TextAlign.center,
                style: AppTheme.notoSerif(
                  fontSize: 22,
                  weight: FontWeight.w300,
                  color: AppTheme.onSurface.withValues(alpha: 0.65),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Phone silhouette painter ──────────────────────────────────────────────────

class _PhoneSilhouettePainter extends CustomPainter {
  _PhoneSilhouettePainter({
    required this.progress,
    required this.opacity,
  });

  final double progress;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Phone body
    final phonePaint = Paint()
      ..color = AppTheme.onSurface.withValues(alpha: 0.08 * opacity)
      ..style = PaintingStyle.fill;

    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.7, height: h * 0.85),
      const Radius.circular(14),
    );
    canvas.drawRRect(phoneRect, phonePaint);

    // Phone border
    final borderPaint = Paint()
      ..color = AppTheme.onSurface.withValues(alpha: 0.15 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(phoneRect, borderPaint);

    // Screen area
    final screenPaint = Paint()
      ..color = AppTheme.onSurface.withValues(alpha: 0.04 * opacity)
      ..style = PaintingStyle.fill;
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: w * 0.58,
        height: h * 0.72,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(screenRect, screenPaint);

    // Animated "content lines" drifting into the phone
    final linePaint = Paint()
      ..color = AppTheme.onSurface.withValues(alpha: 0.12 * opacity * progress)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final yOffset = cy - 30 + i * 18.0;
      final lineWidth = (w * 0.4 - i * 6) * progress;
      final xStart = cx - lineWidth / 2;
      // Lines drift from outside to inside
      final drift = (1 - progress) * 40;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(xStart + drift, yOffset, lineWidth, 4),
          const Radius.circular(2),
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PhoneSilhouettePainter old) =>
      old.progress != progress || old.opacity != opacity;
}

// ── Turn beat (word-by-word + CTA) ────────────────────────────────────────────

class _TurnBeat extends StatefulWidget {
  const _TurnBeat({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<_TurnBeat> createState() => _TurnBeatState();
}

class _TurnBeatState extends State<_TurnBeat> {
  static const _line1Words = ["The", "question", "isn't", "where", "the", "time", "went."];
  static const _line2Words = ["It's", "what", "you'd", "do", "if", "you", "got", "it", "back."];

  final List<bool> _word1Visible = List.filled(7, false);
  final List<bool> _word2Visible = List.filled(9, false);
  bool _showCta = false;

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Line 1 word by word
    for (int i = 0; i < _line1Words.length; i++) {
      await Future<void>.delayed(OnboardingTiming.turnWordDelay);
      if (!mounted) return;
      setState(() => _word1Visible[i] = true);
    }

    await Future<void>.delayed(OnboardingTiming.turnLineStagger);
    if (!mounted) return;

    // Line 2 word by word
    for (int i = 0; i < _line2Words.length; i++) {
      await Future<void>.delayed(OnboardingTiming.turnWordDelay);
      if (!mounted) return;
      setState(() => _word2Visible[i] = true);
    }

    await Future<void>.delayed(OnboardingTiming.turnHoldBeforeCta);
    if (!mounted) return;
    setState(() => _showCta = true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < _line1Words.length; i++)
                  AnimatedOpacity(
                    duration: OnboardingTiming.turnLineFadeIn,
                    curve: Curves.easeIn,
                    opacity: _word1Visible[i] ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        _line1Words[i],
                        style: AppTheme.notoSerif(
                          fontSize: 22,
                          weight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < _line2Words.length; i++)
                  AnimatedOpacity(
                    duration: OnboardingTiming.turnLineFadeIn,
                    curve: Curves.easeIn,
                    opacity: _word2Visible[i] ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        _line2Words[i],
                        style: AppTheme.notoSerif(
                          fontSize: 22,
                          weight: FontWeight.w300,
                          color: AppTheme.onSurface.withValues(alpha: 0.65),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 48),
            AnimatedOpacity(
              duration: OnboardingTiming.turnCtaFadeIn,
              opacity: _showCta ? 1.0 : 0.0,
              child: AnimatedScale(
                scale: _showCta ? 1.0 : 0.9,
                duration: OnboardingTiming.turnCtaFadeIn,
                child: LiquidGlassActionButton(
                  label: "Let's find out",
                  icon: Icons.arrow_forward_rounded,
                  onTap: widget.onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skip button ───────────────────────────────────────────────────────────────

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.confirm,
    required this.onTap,
  });

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
                color: Colors.white.withValues(alpha: 0.4),
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
                      : AppTheme.onSurface.withValues(alpha: 0.48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
