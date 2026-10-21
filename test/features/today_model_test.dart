import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rules.dart';
import 'package:little_steps/features/today/today_model.dart';

import '../domain/fixtures.dart';

void main() {
  final tuesday = monday.addDays(1);

  TodayData build(List<Habit> habits, List<HabitEntry> entries) => buildToday(
    history: History(habits: habits, entries: entries),
    habits: habits,
    selected: tuesday,
    today: tuesday,
    firstWeekday: DateTime.monday,
  );

  test('due habits are listed with their value and capped progress', () {
    final water = habit(id: 1, type: HabitType.quantity, goal: 2000);
    final data = build(
      [water],
      [HabitEntry(habitId: 1, day: tuesday, value: 2250)],
    );
    final pill = data.active.single;
    expect((pill.value, pill.progress, pill.done), (2250, 1.0, true));
  });

  test('rest and paused habits go to the resting group', () {
    final rest = habit(id: 1, activeDays: {1});
    final paused = habit(id: 2, pauses: [Pause(tuesday, tuesday)]);
    final due = habit(id: 3);
    final data = build([rest, paused, due], []);
    expect(data.active.map((p) => p.habit.id), [3]);
    expect(data.resting.map((p) => (p.habit.id, p.status)), [
      (1, DayStatus.rest),
      (2, DayStatus.paused),
    ]);
  });

  test('habits created after the selected day are hidden', () {
    final data = build([habit(createdOn: tuesday.addDays(1))], []);
    expect(data.active, isEmpty);
    expect(data.resting, isEmpty);
  });

  test('a weekly frequency habit shows the week count against its target', () {
    final sport = habit(
      id: 1,
      type: HabitType.frequency,
      mode: ScheduleMode.weekly,
      timesPerWeek: 3,
    );
    final data = build(
      [sport],
      [
        HabitEntry(
          habitId: 1,
          day: monday.addDays(-1),
          value: 1,
        ), // previous week
        HabitEntry(habitId: 1, day: monday, value: 1),
      ],
    );
    final pill = data.active.single;
    expect(
      (pill.value, pill.weekCount, pill.progress, pill.done),
      (0, 1, 1 / 3, false),
    );
  });

  test('week dots mark days with something logged', () {
    final a = habit(id: 1);
    final data = build(
      [a],
      [
        HabitEntry(habitId: 1, day: monday, value: 1),
        HabitEntry(habitId: 1, day: tuesday, value: 0),
      ],
    );
    expect(data.weekDays.length, 7);
    expect(data.weekDays.first, monday);
    expect(data.loggedDays, {monday});
  });

  test('header shows the global streak and level', () {
    final a = habit(id: 1, createdOn: monday);
    final data = build([a], [HabitEntry(habitId: 1, day: monday, value: 1)]);
    expect(data.streak.current, 1);
    expect(data.level, levelFor(30));
  });
}
