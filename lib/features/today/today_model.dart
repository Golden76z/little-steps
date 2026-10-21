import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/rules.dart';

/// One habit as shown on Today for the selected day.
final class PillData {
  const PillData({
    required this.habit,
    required this.status,
    required this.value,
    required this.progress,
    required this.done,
    this.weekCount,
  });

  final Habit habit;
  final DayStatus status;

  /// Logged on the selected day, in base units.
  final double value;
  final double progress;
  final bool done;

  /// Completed days this week, for a weekly frequency habit.
  final int? weekCount;
}

final class TodayData {
  const TodayData({
    required this.active,
    required this.resting,
    required this.weekDays,
    required this.loggedDays,
    required this.streak,
    required this.level,
  });

  final List<PillData> active;

  /// At rest or paused on the selected day.
  final List<PillData> resting;
  final List<Day> weekDays;

  /// Days of [weekDays] with something logged.
  final Set<Day> loggedDays;
  final Streak streak;
  final Level level;
}

TodayData buildToday({
  required History history,
  required List<Habit> habits,
  required Day selected,
  required Day today,
  required int firstWeekday,
}) {
  final start = selected.weekStart(firstWeekday);
  final week = [for (var i = 0; i < 7; i++) start.addDays(i)];
  final active = <PillData>[], resting = <PillData>[];
  for (final h in habits) {
    final status = h.statusOn(selected);
    if (status == DayStatus.untracked) continue;
    final value = history.valueOf(h.id, selected);
    final PillData pill;
    if (h.type == HabitType.frequency && h.isWeekly) {
      final count = week
          .where((d) => d <= today && history.isDone(h, d))
          .length;
      pill = PillData(
        habit: h,
        status: status,
        value: value,
        weekCount: count,
        progress: (count / h.timesPerWeek).clamp(0, 1).toDouble(),
        done: count >= h.timesPerWeek,
      );
    } else {
      pill = PillData(
        habit: h,
        status: status,
        value: value,
        progress: h.progress(value),
        done: h.isCompleted(value),
      );
    }
    (status == DayStatus.rest || status == DayStatus.paused ? resting : active)
        .add(pill);
  }
  return TodayData(
    active: active,
    resting: resting,
    weekDays: week,
    loggedDays: {
      for (final d in week)
        if (history.habits.any((h) => history.valueOf(h.id, d) > 0)) d,
    },
    streak: globalStreak(history, today),
    level: levelFor(totalXp(history, today)),
  );
}
