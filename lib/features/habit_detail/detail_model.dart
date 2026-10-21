import 'dart:math' as math;

import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/rules.dart';

/// The month holding [day], padded with nulls to whole weeks.
List<Day?> monthGrid(Day day, int firstWeekday) {
  final first = Day(day.year, day.month, 1);
  final next = Day(day.year, day.month + 1, 1);
  final lead = first.difference(first.weekStart(firstWeekday));
  final cells = <Day?>[
    for (var i = 0; i < lead; i++) null,
    for (var d = first; d < next; d = d.addDays(1)) d,
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return cells;
}

enum DayCellState {
  done,

  /// Something logged, goal not reached, day over.
  partial,
  missed,
  joker,

  /// Rest, pause, or a weekly habit's day without a session.
  rest,

  /// Today, not done yet.
  today,
  future,
  untracked,
}

final class DayCell {
  const DayCell(this.day, this.state, this.value, this.progress);

  final Day day;
  final DayCellState state;
  final double value;
  final double progress;
}

DayCell dayCell(Habit h, History history, Day d, Day today) {
  final value = history.valueOf(h.id, d);
  DayCell cell(DayCellState s) => DayCell(d, s, value, h.progress(value));
  if (d > today) return cell(DayCellState.future);
  final status = h.statusOn(d);
  if (status == DayStatus.untracked) return cell(DayCellState.untracked);
  if (h.isCompleted(value)) return cell(DayCellState.done);
  if (history.jokerDays.contains(d)) return cell(DayCellState.joker);
  if (status != DayStatus.due) return cell(DayCellState.rest);
  if (d == today) return cell(DayCellState.today);
  return cell(value > 0 ? DayCellState.partial : DayCellState.missed);
}

final class HabitStats {
  const HabitStats({
    required this.streak,
    required this.monthDone,
    required this.monthDue,
  });

  final Streak streak;

  /// Days this month, up to today, where the goal was met.
  final int monthDone;

  /// Days this month, up to today, the habit was expected.
  final int monthDue;

  double get monthRate => monthDue == 0 ? 0 : monthDone / monthDue;
}

HabitStats habitStats(
  Habit h,
  History history,
  Day today, {
  int firstWeekday = DateTime.monday,
}) {
  var done = 0, due = 0;
  for (var d = Day(today.year, today.month, 1); d <= today; d = d.addDays(1)) {
    final status = h.statusOn(d);
    if (status != DayStatus.due && status != DayStatus.flexible) continue;
    due++;
    if (history.isDone(h, d)) done++;
  }
  return HabitStats(
    streak: habitStreak(h, history, today, firstWeekday: firstWeekday),
    monthDone: done,
    monthDue: due,
  );
}

/// Completed days in each of the last [weeks] weeks, oldest first.
List<int> weeklyCounts(
  Habit h,
  History history,
  Day today,
  int weeks, {
  int firstWeekday = DateTime.monday,
}) {
  final current = today.weekStart(firstWeekday);
  return [
    for (var w = weeks - 1; w >= 0; w--)
      [for (var i = 0; i < 7; i++) current.addDays(-7 * w + i)]
          .where((d) => d <= today && history.isDone(h, d))
          .length,
  ];
}

/// ISO 8601 week number (weeks start on Monday, week 1 holds a Thursday).
int isoWeek(Day d) {
  final thursday = d.addDays(DateTime.thursday - d.weekday);
  final jan1 = Day(thursday.year, 1, 1);
  return thursday.difference(jan1) ~/ 7 + 1;
}

/// Yesterday broke the global streak and a joker could save it (E2).
final class JokerPrompt {
  const JokerPrompt({
    required this.day,
    required this.missed,
    required this.streak,
    required this.jokers,
  });

  /// The day to save: yesterday.
  final Day day;
  final List<Habit> missed;

  /// The streak a joker keeps.
  final int streak;
  final int jokers;
}

JokerPrompt? jokerPrompt(History history, Day today) {
  final yesterday = today.addDays(-1);
  if (history.jokerDays.contains(yesterday) ||
      history.isPerfect(yesterday) != false) {
    return null;
  }
  // Judged "as of yesterday", an unfinished yesterday is neutral: this is the streak at stake.
  final streak = globalStreak(history, yesterday).current;
  final jokers = jokerBalance(history, today);
  if (math.min(streak, jokers) == 0) return null;
  return JokerPrompt(
    day: yesterday,
    missed: [
      for (final h in history.habits)
        if (h.statusOn(yesterday) == DayStatus.due &&
            !history.isDone(h, yesterday))
          h,
    ],
    streak: streak,
    jokers: jokers,
  );
}
