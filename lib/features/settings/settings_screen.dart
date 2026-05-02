import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: AppTheme.notoSerif(fontSize: 20)),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsTile(
              icon: Icons.schedule_rounded,
              title: 'My Schedule',
              subtitle: 'Wake, work, and sleep times',
              onTap: () => context.push('/settings/schedule'),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: AppTheme.cardDecoration(
                color: AppTheme.surfaceContainerLow,
              ),
              child: Text(
                'Export / import data coming in the next update.',
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  fontSize: 13,
                  color: AppTheme.onSurface.withValues(alpha: 0.45),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: AppTheme.cardDecoration(
          color: AppTheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.inter(
                      fontSize: 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTheme.inter(
                      fontSize: 12,
                      color: AppTheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.onSurface.withValues(alpha: 0.35),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
