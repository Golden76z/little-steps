import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';
import '../domain/habit.dart';
import '../domain/rules.dart';
import 'app_database.dart';
import 'habit_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final habitRepositoryProvider = Provider(
  (ref) => HabitRepository(ref.watch(databaseProvider)),
);

/// Active habits, for the Today list.
final habitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(habitRepositoryProvider).watchHabits(),
);

final _allHabitsProvider = StreamProvider<List<Habit>>(
  (ref) =>
      ref.watch(habitRepositoryProvider).watchHabits(includeArchived: true),
);
final _entriesProvider = StreamProvider<List<HabitEntry>>(
  (ref) => ref.watch(habitRepositoryProvider).watchEntries(),
);
final _jokerDaysProvider = StreamProvider<Set<Day>>(
  (ref) => ref.watch(habitRepositoryProvider).watchJokerDays(),
);

/// Everything the streak, XP and joker rules need.
final historyProvider = FutureProvider<History>(
  (ref) async => History(
    habits: await ref.watch(_allHabitsProvider.future),
    entries: await ref.watch(_entriesProvider.future),
    jokerDays: await ref.watch(_jokerDaysProvider.future),
  ),
);

/// One stored preference, null until set.
final settingProvider = StreamProvider.family<String?, String>(
  (ref, key) => ref.watch(habitRepositoryProvider).watchSetting(key),
);
