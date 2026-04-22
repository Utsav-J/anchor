import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),
              Text('Me', style: AppTheme.notoSerif(fontSize: 28, italic: true)),
              SizedBox(height: 24.h),
              _linkTile(
                context,
                title: 'My Focus',
                subtitle: 'Reorder or update your active categories',
                icon: Icons.tune_rounded,
                location: '/me/manage-focus',
              ),
              _linkTile(
                context,
                title: 'History',
                subtitle: 'All past weeks',
                icon: Icons.history,
                location: '/history',
              ),
              _linkTile(
                context,
                title: 'Settings',
                subtitle: 'App preferences & export',
                icon: Icons.settings_outlined,
                location: '/settings',
              ),
              _linkTile(
                context,
                title: 'Ownership Reveal',
                subtitle: 'This week\'s full insight',
                icon: Icons.donut_large_outlined,
                location: '/ownership-reveal',
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linkTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String location,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        onTap: () => context.push(location),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: AppTheme.cardDecoration(),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.accent, size: 24.sp),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTheme.inter(
                            fontSize: 15, weight: FontWeight.w600)),
                    SizedBox(height: 2.h),
                    Text(subtitle,
                        style: AppTheme.inter(
                            fontSize: 12,
                            color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppTheme.onSurface.withValues(alpha: 0.3),
                  size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
