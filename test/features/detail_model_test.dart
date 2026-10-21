import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rules.dart';
import 'package:little_steps/features/habit_detail/detail_model.dart';

import '../domain/fixtures.dart';

List<HabitEntry> done(Habit h, Iterable<int> offsets, {double? value}) => [
  for (final o in offsets)
    HabitEntry(habitId: h.id, day: monday.addDays(o), value: value ?? h.goal),
];

void main() {
  // Monday 19 October 2026; October 1st is a Thursday.
  final today = monday.addDays(1);

  group('month grid', () {
    test('pads to whole weeks from the locale first day', () {
      final grid = monthGrid(today, DateTime.monday);
      expect(grid.length % 7, 0);
      expect(grid.take(3), everyElement(isNull));
      expect(grid[3], Day(2026, 10, 1));
      expect(grid.whereType<Day>().length, 31);
    });

    test('Sunday-first weeks shift the padding', () {
      final grid = monthGrid(today, DateTime.sunday);
      expect(grid.take(4), everyElement(isNull));
      expect(grid[4], Day(2026, 10, 1));
    });
  });

  group('day cell', () {
    final h = habit(
      id: 1,
      goal: 2000,
      activeDays: {1, 2, 3, 4, 5},
      createdOn: monday.addDays(-10),
    );

    DayCellState state(
      List<HabitEntry> e,
      Day d, {
      Set<Day> jokers = const {},
    }) => dayCell(
      h,
      History(habits: [h], entries: e, jokerDays: jokers),
      d,
      today,
    ).state;

    test('done, partial and missed past days', () {
      expect(state(done(h, [0]), monday), DayCellState.done);
      expect(state(done(h, [0], value: 500), monday), DayCellState.partial);
      expect(state([], monday), DayCellState.missed);
    });

    test('joker, rest, today, future and before creation', () {
      expect(state([], monday, jokers: {monday}), DayCellState.joker);
      expect(state([], monday.addDays(-2)), DayCellState.rest);
      expect(state([], today), DayCellState.today);
      expect(state([], today.addDays(1)), DayCellState.future);
      expect(state([], monday.addDays(-30)), DayCellState.untracked);
    });

    test('carries the value and its capped progress', () {
      final cell = dayCell(
        h,
        History(habits: [h], entries: done(h, [0], value: 3000)),
        monday,
        today,
      );
      expect((cell.value, cell.progress), (3000.0, 1.0));
    });
  });

  group('stats', () {
    test('month rate and count over due days so far', () {
      // October: due weekdays from the 1st up to Tuesday 20 = 14 days.
      final h = habit(
        id: 1,
        activeDays: {1, 2, 3, 4, 5},
        createdOn: Day(2026, 9, 1),
      );
      final s = habitStats(
        h,
        History(habits: [h], entries: done(h, [-18, -17, -14, 0, 1])),
        today,
      );
      expect((s.monthDone, s.monthDue), (5, 14));
      expect(s.monthRate, closeTo(5 / 14, 1e-9));
    });

    test('a habit created mid-month only counts its own days', () {
      final h = habit(id: 1, createdOn: monday);
      final s = habitStats(
        h,
        History(habits: [h], entries: done(h, [0])),
        today,
      );
      expect((s.monthDone, s.monthDue), (1, 2));
    });
  });

  group('weeks', () {
    test('completed days per week, oldest first, this week last', () {
      final h = habit(
        id: 1,
        mode: ScheduleMode.weekly,
        createdOn: monday.addDays(-30),
      );
      final counts = weeklyCounts(
        h,
        History(habits: [h], entries: done(h, [-14, -13, -7, 0, 1])),
        today,
        3,
      );
      expect(counts, [2, 1, 2]);
    });

    test('ISO week numbers', () {
      expect(isoWeek(Day(2026, 10, 19)), 43);
      expect(isoWeek(Day(2026, 1, 1)), 1);
      expect(isoWeek(Day(2027, 1, 1)), 53);
    });
  });

  group('joker prompt', () {
    final a = habit(id: 1, createdOn: monday.addDays(-20));
    final b = habit(id: 2, createdOn: monday.addDays(-20));
    // 14 perfect days before yesterday earn 2 jokers.
    List<HabitEntry> perfectUntil(int lastOffset) => [
      ...done(a, [for (var i = -14; i <= lastOffset; i++) i]),
      ...done(b, [for (var i = -14; i <= lastOffset; i++) i]),
    ];

    test('yesterday broke the streak and a joker is left', () {
      final entries = [
        ...perfectUntil(-1),
        ...done(a, [0]),
      ];
      final p = jokerPrompt(History(habits: [a, b], entries: entries), today)!;
      expect(p.missed.map((h) => h.id), [2]);
      expect((p.streak, p.jokers, p.day), (14, 2, monday));
    });

    test('nothing to save when yesterday was perfect or already saved', () {
      expect(
        jokerPrompt(History(habits: [a, b], entries: perfectUntil(0)), today),
        isNull,
      );
      expect(
        jokerPrompt(
          History(
            habits: [a, b],
            entries: perfectUntil(-1),
            jokerDays: {monday},
          ),
          today,
        ),
        isNull,
      );
    });

    test('nothing to save without a streak or without jokers', () {
      expect(jokerPrompt(History(habits: [a, b], entries: []), today), isNull);
      final shortRun = [
        ...done(a, [-3, -2, -1]),
        ...done(b, [-3, -2, -1]),
      ];
      expect(
        jokerPrompt(History(habits: [a, b], entries: shortRun), today),
        isNull,
      );
    });
  });
}
