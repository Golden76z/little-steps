import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rules.dart';

import 'fixtures.dart';

/// Entries completing [h] on each day offset from [monday].
List<HabitEntry> done(Habit h, Iterable<int> offsets) => [
  for (final o in offsets)
    HabitEntry(habitId: h.id, day: monday.addDays(o), value: h.goal),
];

Iterable<int> range(int from, int to) => [for (var i = from; i <= to; i++) i];

void main() {
  // Habits exist from Monday 19 October, "today" is Sunday 25 unless stated.
  final today = monday.addDays(6);
  final a = habit(id: 1, createdOn: monday);
  final b = habit(id: 2, createdOn: monday);

  group('perfect day', () {
    test('all due habits completed', () {
      final h = History(
        habits: [a, b],
        entries: [
          ...done(a, [0]),
          ...done(b, [0]),
        ],
      );
      expect(h.isPerfect(monday), isTrue);
    });

    test('one due habit missing', () {
      final h = History(habits: [a, b], entries: done(a, [0]));
      expect(h.isPerfect(monday), isFalse);
    });

    test('a partial value is not done', () {
      final water = habit(id: 3, goal: 2000, createdOn: monday);
      final h = History(
        habits: [water],
        entries: [HabitEntry(habitId: 3, day: monday, value: 1750)],
      );
      expect(h.isPerfect(monday), isFalse);
    });

    test('ignores habits at rest, paused or weekly', () {
      final rest = habit(id: 3, createdOn: monday, activeDays: {2});
      final paused = habit(
        id: 4,
        createdOn: monday,
        pauses: [Pause(monday, monday)],
      );
      final weekly = habit(id: 5, createdOn: monday, mode: ScheduleMode.weekly);
      final h = History(
        habits: [a, rest, paused, weekly],
        entries: done(a, [0]),
      );
      expect(h.isPerfect(monday), isTrue);
    });

    test('is neutral (null) when nothing is due', () {
      final rest = habit(id: 3, createdOn: monday, activeDays: {2});
      expect(History(habits: [rest], entries: []).isPerfect(monday), isNull);
    });
  });

  group('habit streak', () {
    test('counts consecutive completed days', () {
      final h = History(habits: [a], entries: done(a, range(2, 6)));
      expect(habitStreak(a, h, today), const Streak(current: 5, best: 5));
    });

    test('today not done yet does not break it', () {
      final h = History(habits: [a], entries: done(a, range(0, 5)));
      expect(habitStreak(a, h, today).current, 6);
    });

    test('a missed past day resets it but keeps the record', () {
      final h = History(habits: [a], entries: done(a, [0, 1, 2, 4, 5]));
      expect(habitStreak(a, h, today), const Streak(current: 2, best: 3));
    });

    test('rest and pause days are neutral', () {
      final weekdays = habit(
        id: 3,
        createdOn: monday,
        activeDays: {1, 2, 3, 4, 5},
        pauses: [Pause(monday.addDays(1), monday.addDays(2))],
      );
      final h = History(habits: [weekdays], entries: done(weekdays, [0, 3, 4]));
      expect(habitStreak(weekdays, h, today).current, 3);
    });

    test('a joker day is neutral', () {
      final h = History(
        habits: [a],
        entries: done(a, [0, 1, 3, 4, 5, 6]),
        jokerDays: {monday.addDays(2)},
      );
      expect(habitStreak(a, h, today).current, 6);
    });

    test('weekly habit counts weeks reaching the target', () {
      final sport = habit(
        id: 3,
        mode: ScheduleMode.weekly,
        timesPerWeek: 3,
        createdOn: monday.addDays(-21),
      );
      // Weeks starting at -21, -14, -7 and the current one.
      final h = History(
        habits: [sport],
        entries: done(sport, [-21, -20, -19, -14, -10, -8, -7, -6, -5, 0]),
      );
      expect(habitStreak(sport, h, today), const Streak(current: 3, best: 3));
    });

    test('weekly habit: the week in progress does not break it', () {
      final sport = habit(
        id: 3,
        mode: ScheduleMode.weekly,
        timesPerWeek: 3,
        createdOn: monday.addDays(-7),
      );
      final h = History(habits: [sport], entries: done(sport, [-7, -6, -5]));
      expect(habitStreak(sport, h, monday.addDays(2)).current, 1);
    });

    test('weekly habit: a missed week resets it', () {
      final sport = habit(
        id: 3,
        mode: ScheduleMode.weekly,
        timesPerWeek: 3,
        createdOn: monday.addDays(-14),
      );
      final h = History(
        habits: [sport],
        entries: done(sport, [-14, -13, -12, -7, 0, 1, 2]),
      );
      expect(habitStreak(sport, h, today), const Streak(current: 1, best: 1));
    });

    test('weekly habit: target shrinks to the days actually tracked', () {
      // Created on Saturday: only 2 days that week, target 3.
      final sport = habit(
        id: 3,
        mode: ScheduleMode.weekly,
        timesPerWeek: 3,
        createdOn: monday.addDays(-2),
      );
      final h = History(
        habits: [sport],
        entries: done(sport, [-2, -1, 0, 1, 2]),
      );
      expect(habitStreak(sport, h, today).current, 2);
    });

    test('weekly habit follows the locale first weekday', () {
      final sport = habit(
        id: 3,
        mode: ScheduleMode.weekly,
        timesPerWeek: 2,
        createdOn: monday.addDays(-8),
      );
      // Sunday-first weeks: Sun -8..Sat -2 and Sun -1..Sat 5.
      final h = History(habits: [sport], entries: done(sport, [-3, -2, -1, 0]));
      expect(
        habitStreak(
          sport,
          h,
          monday.addDays(5),
          firstWeekday: DateTime.sunday,
        ).current,
        2,
      );
      expect(habitStreak(sport, h, monday.addDays(5)).current, 1);
    });
  });

  group('global streak', () {
    test('counts consecutive perfect days, today included once perfect', () {
      final h = History(
        habits: [a, b],
        entries: [...done(a, range(0, 6)), ...done(b, range(0, 6))],
      );
      expect(globalStreak(h, today), const Streak(current: 7, best: 7));
    });

    test('an imperfect past day breaks it', () {
      final h = History(
        habits: [a, b],
        entries: [
          ...done(a, range(0, 5)),
          ...done(b, [0, 1, 3, 4, 5]),
        ],
      );
      expect(globalStreak(h, today), const Streak(current: 3, best: 3));
    });

    test('a joker saves the day without extending it', () {
      final h = History(
        habits: [a, b],
        entries: [
          ...done(a, range(0, 5)),
          ...done(b, [0, 1, 3, 4, 5]),
        ],
        jokerDays: {monday.addDays(2)},
      );
      expect(globalStreak(h, today).current, 5);
    });

    test('days with nothing due are neutral', () {
      final weekdays = habit(
        id: 3,
        createdOn: monday,
        activeDays: {1, 2, 3, 4, 5},
      );
      final h = History(
        habits: [weekdays],
        entries: done(weekdays, range(0, 4)),
      );
      expect(globalStreak(h, monday.addDays(7)).current, 5);
    });

    test('is zero without any habit', () {
      expect(
        globalStreak(History(habits: [], entries: []), today),
        const Streak(current: 0, best: 0),
      );
    });
  });

  group('XP', () {
    test('10 per completed habit plus 20 per perfect day', () {
      // Monday perfect (2×10 + 20), Tuesday only a (10).
      final h = History(
        habits: [a, b],
        entries: [
          ...done(a, [0, 1]),
          ...done(b, [0]),
        ],
      );
      expect(totalXp(h, today), 50);
    });

    test('a weekly session counts as a completed habit', () {
      final sport = habit(id: 3, mode: ScheduleMode.weekly, createdOn: monday);
      final h = History(habits: [sport], entries: done(sport, [0, 2]));
      expect(totalXp(h, today), 20);
    });

    test('ignores entries after today', () {
      final h = History(habits: [a], entries: done(a, [7]));
      expect(totalXp(h, today), 0);
    });
  });

  group('level', () {
    test('starts at level 1', () {
      expect(levelFor(0), const Level(level: 1, xp: 0, toNext: 200));
    });

    test('level n to n+1 costs 50 × (n + 3)', () {
      expect(levelFor(199).level, 1);
      expect(levelFor(200), const Level(level: 2, xp: 0, toNext: 250));
    });

    test('matches the mockup: level 7 at 340 / 500', () {
      expect(levelFor(1950 + 340), const Level(level: 7, xp: 340, toNext: 500));
    });

    test('exposes the fraction for the avatar ring', () {
      expect(levelFor(1950 + 340).fraction, closeTo(0.68, 1e-9));
    });
  });

  group('jokers', () {
    List<HabitEntry> perfectDays(Iterable<int> offsets) => done(a, offsets);
    final longAgo = habit(id: 1, createdOn: monday.addDays(-60));

    test('one earned every 7 perfect days', () {
      expect(
        jokerBalance(
          History(habits: [longAgo], entries: perfectDays(range(-6, -1))),
          today,
        ),
        0,
      );
      expect(
        jokerBalance(
          History(habits: [longAgo], entries: perfectDays(range(-6, 0))),
          today,
        ),
        1,
      );
    });

    test('perfect days need not be consecutive', () {
      final h = History(
        habits: [longAgo],
        entries: perfectDays([-20, -18, -15, -11, -9, -4, -2]),
      );
      expect(jokerBalance(h, today), 1);
    });

    test('caps the reserve at 2', () {
      final h = History(
        habits: [longAgo],
        entries: perfectDays(range(-30, -9)),
      );
      expect(jokerBalance(h, today), 2);
    });

    test('using one spends it', () {
      final h = History(
        habits: [longAgo],
        entries: perfectDays(range(-20, -7)),
        jokerDays: {monday.addDays(-6)},
      );
      expect(jokerBalance(h, today), 1);
    });

    test('a joker earned at the cap is lost', () {
      // 21 perfect days: the 3rd joker only counts if one was spent before it.
      final entries = perfectDays([...range(-30, -17), ...range(-15, -9)]);
      final spentBefore = History(
        habits: [longAgo],
        entries: entries,
        jokerDays: {monday.addDays(-16)},
      );
      final spentAfter = History(
        habits: [longAgo],
        entries: entries,
        jokerDays: {monday.addDays(-8)},
      );
      expect(jokerBalance(spentBefore, today), 2);
      expect(jokerBalance(spentAfter, today), 1);
    });
  });
}
