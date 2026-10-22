import '../domain/day.dart';
import '../domain/habit.dart';
import '../domain/rules.dart';

/// Days ahead that get scheduled; recomputed on every launch and change.
const reminderWindowDays = 14;

/// Time of the daily "streak at risk" alert, minutes after midnight.
const streakDangerMinutes = 21 * 60;

enum ReminderKind { habit, streakDanger }

final class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.at,
    required this.day,
    required this.kind,
    required this.habits,
  });

  final int id;

  /// Local wall-clock time.
  final DateTime at;

  /// The logical day it is about.
  final Day day;
  final ReminderKind kind;

  /// The habit to do, or the habits whose streak is at risk.
  final List<Habit> habits;
}

/// Wall-clock time of [minutes] on logical [day]: before the rollover hour
/// it falls on the next calendar date.
DateTime _wallClock(Day day, int minutes, int rolloverHour) {
  final d = minutes < rolloverHour * 60 ? day.addDays(1) : day;
  return DateTime(d.year, d.month, d.day, minutes ~/ 60, minutes % 60);
}

/// Every reminder of the next [reminderWindowDays] logical days, skipping
/// rest days, pauses, and what is already done (a weekly habit stops once
/// its week's target is met). One "streak at risk" alert a day lists the
/// due, undone habits that have a streak going and the alert on.
List<PlannedReminder> planReminders(
  History history,
  List<Habit> active,
  DateTime now, {
  int rolloverHour = 3,
  int firstWeekday = DateTime.monday,
}) {
  final today = logicalDay(now, rolloverHour: rolloverHour);
  final atRisk = [
    for (final h in active)
      if (h.streakDangerAlert &&
          !h.isWeekly &&
          habitStreak(h, history, today).current > 0)
        h,
  ];
  final alive = {for (final h in atRisk) h.id};
  final plans =
      <({DateTime at, Day day, ReminderKind kind, List<Habit> habits})>[];
  for (var i = 0; i < reminderWindowDays; i++) {
    final day = today.addDays(i);
    for (final h in active) {
      final status = h.statusOn(day);
      if (status != DayStatus.due && status != DayStatus.flexible) continue;
      if (history.isDone(h, day)) continue;
      if (h.isWeekly) {
        final start = day.weekStart(firstWeekday);
        final count = [for (var j = 0; j < 7; j++) start.addDays(j)]
            .where((d) => history.isDone(h, d))
            .length;
        if (count >= h.timesPerWeek) continue;
      }
      for (final m in h.reminders) {
        plans.add((
          at: _wallClock(day, m, rolloverHour),
          day: day,
          kind: ReminderKind.habit,
          habits: [h],
        ));
      }
    }
    // A due day not done yet breaks the streak for every later day (logging
    // needs the app, which replans), so later alerts would be false.
    final risky = <Habit>[];
    for (final h in atRisk) {
      if (!alive.contains(h.id) || h.statusOn(day) != DayStatus.due) continue;
      if (history.isDone(h, day)) continue;
      risky.add(h);
      alive.remove(h.id);
    }
    if (risky.isNotEmpty) {
      plans.add((
        at: _wallClock(day, streakDangerMinutes, rolloverHour),
        day: day,
        kind: ReminderKind.streakDanger,
        habits: risky,
      ));
    }
  }
  final upcoming = plans.where((p) => p.at.isAfter(now)).toList()
    ..sort((a, b) => a.at.compareTo(b.at));
  return [
    for (final (i, p) in upcoming.indexed)
      PlannedReminder(
        id: i + 1,
        at: p.at,
        day: p.day,
        kind: p.kind,
        habits: p.habits,
      ),
  ];
}
