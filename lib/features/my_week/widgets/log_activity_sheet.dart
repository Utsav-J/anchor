import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/activity_log.dart';
import '../../../shared/models/quick_activity_template.dart';
import '../my_week_notifier.dart';

/// Bottom sheet for logging a quick activity (filling in post-fields).
class LogActivitySheet extends ConsumerStatefulWidget {
  const LogActivitySheet({super.key, required this.template});

  final QuickActivityTemplate template;

  static Future<void> show(
    BuildContext context,
    QuickActivityTemplate template,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogActivitySheet(template: template),
    );
  }

  @override
  ConsumerState<LogActivitySheet> createState() => _LogActivitySheetState();
}

class _LogActivitySheetState extends ConsumerState<LogActivitySheet> {
  // Default post-field values (mid-range)
  final Map<String, int> _fields = {};

  @override
  void initState() {
    super.initState();
    _setDefaults();
  }

  void _setDefaults() {
    switch (widget.template.categoryName) {
      case 'Creative':
      case 'Environment-Shaping':
        _fields['before'] = 3;
        _fields['after'] = 3;
        break;
      case 'Movement':
      case 'Connection':
        _fields['value'] = 3;
        break;
      case 'Reflective':
      case 'Skill-Building':
      case 'Future-Oriented':
        _fields['value'] = 0;
        break;
    }
  }

  void _log() {
    HapticFeedback.mediumImpact();
    final score = ActivityLog.deriveControlScore(
      widget.template.categoryName,
      _fields,
    );
    final log = ActivityLog(
      id: ActivityLog.generateId(widget.template.categoryName),
      templateId: widget.template.id,
      categoryName: widget.template.categoryName,
      activityName: widget.template.activityName,
      emoji: widget.template.emoji,
      loggedAt: DateTime.now(),
      postFields: Map.from(_fields),
      controlScore: score,
    );
    ref
        .read(myWeekProvider.notifier)
        .logActivity(widget.template.categoryName, log);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
                children: [
                  // ── Template header ──────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.template.emoji,
                          style: TextStyle(fontSize: 26.sp),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.template.activityName,
                              style: AppTheme.notoSerif(
                                fontSize: 20,
                                weight: FontWeight.w500,
                              ),
                            ),
                            if (widget.template.fields.isNotEmpty)
                              Text(
                                widget.template.fields.values.join(' · '),
                                style: AppTheme.inter(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // ── Post-fields ──────────────────────────────────────
                  ..._buildPostFields(),
                  SizedBox(height: 32.h),

                  // ── Log button ───────────────────────────────────────
                  _LogButton(onTap: _log),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPostFields() {
    switch (widget.template.categoryName) {
      case 'Creative':
        return [
          _PostHeader(
            headline: 'How was your mood shift?',
            subtitle: 'Capture the emotional impact of your session.',
          ),
          SizedBox(height: 28.h),
          _MoodDualSlider(
            beforeValue: _fields['before'] ?? 3,
            afterValue: _fields['after'] ?? 3,
            onBeforeChanged: (v) =>
                setState(() => _fields['before'] = v),
            onAfterChanged: (v) => setState(() => _fields['after'] = v),
          ),
        ];

      case 'Environment-Shaping':
        return [
          _PostHeader(
            headline: 'How did the space change?',
            subtitle: 'Capture how the environment felt before and after.',
          ),
          SizedBox(height: 28.h),
          _MoodDualSlider(
            beforeValue: _fields['before'] ?? 3,
            afterValue: _fields['after'] ?? 3,
            beforeLabel: 'BEFORE',
            afterLabel: 'AFTER',
            onBeforeChanged: (v) =>
                setState(() => _fields['before'] = v),
            onAfterChanged: (v) => setState(() => _fields['after'] = v),
          ),
        ];

      case 'Movement':
        return [
          _PostHeader(
            headline: 'Energy Change',
            subtitle: 'How did your energy shift through this session?',
          ),
          SizedBox(height: 28.h),
          _SingleScaleSlider(
            value: _fields['value'] ?? 3,
            minLabel: 'Drained',
            maxLabel: 'Energized',
            onChanged: (v) => setState(() => _fields['value'] = v),
          ),
        ];

      case 'Connection':
        return [
          _PostHeader(
            headline: 'Emotional Impact',
            subtitle: 'How did this interaction leave you feeling?',
          ),
          SizedBox(height: 28.h),
          _SingleScaleSlider(
            value: _fields['value'] ?? 3,
            minLabel: 'Draining',
            maxLabel: 'Energizing',
            onChanged: (v) => setState(() => _fields['value'] = v),
          ),
        ];

      case 'Reflective':
        return [
          _PostHeader(
            headline: 'Relief / Weight Lifted',
            subtitle: 'How much lighter do you feel after reflecting?',
          ),
          SizedBox(height: 24.h),
          _ThreePillField(
            value: _fields['value'] ?? -1,
            options: const ['None', 'Partial', 'Significant'],
            onSelect: (v) => setState(() => _fields['value'] = v),
          ),
        ];

      case 'Skill-Building':
        return [
          _PostHeader(
            headline: 'Confidence Change',
            subtitle:
                'How much more confident do you feel in this skill?',
          ),
          SizedBox(height: 24.h),
          _ThreePillField(
            value: _fields['value'] ?? -1,
            options: const ['No change', 'Slight boost', 'Significant'],
            onSelect: (v) => setState(() => _fields['value'] = v),
          ),
        ];

      case 'Future-Oriented':
        return [
          _PostHeader(
            headline: 'Clarity Gained',
            subtitle: 'How clear does the path ahead feel now?',
          ),
          SizedBox(height: 24.h),
          _ThreePillField(
            value: _fields['value'] ?? -1,
            options: const ['None', 'Some', 'Crystal clear'],
            onSelect: (v) => setState(() => _fields['value'] = v),
          ),
        ];

      default:
        return [
          _PostHeader(
            headline: 'How did it go?',
            subtitle: 'Capture the impact of this activity.',
          ),
          SizedBox(height: 24.h),
          _SingleScaleSlider(
            value: _fields['value'] ?? 3,
            minLabel: 'Difficult',
            maxLabel: 'Great',
            onChanged: (v) => setState(() => _fields['value'] = v),
          ),
        ];
    }
  }
}

// ── Post-field widgets ────────────────────────────────────────────────────────

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.headline, required this.subtitle});
  final String headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: AppTheme.notoSerif(fontSize: 24, weight: FontWeight.w500, height: 1.3),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          style: AppTheme.inter(
            fontSize: 13,
            color: AppTheme.accent,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Emoji mood scale: 😔 😐 😌 😊 🤩 (values 1–5)
class _MoodEmojiRow extends StatelessWidget {
  const _MoodEmojiRow({required this.value, required this.onSelect});
  final int value;
  final ValueChanged<int> onSelect;

  static const _emojis = ['😔', '😐', '😌', '😊', '🤩'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(_emojis.length, (i) {
        final faceValue = i + 1;
        final isSelected = faceValue == value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(faceValue);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accent
                  : AppTheme.surfaceContainerHigh,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              _emojis[i],
              style: TextStyle(fontSize: isSelected ? 26.sp : 22.sp),
            ),
          ),
        );
      }),
    );
  }
}

class _MoodDualSlider extends StatelessWidget {
  const _MoodDualSlider({
    required this.beforeValue,
    required this.afterValue,
    required this.onBeforeChanged,
    required this.onAfterChanged,
    this.beforeLabel = 'BEFORE',
    this.afterLabel = 'AFTER',
  });

  final int beforeValue;
  final int afterValue;
  final ValueChanged<int> onBeforeChanged;
  final ValueChanged<int> onAfterChanged;
  final String beforeLabel;
  final String afterLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          beforeLabel,
          style: AppTheme.inter(
            fontSize: 10,
            letterSpacing: 1.2,
            weight: FontWeight.w600,
            color: AppTheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        SizedBox(height: 12.h),
        _MoodEmojiRow(value: beforeValue, onSelect: onBeforeChanged),
        SizedBox(height: 20.h),
        Center(
          child: Icon(
            Icons.arrow_downward_rounded,
            color: AppTheme.onSurface.withValues(alpha: 0.25),
            size: 20.sp,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          afterLabel,
          style: AppTheme.inter(
            fontSize: 10,
            letterSpacing: 1.2,
            weight: FontWeight.w600,
            color: AppTheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        SizedBox(height: 12.h),
        _MoodEmojiRow(value: afterValue, onSelect: onAfterChanged),
      ],
    );
  }
}

class _SingleScaleSlider extends StatelessWidget {
  const _SingleScaleSlider({
    required this.value,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
  });

  final int value;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.accent,
            inactiveTrackColor: AppTheme.surfaceContainerHigh,
            thumbColor: AppTheme.accent,
            overlayColor: AppTheme.accent.withValues(alpha: 0.1),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v.round());
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel,
                  style: AppTheme.inter(
                      fontSize: 11, color: AppTheme.textMuted)),
              Text(maxLabel,
                  style: AppTheme.inter(
                      fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreePillField extends StatelessWidget {
  const _ThreePillField({
    required this.value,
    required this.options,
    required this.onSelect,
  });

  final int value; // -1 = none selected, 0/1/2 = index
  final List<String> options;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: List.generate(options.length, (i) {
        final isSelected = i == value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.onSurface
                  : AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              options[i],
              style: AppTheme.inter(
                fontSize: 14,
                weight: FontWeight.w500,
                color: isSelected
                    ? AppTheme.surfaceContainerLowest
                    : AppTheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LogButton extends StatelessWidget {
  const _LogButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB02F00), Color(0xFFFF5924)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log Activity',
              style: AppTheme.inter(
                fontSize: 16,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10.w),
            const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
