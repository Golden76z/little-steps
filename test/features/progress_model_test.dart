import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rules.dart';
import 'package:little_steps/features/progress/progress_model.dart';

import '../domain/fixtures.dart';

final tuesday = monday.addDays(1);

History history(List<Habit> habits, Map<int, List<Day>> done) => History(
  habits: habits,
  entries: [
    for (final MapEntry(key: id, value: days) in done.entries)
      for (final d in days) HabitEntry(habitId: id, day: d, value: 1),
  ],
);

ProgressData build(
  History h,
  Period period, {
  Day? anchor,
  List<Habit>? habits,
}) => buildProgress(
  history: h,
  habits: habits ?? h.habits,
  period: period,
  anchor: anchor ?? tuesday,
  today: tuesday,
  firstWeekday: DateTime.monday,
);

void main() {
  group('week', () {
    final a = habit(id: 1);
    final b = habit(id: 2, activeDays: {DateTime.monday});
    final h = history(
      [a, b],
      {
        1: [monday],
        2: [monday],
      },
    );

    test('rate counts planned pills up to today only', () {
      final p = build(h, Period.week);
      expect((p.from, p.to), (monday, monday.addDays(6)));
      // a: Mon + Tue, b: Mon; Tue not filled yet.
      expect(p.total, const Tally(2, 3));
      expect(p.total.rate, closeTo(2 / 3, 1e-9));
    });

    test('one slice per day, today marked current', () {
      final p = build(h, Period.week);
      expect(p.slices, hasLength(7));
      expect(p.slices[0].tally, const Tally(2, 2));
      expect(p.slices[1].tally, const Tally(0, 1));
      expect(p.slices[2].tally, const Tally(0, 0));
      expect(p.current, 1);
    });

    test('a weekly habit is planned every flexible day', () {
      final w = habit(id: 3, mode: ScheduleMode.weekly);
      final p = build(
        history(
          [w],
          {
            3: [monday],
          },
        ),
        Period.week,
      );
      expect(p.total, const Tally(1, 2));
    });

    test('rest days are not planned', () {
      final p = build(h, Period.week, habits: [b]);
      expect(p.rows.single.$2, const Tally(1, 1));
    });
  });

  test('month: one slice per week touching it, clipped to the month', () {
    final p = build(history([habit()], {}), Period.month);
    expect((p.from, p.to), (Day(2026, 10, 1), Day(2026, 10, 31)));
    expect([for (final s in p.slices) s.from.day], [1, 5, 12, 19, 26]);
    expect(p.slices.first.to, Day(2026, 10, 4));
    expect(p.slices.last.to, Day(2026, 10, 31));
    expect(p.current, 3);
    // 1 → 20 October.
    expect(p.total.planned, 20);
  });

  test('year: twelve monthly slices', () {
    final p = build(history([habit()], {}), Period.year);
    expect(p.slices, hasLength(12));
    expect(p.slices[9].from, Day(2026, 10, 1));
    expect(p.slices[9].to, Day(2026, 10, 31));
    expect(p.slices[11].tally.planned, 0);
    expect(p.current, 9);
  });

  test('a past period has no current slice', () {
    final p = build(
      history([habit()], {}),
      Period.week,
      anchor: monday.addDays(-7),
    );
    expect(p.current, isNull);
    expect(p.total.planned, 7);
  });

  group('versus previous period', () {
    test('signed gap in rounded points', () {
      final a = habit(id: 1);
      final p = build(
        history(
          [a],
          {
            1: [for (var i = 1; i <= 7; i++) monday.addDays(-i), monday],
          },
        ),
        Period.week,
      );
      // 1 / 2 now against 7 / 7 last week.
      expect(p.deltaPoints, -50);
    });

    test('none when the previous period planned nothing', () {
      final a = habit(id: 1, createdOn: monday);
      final p = build(
        history(
          [a],
          {
            1: [monday],
          },
        ),
        Period.week,
      );
      expect(p.deltaPoints, isNull);
    });
  });

  test('rows sorted by days succeeded, ties keep their order', () {
    final a = habit(id: 1), b = habit(id: 2), c = habit(id: 3);
    final p = build(
      history(
        [a, b, c],
        {
          2: [monday, tuesday],
          3: [monday],
          1: [monday],
        },
      ),
      Period.week,
    );
    expect([for (final r in p.rows) r.$1.id], [2, 1, 3]);
    expect(p.rows.first.$2, const Tally(2, 2));
  });

  test('shiftPeriod moves by week, month or year', () {
    final d = Day(2026, 1, 15);
    expect(shiftPeriod(Period.week, d, -1), Day(2026, 1, 8));
    expect(shiftPeriod(Period.month, d, -1), Day(2025, 12, 1));
    expect(shiftPeriod(Period.year, d, 1), Day(2027, 1, 1));
  });
}
