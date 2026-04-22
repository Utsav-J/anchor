import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/me/manage_focus_screen.dart';
import '../../features/me/me_screen.dart';
import '../../features/my_week/my_week_screen.dart';
import '../../features/onboarding/focus_filter/focus_filter_screen.dart';
import '../../features/ownership_reveal/ownership_reveal_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/anchor_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Overridden in main.dart after reading SharedPreferences at startup.
/// Determines whether to land on home or show onboarding first.
final initialLocationProvider = Provider<String>((_) => '/home');

final goRouterProvider = Provider<GoRouter>((ref) {
  final initialLocation = ref.read(initialLocationProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AnchorShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-week',
                name: 'myWeek',
                builder: (context, state) => const MyWeekScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                name: 'me',
                builder: (context, state) => const MeScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ownership-reveal',
        name: 'ownershipReveal',
        builder: (context, state) => const OwnershipRevealScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/onboarding/focus-filter',
        name: 'focusFilter',
        builder: (context, state) => const FocusFilterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/me/manage-focus',
        name: 'manageFocus',
        builder: (context, state) => const ManageFocusScreen(),
      ),
    ],
  );
});
