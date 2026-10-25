import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/create_habit/choose_type_screen.dart';
import '../../features/create_habit/habit_draft.dart';
import '../../features/create_habit/habit_settings_screen.dart';
import '../../features/create_habit/premium_screen.dart';
import '../../features/create_habit/schedule_screen.dart';
import '../../features/habit_detail/habit_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/reminders_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/trophies/trophies_screen.dart';
import '../database/providers.dart';
import 'app_shell.dart';
import 'fading_branches.dart';

abstract final class Routes {
  static const today = '/today';
  static const progress = '/progress';
  static const trophies = '/trophies';
  static const profile = '/profile';
  static const create = '/create';
  static const createSettings = '/create/settings';
  static const createSchedule = '/create/schedule';
  static const premium = '/premium';
  static const reminders = '/reminders';

  static String habit(int id, {bool startTimer = false}) =>
      '/habit/$id${startTimer ? '?timer=1' : ''}';
}

/// An opened screen: every top-level route uses `pageBuilder: _page`.
/// go_router does not see our MaterialApp and would fall back to pages
/// without any transition.
Page<void> _page(GoRouterState state, Widget child) =>
    MaterialPage(key: state.pageKey, child: child);

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.today,
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) => AppShell(shell: shell),
        navigatorContainerBuilder: (context, shell, children) =>
            FadingBranches(index: shell.currentIndex, children: children),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (_, _) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.progress,
                builder: (_, _) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.trophies,
                builder: (_, _) => const TrophiesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.create,
        // Free plan: past the limit, the "+" leads to Premium.
        redirect: (_, _) =>
            canCreateHabit(ref.read(habitsProvider).value?.length ?? 0)
            ? null
            : Routes.premium,
        pageBuilder: (_, state) => _page(state, const ChooseTypeScreen()),
      ),
      // Not nested under /create: editing reuses them without the limit redirect.
      GoRoute(
        path: Routes.createSettings,
        pageBuilder: (_, state) => _page(state, const HabitSettingsScreen()),
      ),
      GoRoute(
        path: Routes.createSchedule,
        pageBuilder: (_, state) => _page(state, const ScheduleScreen()),
      ),
      GoRoute(
        path: Routes.premium,
        pageBuilder: (_, state) => _page(state, const PremiumScreen()),
      ),
      GoRoute(
        path: Routes.reminders,
        pageBuilder: (_, state) => _page(state, const RemindersScreen()),
      ),
      GoRoute(
        path: '/habit/:id',
        pageBuilder: (_, state) => _page(
          state,
          HabitDetailScreen(
            habitId: int.parse(state.pathParameters['id']!),
            startTimer: state.uri.queryParameters['timer'] == '1',
          ),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
