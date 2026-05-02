import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_schedule.dart';
import '../../../shared/widgets/liquid_glass_action_button.dart';

// ── Beat types ────────────────────────────────────────────────────────────────

enum _BeatType {
  intro,
  morningContext,
  morningWindow,
  morningFlip,
  eveningContext,
  eveningWindow,
  eveningWork,
  eveningRoutine,
  total,
  accusation,
  question,
  reveal,
  anchor,
}

class _Beat {
  const _Beat(this.type, this.durationMs);
  final _BeatType type;
  final int durationMs;
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
  int _currentNumber = 0; // the large flipping number
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
        const _Beat(_BeatType.intro, 2200),
        if (_data.hasMorning) ...[
          const _Beat(_BeatType.morningContext, 1900),
          const _Beat(_BeatType.morningWindow, 1900),
          const _Beat(_BeatType.morningFlip, 1900),
        ],
        const _Beat(_BeatType.eveningContext, 1900),
        const _Beat(_BeatType.eveningWindow, 1900),
        const _Beat(_BeatType.eveningWork, 1600),
        const _Beat(_BeatType.eveningRoutine, 1900),
        const _Beat(_BeatType.total, 3800),
        const _Beat(_BeatType.accusation, 2600),
        const _Beat(_BeatType.question, 2000),
        const _Beat(_BeatType.reveal, 2800),
        const _Beat(_BeatType.anchor, 99999),
      ];

  void _scheduleNext() {
    if (_beatIndex >= _beats.length - 1) return;
    _beatTimer =
        Timer(Duration(milliseconds: _beats[_beatIndex].durationMs), () {
      if (!mounted) return;
      final next = _beatIndex + 1;
      final nextType = _beats[next].type;

      // Update the large number as we transition into a new beat
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

  void _startTracking() {
    _beatTimer?.cancel();
    context.go('/onboarding/focus-filter');
  }

  @override
  void dispose() {
    _beatTimer?.cancel();
    super.dispose();
  }

  // ── Derived state ──────────────────────────────────────────────────────────

  _BeatType get _currentType => _beats[_beatIndex].type;
  bool get _isAccusation => _currentType == _BeatType.accusation;
  bool get _isAnchor => _currentType == _BeatType.anchor;
  bool get _showSkip => !_isAnchor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF8F3), Color(0xFFFFF0E6)],
              ),
            ),
          ),
          // ── Accusation dimming overlay ─────────────────────────────────
          AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            opacity: _isAccusation ? 1.0 : 0.0,
            child: Container(
              color: const Color(0xFF1A0806).withValues(alpha: 0.62),
            ),
          ),
          // ── Beat content ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Skip button row
                if (_showSkip)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 20, 0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: _SkipButton(
                        confirm: _skipConfirm,
                        onTap: _handleSkip,
                        brightText: _isAccusation,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 14),
                // Animated beat content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
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
                    child: _buildBeatContent(
                      key: ValueKey(_beatIndex),
                    ),
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
    final textColor =
        _isAccusation ? Colors.white.withValues(alpha: 0.92) : AppTheme.onSurface;

    return switch (_currentType) {
      _BeatType.intro => _TextBeat(
          key: key,
          lines: const ['How much of last week', 'was truly yours?'],
          textColor: textColor,
          italicFirst: false,
          fontSize: 26,
        ),
      _BeatType.morningContext => _TextBeat(
          key: key,
          lines: ['You woke up at ${_data.wakeLabel}.', 'Left for work at ${_data.leaveLabel}.'],
          textColor: textColor,
        ),
      _BeatType.morningWindow => _NumberBeat(
          key: key,
          number: _currentNumber,
          supporting: 'hours in the morning.',
          textColor: textColor,
        ),
      _BeatType.morningFlip => _NumberBeat(
          key: key,
          number: _currentNumber,
          supporting: 'Getting ready. Commuting.',
          extraLine: '${_data.morningOwned} ${_data.morningOwned == 1 ? 'hour' : 'hours'}. Maybe yours.',
          textColor: textColor,
        ),
      _BeatType.eveningContext => _TextBeat(
          key: key,
          lines: ['You got home at ${_data.returnLabel}.', 'You sleep at ${_data.sleepLabel}.'],
          textColor: textColor,
        ),
      _BeatType.eveningWindow => _NumberBeat(
          key: key,
          number: _currentNumber,
          supporting: 'hours in the evening.',
          textColor: textColor,
        ),
      _BeatType.eveningWork => _NumberBeat(
          key: key,
          number: _currentNumber,
          supporting: 'Finishing up work.',
          textColor: textColor,
        ),
      _BeatType.eveningRoutine => _NumberBeat(
          key: key,
          number: _currentNumber,
          supporting: 'Getting fresh. Making food.',
          textColor: textColor,
        ),
      _BeatType.total => _TotalBeat(
          key: key,
          data: _data,
          textColor: textColor,
        ),
      _BeatType.accusation => _TextBeat(
          key: key,
          lines: const [
            'Most of it goes to doomscrolling.',
            'Chasing instant gratification\nafter a tiring day.',
          ],
          textColor: textColor,
          fontSize: 20,
        ),
      _BeatType.question => _TextBeat(
          key: key,
          lines: const ['What if it didn\'t?'],
          textColor: textColor,
          fontSize: 28,
          italicFirst: true,
        ),
      _BeatType.reveal => _RevealBeat(
          key: key,
          textColor: textColor,
        ),
      _BeatType.anchor => _AnchorBeat(
          key: key,
          onStart: _startTracking,
        ),
    };
  }
}

// ── Beat content widgets ──────────────────────────────────────────────────────

class _TextBeat extends StatelessWidget {
  const _TextBeat({
    super.key,
    required this.lines,
    required this.textColor,
    this.fontSize = 22,
    this.italicFirst = false,
  });

  final List<String> lines;
  final Color textColor;
  final double fontSize;
  final bool italicFirst;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < lines.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Text(
                lines[i],
                textAlign: TextAlign.center,
                style: AppTheme.notoSerif(
                  fontSize: fontSize,
                  weight: i == 0 ? FontWeight.w400 : FontWeight.w300,
                  italic: italicFirst && i == 0,
                  color: i == 0
                      ? textColor
                      : textColor.withValues(alpha: 0.65),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberBeat extends StatelessWidget {
  const _NumberBeat({
    super.key,
    required this.number,
    required this.supporting,
    this.extraLine,
    required this.textColor,
  });

  final int number;
  final String supporting;
  final String? extraLine;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
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
                '$number',
                key: ValueKey(number),
                style: AppTheme.notoSerif(
                  fontSize: 96,
                  weight: FontWeight.w300,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              supporting,
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                fontSize: 16,
                color: textColor.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
            if (extraLine != null) ...[
              const SizedBox(height: 6),
              Text(
                extraLine!,
                textAlign: TextAlign.center,
                style: AppTheme.notoSerif(
                  fontSize: 16,
                  italic: true,
                  color: textColor.withValues(alpha: 0.45),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TotalBeat extends StatefulWidget {
  const _TotalBeat({
    super.key,
    required this.data,
    required this.textColor,
  });

  final _NarrativeData data;
  final Color textColor;

  @override
  State<_TotalBeat> createState() => _TotalBeatState();
}

class _TotalBeatState extends State<_TotalBeat> {
  int _phase = 0; // 0 → equation, 1 → daily, 2 → weekly

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900)).then((_) {
      if (mounted) setState(() => _phase = 1);
    });
    Future<void>.delayed(const Duration(milliseconds: 1900)).then((_) {
      if (mounted) setState(() => _phase = 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final c = widget.textColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Equation
            _EquationRow(data: d, textColor: c),
            // "Yours. Every day."
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _phase >= 1 ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Yours. Every day.',
                  style: AppTheme.notoSerif(
                    fontSize: 20,
                    italic: true,
                    weight: FontWeight.w500,
                    color: c,
                  ),
                ),
              ),
            ),
            // Weekly total
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _phase >= 2 ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${d.weekly}',
                        style: AppTheme.notoSerif(
                          fontSize: 52,
                          weight: FontWeight.w300,
                          color: c,
                        ),
                      ),
                      TextSpan(
                        text: ' hours\nacross the week.',
                        style: AppTheme.notoSerif(
                          fontSize: 18,
                          weight: FontWeight.w300,
                          color: c.withValues(alpha: 0.6),
                          height: 1.6,
                        ),
                      ),
                    ],
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

class _EquationRow extends StatelessWidget {
  const _EquationRow({required this.data, required this.textColor});
  final _NarrativeData data;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.notoSerif(
      fontSize: 48,
      weight: FontWeight.w300,
      color: textColor,
    );
    final opStyle = AppTheme.inter(
      fontSize: 28,
      weight: FontWeight.w300,
      color: textColor.withValues(alpha: 0.4),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (data.hasMorning) ...[
          Text('${data.morningOwned}', style: style),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('+', style: opStyle),
          ),
        ],
        Text('${data.eveningOwned}', style: style),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('=', style: opStyle),
        ),
        Text(
          '${data.daily}',
          style: AppTheme.notoSerif(
            fontSize: 48,
            weight: FontWeight.w400,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'hrs',
          style: AppTheme.inter(
            fontSize: 16,
            color: textColor.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _RevealBeat extends StatefulWidget {
  const _RevealBeat({super.key, required this.textColor});
  final Color textColor;

  @override
  State<_RevealBeat> createState() => _RevealBeatState();
}

class _RevealBeatState extends State<_RevealBeat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fill;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fill = Tween<double>(begin: 0, end: 0.68).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _fill,
              builder: (context, _) => CircularPercentIndicator(
                radius: 90,
                lineWidth: 10,
                percent: _fill.value,
                backgroundColor: AppTheme.surfaceContainerHigh,
                linearGradient: const LinearGradient(
                  colors: [Color(0xFFB02F00), Color(0xFFFF5924)],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '${(_fill.value * 100).toStringAsFixed(0)}%',
                  style: AppTheme.notoSerif(
                    fontSize: 36,
                    weight: FontWeight.w300,
                    color: widget.textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'This is what ownership looks like.',
              textAlign: TextAlign.center,
              style: AppTheme.notoSerif(
                fontSize: 20,
                weight: FontWeight.w400,
                color: widget.textColor.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnchorBeat extends StatelessWidget {
  const _AnchorBeat({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Anchor.',
              style: AppTheme.notoSerif(
                fontSize: 52,
                weight: FontWeight.w300,
                italic: true,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            LiquidGlassActionButton(
              label: 'Start tracking',
              icon: Icons.arrow_forward_rounded,
              onTap: onStart,
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
    required this.brightText,
  });

  final bool confirm;
  final VoidCallback onTap;
  final bool brightText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: brightText
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: confirm ? 0.4 : 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
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
                  color: brightText
                      ? Colors.white.withValues(alpha: 0.8)
                      : confirm
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
