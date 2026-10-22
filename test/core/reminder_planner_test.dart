import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rules.dart';
import 'package:little_steps/core/notifications/reminder_planner.dart';

import '../domain/fixtures.dart';

/// Monday 19 October 2026, 10 am.
final now = DateTime(2026, 10, 19, 10);

List<HabitEntry> done(Habit h, Iterable<int> offsets) => [
  for (final o in offsets)
    HabitEntry(habitId: h.id, day: monday.addDays(o), value: h.goal),
];

List<PlannedReminder> plan(
  List<Habit> habits, {
  List<HabitEntry> entries = const [],
  DateTime? at,
  int rollover = 3,
}) => planReminders(
  History(habits: habits, entries: entries),
  habits,
  at ?? now,
  rolloverHour: rollover,
);

Habit withReminders(Habit h, List<int> minutes, {bool danger = false}) => Habit(
  id: h.id,
  name: h.name,
  type: h.type,
  color: h.color,
  icon: h.icon,
  goal: h.goal,
  step: h.step,
  scheduleMode: h.scheduleMode,
  activeDays: h.activeDays,
  timesPerWeek: h.timesPerWeek,
  reminders: minutes,
  streakDangerAlert: danger,
  createdOn: h.createdOn,
  pauses: h.pauses,
);

void main() {
  test('one reminder per day over the 14-day window, from now on', () {
    final r = plan([
      withReminders(habit(), [8 * 60, 20 * 60]),
    ]);
    // Today 08:00 is past: 1 left today + 13 days × 2.
    expect(r, hasLength(27));
    expect(r.first.at, DateTime(2026, 10, 19, 20));
    expect(r.last.at, DateTime(2026, 11, 1, 20));
    expect(r.map((x) => x.id).toSet(), hasLength(27));
  });

  test('rest days, pauses and before creation are skipped', () {
    final h = withReminders(
      habit(
        activeDays: {1, 2, 3, 4, 5},
        pauses: [Pause(monday.addDays(1), monday.addDays(2))],
      ),
      [20 * 60],
    );
    final days = plan([h]).map((x) => x.at.day).toList();
    expect(days.take(5), [19, 22, 23, 26, 27]);
  });

  test('a habit already done that day gets no reminder', () {
    final h = withReminders(habit(), [20 * 60]);
    expect(
      plan([h], entries: done(h, [0])).first.at,
      DateTime(2026, 10, 20, 20),
    );
  });

  test('a weekly habit stops reminding once its target is met', () {
    final h = withReminders(habit(mode: ScheduleMode.weekly, timesPerWeek: 2), [
      20 * 60,
    ]);
    final r = plan(
      [h],
      entries: done(h, [-1 + 1, 1]),
      at: DateTime(2026, 10, 20, 10),
    );
    // Target met this week (Mon + Tue): next reminder is next Monday.
    expect(r.first.at, DateTime(2026, 10, 26, 20));
  });

  test('a time before the rollover belongs to the logical day before', () {
    final h = withReminders(habit(), [60]);
    final r = plan([h]);
    expect(r.first.at, DateTime(2026, 10, 20, 1));
    expect(r.first.day, monday);
  });

  test('one streak alert at 21:00 listing the habits at risk', () {
    final a = withReminders(
      habit(id: 1, createdOn: monday.addDays(-10)),
      [],
      danger: true,
    );
    final b = withReminders(
      habit(id: 2, createdOn: monday.addDays(-10)),
      [],
      danger: true,
    );
    final c = withReminders(habit(id: 3, createdOn: monday.addDays(-10)), []);
    final r = plan(
      [a, b, c],
      entries: [
        ...done(a, [-2, -1]),
        ...done(b, [-1]),
        ...done(c, [-1]),
      ],
    );
    final today = r
        .where((x) => x.kind == ReminderKind.streakDanger && x.at.day == 19)
        .single;
    expect(today.at, DateTime(2026, 10, 19, 21));
    expect(today.habits.map((h) => h.id), [1, 2]);
  });

  test('no streak alert without a streak, once done, or for weekly habits', () {
    final a = withReminders(
      habit(id: 1, createdOn: monday.addDays(-10)),
      [],
      danger: true,
    );
    final w = withReminders(
      habit(id: 2, mode: ScheduleMode.weekly, createdOn: monday.addDays(-10)),
      [],
      danger: true,
    );
    expect(
      plan([a, w]).where((x) => x.kind == ReminderKind.streakDanger),
      isEmpty,
    );
    final r = plan([a], entries: done(a, [-1, 0]));
    expect(
      r.where((x) => x.kind == ReminderKind.streakDanger && x.at.day == 19),
      isEmpty,
    );
  });

  test('a streak alert for a later day only while the streak still holds', () {
    final a = withReminders(
      habit(
        id: 1,
        activeDays: {1, 3, 4, 5, 6, 7},
        createdOn: monday.addDays(-10),
      ),
      [],
      danger: true,
    );
    final alerts = plan(
      [a],
      entries: done(a, [-2, -1]),
    ).where((x) => x.kind == ReminderKind.streakDanger);
    // Not done today: today's alert only; past today the streak is already gone.
    expect(alerts.map((x) => x.at.day), [19]);
    final afterDone = plan(
      [a],
      entries: done(a, [-2, -1, 0]),
    ).where((x) => x.kind == ReminderKind.streakDanger);
    // Done today, Tuesday is a rest day: the next due day, Wednesday, is still at stake.
    expect(afterDone.map((x) => x.at.day), [21]);
  });
}
