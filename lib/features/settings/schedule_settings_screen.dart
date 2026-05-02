import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/models/user_schedule.dart';
import '../../shared/widgets/liquid_glass_action_button.dart';

// ── Helpers (mirrors intro_screen.dart helpers) ───────────────────────────────

String _hourDisplay(int hour) {
  if (hour == 0 || hour == 24) return '12';
  if (hour == 12) return '12';
  if (hour > 12) return (hour - 12).toString().padLeft(2, '0');
  return hour.toString().padLeft(2, '0');
}

String _minDisplay(int m) => m.toString().padLeft(2, '0');

String _amPmLabel(int hour) {
  if (hour == 0 || (hour > 0 && hour < 12)) return 'AM';
  return 'PM';
}

int _nextMin(int m) => (m + 15) % 60;
int _prevMin(int m) => (m - 15 + 60) % 60;

// ── Screen ────────────────────────────────────────────────────────────────────

class ScheduleSettingsScreen extends ConsumerStatefulWidget {
  const ScheduleSettingsScreen({super.key});

  @override
  ConsumerState<ScheduleSettingsScreen> createState() =>
      _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState
    extends ConsumerState<ScheduleSettingsScreen> {
  late int _wakeH, _wakeM;
  late int _leaveH, _leaveM;
  late int _returnH, _returnM;
  late int _sleepH, _sleepM;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(userScheduleProvider) ?? UserSchedule.defaults;
    _wakeH = s.wakeTime.hour;
    _wakeM = s.wakeTime.minute;
    _leaveH = s.leaveTime.hour;
    _leaveM = s.leaveTime.minute;
    _returnH = s.returnTime.hour;
    _returnM = s.returnTime.minute;
    _sleepH = s.sleepTime.hour;
    _sleepM = s.sleepTime.minute;
  }

  void _incSleepH() => setState(() {
        if (_sleepH == 2) return;
        _sleepH = _sleepH == 23 ? 0 : _sleepH + 1;
      });

  void _decSleepH() => setState(() {
        if (_sleepH == 20) return;
        _sleepH = _sleepH == 0 ? 23 : _sleepH - 1;
      });

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final schedule = UserSchedule(
      wakeTime: TimeOfDay(hour: _wakeH, minute: _wakeM),
      leaveTime: TimeOfDay(hour: _leaveH, minute: _leaveM),
      returnTime: TimeOfDay(hour: _returnH, minute: _returnM),
      sleepTime: TimeOfDay(hour: _sleepH, minute: _sleepM),
    );
    await schedule.save();
    ref.read(userScheduleProvider.notifier).state = schedule;
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Subtle gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF8F3),
                  Color(0xFFFFEEE0),
                  Color(0xFFFFE0C8),
                ],
              ),
            ),
          ),
          // Decorative blobs
          Positioned(
            top: -80,
            right: -80,
            child: _Blob(size: 240, alpha: 0.14),
          ),
          Positioned(
            bottom: -50,
            left: -60,
            child: _Blob(size: 200, alpha: 0.1, color: AppTheme.primary),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                        color: AppTheme.onSurface,
                      ),
                      Expanded(
                        child: Text(
                          'My Schedule',
                          style: AppTheme.notoSerif(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: 'MORNING'),
                        const SizedBox(height: 10),
                        _buildTimeCard(
                          label: 'Wake up',
                          hour: _wakeH,
                          minute: _wakeM,
                          onHourInc: () => setState(() =>
                              _wakeH = (_wakeH < 11) ? _wakeH + 1 : _wakeH),
                          onHourDec: () => setState(() =>
                              _wakeH = (_wakeH > 4) ? _wakeH - 1 : _wakeH),
                          onMinInc: () =>
                              setState(() => _wakeM = _nextMin(_wakeM)),
                          onMinDec: () =>
                              setState(() => _wakeM = _prevMin(_wakeM)),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeCard(
                          label: 'Leave for work',
                          hour: _leaveH,
                          minute: _leaveM,
                          onHourInc: () => setState(() =>
                              _leaveH =
                                  (_leaveH < 12) ? _leaveH + 1 : _leaveH),
                          onHourDec: () => setState(() =>
                              _leaveH =
                                  (_leaveH > 5) ? _leaveH - 1 : _leaveH),
                          onMinInc: () =>
                              setState(() => _leaveM = _nextMin(_leaveM)),
                          onMinDec: () =>
                              setState(() => _leaveM = _prevMin(_leaveM)),
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(label: 'EVENING'),
                        const SizedBox(height: 10),
                        _buildTimeCard(
                          label: 'Get home from work',
                          hour: _returnH,
                          minute: _returnM,
                          onHourInc: () => setState(() =>
                              _returnH =
                                  (_returnH < 22) ? _returnH + 1 : _returnH),
                          onHourDec: () => setState(() =>
                              _returnH =
                                  (_returnH > 12) ? _returnH - 1 : _returnH),
                          onMinInc: () =>
                              setState(() => _returnM = _nextMin(_returnM)),
                          onMinDec: () =>
                              setState(() => _returnM = _prevMin(_returnM)),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeCard(
                          label: 'Go to sleep',
                          hour: _sleepH,
                          minute: _sleepM,
                          onHourInc: _incSleepH,
                          onHourDec: _decSleepH,
                          onMinInc: () =>
                              setState(() => _sleepM = _nextMin(_sleepM)),
                          onMinDec: () =>
                              setState(() => _sleepM = _prevMin(_sleepM)),
                        ),
                        const SizedBox(height: 36),
                        LiquidGlassActionButton(
                          label: _saving ? 'Saving…' : 'Save changes',
                          icon: _saving ? null : Icons.check_rounded,
                          enabled: !_saving,
                          onTap: _save,
                        ),
                      ],
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

  Widget _buildTimeCard({
    required String label,
    required int hour,
    required int minute,
    required VoidCallback onHourInc,
    required VoidCallback onHourDec,
    required VoidCallback onMinInc,
    required VoidCallback onMinDec,
  }) {
    final amPm = _amPmLabel(hour);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTheme.inter(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  weight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimeBox(
                    value: _hourDisplay(hour),
                    onInc: onHourInc,
                    onDec: onHourDec,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: AppTheme.notoSerif(
                        fontSize: 38,
                        weight: FontWeight.w300,
                        color: AppTheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  _TimeBox(
                    value: _minDisplay(minute),
                    onInc: onMinInc,
                    onDec: onMinDec,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    amPm,
                    style: AppTheme.inter(
                      fontSize: 15,
                      weight: FontWeight.w600,
                      color: AppTheme.primary.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.value,
    required this.onInc,
    required this.onDec,
  });

  final String value;
  final VoidCallback onInc;
  final VoidCallback onDec;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Arrow(icon: Icons.keyboard_arrow_up_rounded, onTap: onInc),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
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
            value,
            key: ValueKey(value),
            style: AppTheme.notoSerif(
              fontSize: 40,
              weight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(height: 2),
        _Arrow(icon: Icons.keyboard_arrow_down_rounded, onTap: onDec),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 28,
        child: Icon(
          icon,
          size: 22,
          color: AppTheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTheme.inter(
        fontSize: 11,
        letterSpacing: 1.6,
        weight: FontWeight.w700,
        color: AppTheme.primary.withValues(alpha: 0.65),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.size,
    required this.alpha,
    this.color = Colors.white,
  });

  final double size;
  final double alpha;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha),
        ),
      );
}
