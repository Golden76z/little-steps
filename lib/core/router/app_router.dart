import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/create_habit/choose_type_screen.dart';
import '../../features/create_habit/habit_draft.dart';
import '../../features/create_habit/habit_settings_screen.dart';
import '../../features/create_habit/premium_screen.dart';
import '../../features/create_habit/schedule_screen.dart';
import '../../features/habit_detail/habit_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/trophies/trophies_screen.dart';
import '../database/providers.dart';
import 'app_shell.dart';

abstract final class Routes {
  static const today = '/today';
  static const progress = '/progress';
  static const trophies = '/trophies';
  static const profile = '/profile';
  static const create = '/create';
  static const createSettings = '/create/settings';
  static const createSchedule = '/create/schedule';
  static const premium = '/premium';

  static String habit(int id, {bool startTimer = false}) =>
      '/habit/$id${startTimer ? '?timer=1' : ''}';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
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
        builder: (_, _) => const ChooseTypeScreen(),
      ),
      // Not nested under /create: editing reuses them without the limit redirect.
      GoRoute(
        path: Routes.createSettings,
        builder: (_, _) => const HabitSettingsScreen(),
      ),
      GoRoute(
        path: Routes.createSchedule,
        builder: (_, _) => const ScheduleScreen(),
      ),
      GoRoute(path: Routes.premium, builder: (_, _) => const PremiumScreen()),
      GoRoute(
        path: '/habit/:id',
        builder: (_, state) => HabitDetailScreen(
          habitId: int.parse(state.pathParameters['id']!),
          startTimer: state.uri.queryParameters['timer'] == '1',
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
