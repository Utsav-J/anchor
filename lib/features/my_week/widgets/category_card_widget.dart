import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/category_draft.dart';
import '../../../shared/models/quick_activity_template.dart';
import 'create_template_sheet.dart';
import 'log_activity_sheet.dart';

/// Expanded/collapsed category card for the My Week Daily Pulse section.
class CategoryCardWidget extends StatelessWidget {
  const CategoryCardWidget({
    super.key,
    required this.meta,
    required this.draft,
    required this.isExpanded,
    required this.onToggle,
  });

  final CategoryMeta meta;
  final CategoryDraft draft;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08121C2B),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Collapsed header (always visible) ─────────────────────────
          _CardHeader(
            meta: meta,
            draft: draft,
            isExpanded: isExpanded,
            onToggle: onToggle,
          ),

          // ── Expandable body ────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _CardBody(
              meta: meta,
              draft: draft,
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.meta,
    required this.draft,
    required this.isExpanded,
    required this.onToggle,
  });

  final CategoryMeta meta;
  final CategoryDraft draft;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final logCount = draft.logs.length;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Category icon
            Icon(meta.icon, color: AppTheme.primary, size: 22.sp),
            SizedBox(width: 10.w),

            // Name + log count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.name,
                    style: AppTheme.notoSerif(
                      fontSize: 16,
                      weight: FontWeight.w500,
                    ),
                  ),
                  if (logCount > 0)
                    Text(
                      '$logCount ${logCount == 1 ? 'activity' : 'activities'} logged · score ${draft.controlScore}/10',
                      style: AppTheme.inter(
                        fontSize: 11,
                        color: AppTheme.accent,
                      ),
                    ),
                ],
              ),
            ),

            // Logged indicator dot
            if (draft.isLogged)
              Container(
                width: 8.r,
                height: 8.r,
                margin: EdgeInsets.only(right: 8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),

            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.onSurface.withValues(alpha: 0.4),
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  const _CardBody({required this.meta, required this.draft});

  final CategoryMeta meta;
  final CategoryDraft draft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(
          color: AppTheme.outlineVariant.withValues(alpha: 0.4),
          height: 1,
          indent: 16.w,
          endIndent: 16.w,
        ),
        SizedBox(height: 16.h),

        if (draft.templates.isEmpty)
          _EmptyState(meta: meta)
        else
          _TemplateGrid(meta: meta, templates: draft.templates),

        SizedBox(height: 16.h),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.meta});
  final CategoryMeta meta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              meta.icon,
              size: 28.sp,
              color: AppTheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'No quick activities yet',
            style: AppTheme.notoSerif(
              fontSize: 16,
              weight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Create small, manageable ways to engage with ${meta.name.toLowerCase()} throughout the week.',
            style: AppTheme.inter(
              fontSize: 12,
              color: AppTheme.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => CreateTemplateSheet.show(context, meta.name),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB02F00), Color(0xFFFF5924)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Define your first ${meta.name} Quickie',
                style: AppTheme.inter(
                  fontSize: 13,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template grid ─────────────────────────────────────────────────────────────

class _TemplateGrid extends StatelessWidget {
  const _TemplateGrid({required this.meta, required this.templates});

  final CategoryMeta meta;
  final List<QuickActivityTemplate> templates;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (final t in templates) _TemplateCard(template: t),
      _AddNewCard(categoryName: meta.name),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: items,
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});
  final QuickActivityTemplate template;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => LogActivitySheet.show(context, template),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                template.emoji,
                style: TextStyle(fontSize: 26.sp),
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            template.activityName,
            style: AppTheme.inter(
              fontSize: 10,
              color: AppTheme.onSurface.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AddNewCard extends StatelessWidget {
  const _AddNewCard({required this.categoryName});
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CreateTemplateSheet.show(context, categoryName),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                color: AppTheme.onSurface.withValues(alpha: 0.4),
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Add New',
            style: AppTheme.inter(
              fontSize: 10,
              color: AppTheme.onSurface.withValues(alpha: 0.45),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
