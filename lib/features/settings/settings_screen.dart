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
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: AppTheme.cardDecoration(
                  color: AppTheme.surfaceContainerLow),
              child: Text(
                'SETTINGS PLACEHOLDER\nExport/import (share_plus, file_picker) in Sprint 2.',
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  fontSize: 14,
                  color: AppTheme.onSurface.withValues(alpha: 0.55),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
