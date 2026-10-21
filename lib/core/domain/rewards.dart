import 'dart:math' as math;

import 'day.dart';
import 'habit.dart';
import 'rules.dart';

/// The 12 badges, in display order.
enum Badge {
  firstStep,
  streak7,
  earlyBird,
  bookworm,
  streak30,
  zen,
  perfectDay,
  perfectWeek,
  streak100,
  nightOwl,
  hydrated,
  rescue,
}

Iterable<Day> _days(Day from, Day to) sync* {
  for (var d = from; d <= to; d = d.addDays(1)) {
    yield d;
  }
}

Set<Badge> earnedBadges(History history, Day today) {
  final start = history.firstDay;
  if (start == null) return {};
  var anyDone = false, anyPerfect = false, perfectWeek = false;
  var mornings = 0, evenings = 0;
  var pages = 0.0, seconds = 0.0, milliliters = 0.0;
  for (final d in _days(start, today)) {
    for (final h in history.habits) {
      final v = history.valueOf(h.id, d);
      if (v <= 0 || h.statusOn(d) == DayStatus.untracked) continue;
      if (h.type == HabitType.duration) seconds += v;
      if (h.unit == QuantityUnit.pages) pages += v;
      if (h.unit?.isVolume ?? false) milliliters += v;
      if (!h.isCompleted(v)) continue;
      anyDone = true;
      if (h.moment == Moment.morning) mornings++;
      if (h.moment == Moment.evening) evenings++;
    }
    if (history.isPerfect(d) ?? false) anyPerfect = true;
    // A whole Monday-to-Sunday week ending on d, every day perfect or with nothing due.
    if (d.weekday == DateTime.sunday && d.addDays(-6) >= start) {
      final week = _days(d.addDays(-6), d).map(history.isPerfect).toList();
      perfectWeek |= week.every((p) => p != false) && week.contains(true);
    }
  }
  final best = globalStreak(history, today).best;
  return {
    if (anyDone) Badge.firstStep,
    if (best >= 7) Badge.streak7,
    if (mornings >= 10) Badge.earlyBird,
    if (pages >= 100) Badge.bookworm,
    if (best >= 30) Badge.streak30,
    if (seconds >= 10 * 3600) Badge.zen,
    if (anyPerfect) Badge.perfectDay,
    if (perfectWeek) Badge.perfectWeek,
    if (best >= 100) Badge.streak100,
    if (evenings >= 10) Badge.nightOwl,
    if (milliliters >= 20000) Badge.hydrated,
    if (history.jokerDays.isNotEmpty) Badge.rescue,
  };
}

enum ChallengeKind {
  /// A daily habit done every day of the week.
  sevenDays,

  /// A daily quantity habit's goal met on 5 days.
  goalFiveDays,

  /// A weekly habit's target reached.
  timesThisWeek,

  /// Seven perfect days.
  perfectWeek,
}

final class Challenge {
  const Challenge({
    required this.kind,
    required this.progress,
    required this.target,
    required this.xp,
    this.habit,
  });

  final ChallengeKind kind;

  /// The habit it is about; none for [ChallengeKind.perfectWeek].
  final Habit? habit;
  final int progress;
  final int target;
  final int xp;

  bool get completed => progress >= target;
}

/// The challenges of the Monday-started week holding [day], with their
/// progress up to [day]. Each kind picks among matching habits, a
/// different one from week to week. Weeks are ISO (Monday) whatever the
/// locale, so XP never depends on it.
List<Challenge> weeklyChallenges(History history, Day day) {
  final week = day.weekStart(DateTime.monday);
  final elapsed = _days(week, week.addDays(6)).where((d) => d <= day).toList();
  final tracked = [
    for (final h in history.habits)
      if (_days(
        week,
        week.addDays(6),
      ).any((d) => h.statusOn(d) != DayStatus.untracked))
        h,
  ]..sort((a, b) => a.id.compareTo(b.id));
  Habit? pick(bool Function(Habit) test) {
    final candidates = tracked.where(test).toList();
    return candidates.isEmpty
        ? null
        : candidates[(week.index ~/ 7) % candidates.length];
  }

  int doneDays(Habit h) => elapsed.where((d) => history.isDone(h, d)).length;
  final daily = pick((h) => !h.isWeekly && h.type != HabitType.quantity);
  final quantity = pick((h) => !h.isWeekly && h.type == HabitType.quantity);
  final weekly = pick((h) => h.isWeekly);
  return [
    if (daily != null)
      Challenge(
        kind: ChallengeKind.sevenDays,
        habit: daily,
        progress: doneDays(daily),
        target: 7,
        xp: 150,
      ),
    if (quantity != null)
      Challenge(
        kind: ChallengeKind.goalFiveDays,
        habit: quantity,
        progress: math.min(doneDays(quantity), 5),
        target: 5,
        xp: 100,
      ),
    if (weekly != null)
      Challenge(
        kind: ChallengeKind.timesThisWeek,
        habit: weekly,
        progress: math.min(doneDays(weekly), weekly.timesPerWeek),
        target: weekly.timesPerWeek,
        xp: 80,
      ),
    Challenge(
      kind: ChallengeKind.perfectWeek,
      progress: elapsed.where((d) => history.isPerfect(d) ?? false).length,
      target: 7,
      xp: 300,
    ),
  ];
}

/// XP of every challenge completed so far.
int challengeXp(History history, Day today) {
  final start = history.firstDay;
  if (start == null) return 0;
  var xp = 0;
  for (var w = start.weekStart(DateTime.monday); w <= today; w = w.addDays(7)) {
    final end = w.addDays(6) < today ? w.addDays(6) : today;
    xp += weeklyChallenges(
      history,
      end,
    ).where((c) => c.completed).fold(0, (sum, c) => sum + c.xp);
  }
  return xp;
}

/// XP that counts for the level: habits, perfect days and challenges.
int levelXp(History history, Day today) =>
    totalXp(history, today) + challengeXp(history, today);
