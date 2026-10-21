import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/create_habit/create_habit_screen.dart';
import '../../features/habit_detail/habit_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/trophies/trophies_screen.dart';
import 'app_shell.dart';

abstract final class Routes {
  static const today = '/today';
  static const progress = '/progress';
  static const trophies = '/trophies';
  static const profile = '/profile';
  static const create = '/create';

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
        builder: (_, _) => const CreateHabitScreen(),
      ),
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
