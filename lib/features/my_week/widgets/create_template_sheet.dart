import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/quick_activity_template.dart';
import '../my_week_notifier.dart';

/// Bottom sheet for creating a reusable Quick Activity Template.
class CreateTemplateSheet extends ConsumerStatefulWidget {
  const CreateTemplateSheet({super.key, required this.categoryName});

  final String categoryName;

  static Future<void> show(BuildContext context, String categoryName) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateTemplateSheet(categoryName: categoryName),
    );
  }

  @override
  ConsumerState<CreateTemplateSheet> createState() =>
      _CreateTemplateSheetState();
}

class _CreateTemplateSheetState extends ConsumerState<CreateTemplateSheet> {
  final _nameCtrl = TextEditingController();
  String _selectedEmoji = '';
  final Map<String, String> _fields = {};

  bool get _canCreate =>
      _nameCtrl.text.trim().isNotEmpty && _selectedEmoji.isNotEmpty;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _openEmojiPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.58,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
              child: Text(
                'Choose an emoji',
                style: AppTheme.notoSerif(fontSize: 18),
              ),
            ),
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (_, emoji) {
                  setState(() => _selectedEmoji = emoji.emoji);
                  Navigator.of(ctx).pop();
                },
                config: Config(
                  height: double.infinity,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28.sp,
                    columns: 8,
                    backgroundColor: AppTheme.surfaceContainerLowest,
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: AppTheme.surfaceContainerLowest,
                    buttonIconColor: AppTheme.accent,
                  ),
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: AppTheme.surfaceContainerLowest,
                    indicatorColor: AppTheme.accent,
                    iconColorSelected: AppTheme.accent,
                    iconColor: AppTheme.onSurface.withValues(alpha: 0.4),
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(
                    enabled: false,
                  ),
                  viewOrderConfig: const ViewOrderConfig(
                    top: EmojiPickerItem.categoryBar,
                    middle: EmojiPickerItem.emojiView,
                    bottom: EmojiPickerItem.searchBar,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _create() {
    if (!_canCreate) return;
    HapticFeedback.mediumImpact();
    final template = QuickActivityTemplate(
      id: QuickActivityTemplate.generateId(widget.categoryName),
      categoryName: widget.categoryName,
      activityName: _nameCtrl.text.trim(),
      emoji: _selectedEmoji,
      fields: Map.from(_fields),
    );
    ref.read(myWeekProvider.notifier).addTemplate(widget.categoryName, template);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
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
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
                children: [
                  // ── Title ──────────────────────────────────────────────
                  RichText(
                    text: TextSpan(
                      style: AppTheme.notoSerif(fontSize: 28, height: 1.3),
                      children: [
                        const TextSpan(text: 'Define '),
                        TextSpan(
                          text: widget.categoryName,
                          style: AppTheme.notoSerif(
                            fontSize: 28,
                            italic: true,
                            height: 1.3,
                          ),
                        ),
                        const TextSpan(text: ' Quickie'),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Craft the parameters for your new ${widget.categoryName.toLowerCase()} habit.',
                    style: AppTheme.inter(
                      fontSize: 13,
                      color: AppTheme.accent,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // ── Activity Name ──────────────────────────────────────
                  _FieldLabel('Activity Name'),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _nameCtrl,
                    onChanged: (_) => setState(() {}),
                    style: AppTheme.inter(fontSize: 14),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText:
                          'e.g., ${_placeholder(widget.categoryName)}',
                      hintStyle: AppTheme.inter(
                        fontSize: 14,
                        color: AppTheme.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ── Emoji / Iconography ───────────────────────────────
                  _FieldLabel('Iconography'),
                  SizedBox(height: 10.h),
                  _EmojiButton(
                    selected: _selectedEmoji,
                    onTap: _openEmojiPicker,
                  ),
                  SizedBox(height: 24.h),

                  // ── Category-specific fields ──────────────────────────
                  ..._buildCategoryFields(),
                  SizedBox(height: 32.h),

                  // ── Create button ─────────────────────────────────────
                  _PrimaryButton(
                    label: 'Create Template',
                    enabled: _canCreate,
                    onTap: _create,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryFields() {
    switch (widget.categoryName) {
      case 'Creative':
        return [
          _PillField(
            label: 'Depth Level',
            options: const ['Light', 'Focused', 'Deep Flow'],
            selected: _fields['depthLevel'],
            onSelect: (v) => setState(() => _fields['depthLevel'] = v),
          ),
        ];

      case 'Movement':
        return [
          _FieldLabel('Default Duration (minutes)'),
          SizedBox(height: 8.h),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => setState(() => _fields['duration'] = v),
            style: AppTheme.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g., 30',
              hintStyle: AppTheme.inter(
                fontSize: 14,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _PillField(
            label: 'Intensity',
            options: const ['Low', 'Medium', 'High'],
            selected: _fields['intensity'],
            onSelect: (v) => setState(() => _fields['intensity'] = v),
          ),
        ];

      case 'Reflective':
        return [
          _PillField(
            label: 'Focus Area',
            options: const ['Self', 'Work', 'Relationships', 'General'],
            selected: _fields['focusArea'],
            onSelect: (v) => setState(() => _fields['focusArea'] = v),
          ),
        ];

      case 'Skill-Building':
        return [
          _PillField(
            label: 'Focus',
            options: const [
              'Learn New',
              'Practice',
              'Revise',
              'Experiment',
            ],
            selected: _fields['focus'],
            onSelect: (v) => setState(() => _fields['focus'] = v),
          ),
          SizedBox(height: 20.h),
          _PillField(
            label: 'Difficulty',
            options: const ['Easy', 'Moderate', 'Hard'],
            selected: _fields['difficulty'],
            onSelect: (v) => setState(() => _fields['difficulty'] = v),
          ),
        ];

      case 'Environment-Shaping':
        return [
          _PillField(
            label: 'Type',
            options: const [
              'Cleaning',
              'Organizing',
              'Setup',
              'Digital Cleanup',
            ],
            selected: _fields['type'],
            onSelect: (v) => setState(() => _fields['type'] = v),
          ),
          SizedBox(height: 20.h),
          _PillField(
            label: 'Impact',
            options: const ['Low', 'Medium', 'High'],
            selected: _fields['impact'],
            onSelect: (v) => setState(() => _fields['impact'] = v),
          ),
        ];

      case 'Future-Oriented':
        return [
          _PillField(
            label: 'Type',
            options: const [
              'Planning',
              'Goal-setting',
              'Reviewing',
              'Strategizing',
            ],
            selected: _fields['type'],
            onSelect: (v) => setState(() => _fields['type'] = v),
          ),
          SizedBox(height: 20.h),
          _PillField(
            label: 'Time Horizon',
            options: const ['Short', 'Medium', 'Long'],
            selected: _fields['timeHorizon'],
            onSelect: (v) => setState(() => _fields['timeHorizon'] = v),
          ),
        ];

      case 'Connection':
        return [
          _PillField(
            label: 'Mode',
            options: const ['In-person', 'Call', 'Text'],
            selected: _fields['mode'],
            onSelect: (v) => setState(() => _fields['mode'] = v),
          ),
          SizedBox(height: 20.h),
          _PillField(
            label: 'Depth',
            options: const ['Casual', 'Meaningful', 'Deep'],
            selected: _fields['depth'],
            onSelect: (v) => setState(() => _fields['depth'] = v),
          ),
        ];

      default:
        return [];
    }
  }

  String _placeholder(String category) {
    switch (category) {
      case 'Creative':
        return 'Morning Sketch';
      case 'Movement':
        return 'Morning Run';
      case 'Reflective':
        return 'Evening Journal';
      case 'Skill-Building':
        return 'Flutter Practice';
      case 'Environment-Shaping':
        return 'Desk Reset';
      case 'Future-Oriented':
        return 'Weekly Review';
      case 'Connection':
        return 'Coffee with a Friend';
      default:
        return 'Activity Name';
    }
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTheme.inter(
          fontSize: 11,
          weight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppTheme.onSurface.withValues(alpha: 0.55),
        ),
      );
}

class _EmojiButton extends StatelessWidget {
  const _EmojiButton({required this.selected, required this.onTap});

  final String selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Row(
        children: [
          // Preview circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: selected.isNotEmpty
                  ? AppTheme.accent.withValues(alpha: 0.12)
                  : AppTheme.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected.isNotEmpty
                    ? AppTheme.accent.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: selected.isNotEmpty
                ? Text(selected, style: TextStyle(fontSize: 30.sp))
                : Icon(
                    Icons.add_reaction_outlined,
                    color: AppTheme.onSurface.withValues(alpha: 0.3),
                    size: 26.sp,
                  ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selected.isEmpty ? 'Choose an emoji' : 'Change emoji',
                style: AppTheme.inter(fontSize: 14, color: AppTheme.onSurface),
              ),
              SizedBox(height: 2.h),
              Text(
                'Browse all emoji or search by name',
                style: AppTheme.inter(
                    fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            color: AppTheme.onSurface.withValues(alpha: 0.3),
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}

class _PillField extends StatelessWidget {
  const _PillField({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(opt);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.onSurface
                      : AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  opt,
                  style: AppTheme.inter(
                    fontSize: 13,
                    weight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.surfaceContainerLowest
                        : AppTheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFB02F00), Color(0xFFFF5924)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: enabled ? null : AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(40),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.inter(
            fontSize: 15,
            weight: FontWeight.w600,
            color:
                enabled ? Colors.white : AppTheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
