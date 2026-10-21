import 'dart:math' as math;

import 'day.dart';
import 'habit.dart';

const xpPerHabit = 10;
const perfectDayBonus = 20;
const perfectDaysPerJoker = 7;
const maxJokers = 2;

/// Everything logged so far, indexed for the rules below. Include archived
/// habits so past days keep being judged as they were.
final class History {
  History({
    required this.habits,
    required Iterable<HabitEntry> entries,
    this.jokerDays = const {},
  }) : _values = {for (final e in entries) (e.habitId, e.day): e.value};

  final List<Habit> habits;

  /// Days saved by a joker: neutral for every streak.
  final Set<Day> jokerDays;
  final Map<(int, Day), double> _values;

  double valueOf(int habitId, Day d) => _values[(habitId, d)] ?? 0;

  bool isDone(Habit h, Day d) => h.isCompleted(valueOf(h.id, d));

  /// Whether every habit due on [d] is done; null when nothing is due.
  bool? isPerfect(Day d) {
    final due = habits.where((h) => h.statusOn(d) == DayStatus.due);
    if (due.isEmpty) return null;
    return due.every((h) => isDone(h, d));
  }

  Day? get firstDay => habits.isEmpty
      ? null
      : habits.map((h) => h.createdOn).reduce((a, b) => a < b ? a : b);
}

final class Streak {
  const Streak({required this.current, required this.best});

  final int current;
  final int best;

  @override
  bool operator ==(Object other) =>
      other is Streak && other.current == current && other.best == best;

  @override
  int get hashCode => Object.hash(current, best);

  @override
  String toString() => 'Streak(current: $current, best: $best)';
}

final class Level {
  const Level({required this.level, required this.xp, required this.toNext});

  final int level;

  /// XP gathered inside this level.
  final int xp;

  /// XP this level takes in total.
  final int toNext;

  double get fraction => xp / toNext;

  @override
  bool operator ==(Object other) =>
      other is Level &&
      other.level == level &&
      other.xp == xp &&
      other.toNext == toNext;

  @override
  int get hashCode => Object.hash(level, xp, toNext);

  @override
  String toString() => 'Level($level, $xp / $toNext)';
}

enum _Outcome { success, failure, neutral }

Streak _fold(Iterable<_Outcome> outcomes) {
  var run = 0, best = 0;
  for (final o in outcomes) {
    if (o == _Outcome.success) best = math.max(best, ++run);
    if (o == _Outcome.failure) run = 0;
  }
  return Streak(current: run, best: best);
}

Iterable<Day> _days(Day from, Day to) sync* {
  for (var d = from; d <= to; d = d.addDays(1)) {
    yield d;
  }
}

/// Days in a row (weeks in a row for a weekly habit) where [h] met its goal.
/// Rest, pause and joker days are neutral; so is a today (or this week)
/// not finished yet.
Streak habitStreak(
  Habit h,
  History history,
  Day today, {
  int firstWeekday = DateTime.monday,
}) {
  if (!h.isWeekly) {
    return _fold(
      _days(h.createdOn, today).map((d) {
        if (h.statusOn(d) != DayStatus.due || history.jokerDays.contains(d)) {
          return _Outcome.neutral;
        }
        if (history.isDone(h, d)) return _Outcome.success;
        return d == today ? _Outcome.neutral : _Outcome.failure;
      }),
    );
  }
  final weeks = <_Outcome>[];
  for (
    var start = h.createdOn.weekStart(firstWeekday);
    start <= today;
    start = start.addDays(7)
  ) {
    final tracked = _days(
      start,
      start.addDays(6),
    ).where((d) => h.statusOn(d) == DayStatus.flexible).toList();
    final required = math.min(h.timesPerWeek, tracked.length);
    final doneCount = tracked
        .where((d) => d <= today && history.isDone(h, d))
        .length;
    weeks.add(switch (required) {
      0 => _Outcome.neutral,
      _ when doneCount >= required => _Outcome.success,
      _ when start.addDays(6) >= today => _Outcome.neutral,
      _ => _Outcome.failure,
    });
  }
  return _fold(weeks);
}

/// Perfect days in a row: the global flame.
Streak globalStreak(History history, Day today) {
  final start = history.firstDay;
  if (start == null) return const Streak(current: 0, best: 0);
  return _fold(
    _days(start, today).map((d) {
      if (history.jokerDays.contains(d)) return _Outcome.neutral;
      return switch (history.isPerfect(d)) {
        null => _Outcome.neutral,
        true => _Outcome.success,
        false when d == today => _Outcome.neutral,
        false => _Outcome.failure,
      };
    }),
  );
}

int totalXp(History history, Day today) {
  final start = history.firstDay;
  if (start == null) return 0;
  var xp = 0;
  for (final d in _days(start, today)) {
    for (final h in history.habits) {
      if (h.statusOn(d) != DayStatus.untracked && history.isDone(h, d)) {
        xp += xpPerHabit;
      }
    }
    if (history.isPerfect(d) ?? false) xp += perfectDayBonus;
  }
  return xp;
}

/// Level n to n+1 costs 50 × (n + 3) XP: 200 at level 1, 500 at level 7.
Level levelFor(int xp) {
  var level = 1;
  while (xp >= _levelCost(level)) {
    xp -= _levelCost(level++);
  }
  return Level(level: level, xp: xp, toNext: _levelCost(level));
}

int _levelCost(int level) => 50 * (level + 3);

/// Jokers in reserve: one earned on every 7th perfect day, at most 2 held;
/// one spent per joker day. Replayed day by day so the cap applies in order.
int jokerBalance(History history, Day today) {
  final start = history.firstDay;
  if (start == null) return 0;
  var balance = 0, perfect = 0;
  for (final d in _days(start, today)) {
    if (history.jokerDays.contains(d)) {
      balance = math.max(0, balance - 1);
    } else if (history.isPerfect(d) ?? false) {
      if (++perfect % perfectDaysPerJoker == 0) {
        balance = math.min(maxJokers, balance + 1);
      }
    }
  }
  return balance;
}
