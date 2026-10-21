import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

void main() {
  test(
    'history follows habits, entries and jokers, archived included',
    () async {
      final day = Day(2026, 10, 21);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
        ],
      );
      addTearDown(container.dispose);
      final repo = container.read(habitRepositoryProvider);
      final id = await repo.createHabit(
        Habit(
          id: 0,
          name: 'Lire',
          type: HabitType.yesNo,
          color: HabitColor.mint,
          icon: 'book',
          goal: 1,
          step: 1,
          createdOn: day,
        ),
      );
      await repo.setEntry(HabitEntry(habitId: id, day: day, value: 1));
      await repo.useJoker(day.addDays(-1));
      await repo.archiveHabit(id, day.addDays(1));

      final sub = container.listen(historyProvider, (_, _) {});
      addTearDown(sub.close);
      final history = await container.read(historyProvider.future);
      expect(history.habits.single.id, id);
      expect(history.valueOf(id, day), 1);
      expect(history.jokerDays, {day.addDays(-1)});
    },
  );
}
