import 'day.dart';

enum HabitType { quantity, duration, yesNo, journal, frequency }

/// The 12 habit tints offered at creation, in the P2-Reglages order.
enum HabitColor {
  lilac,
  lavender,
  sky,
  lagoon,
  mint,
  pistachio,
  lemon,
  apricot,
  peach,
  coral,
  pink,
  raspberry,
}

/// Display unit of a quantity habit. Values are stored in [baseFactor]
/// multiples (ml for volumes, metres for km), so glasses and litres stay
/// interchangeable.
enum QuantityUnit {
  glasses(250, goalStep: 250, defaultGoal: 2000, stepPresets: [250, 500, 750]),
  liters(1000, goalStep: 250, defaultGoal: 2000, stepPresets: [250, 330, 500]),
  milliliters(
    1,
    goalStep: 250,
    defaultGoal: 2000,
    stepPresets: [250, 330, 500],
  ),
  pages(1, goalStep: 5, defaultGoal: 20, stepPresets: [1, 4, 10]),
  steps(1, goalStep: 1000, defaultGoal: 8000, stepPresets: [500, 1000, 2000]),
  kilometers(
    1000,
    goalStep: 500,
    defaultGoal: 5000,
    stepPresets: [500, 1000, 2000],
  ),
  times(1, goalStep: 1, defaultGoal: 3, stepPresets: [1, 2, 5]);

  const QuantityUnit(
    this.baseFactor, {
    required this.goalStep,
    required this.defaultGoal,
    required this.stepPresets,
  });

  final double baseFactor;

  /// Goal +/− increment in the creation flow, base units.
  final double goalStep;
  final double defaultGoal;

  /// Quick-add choices offered at creation, base units.
  final List<double> stepPresets;

  bool get isVolume => this == glasses || this == liters || this == milliliters;
}

enum ScheduleMode { days, weekly }

enum Moment { morning, noon, evening, anytime }

enum DayStatus {
  /// Expected that day: counts for streaks and the perfect day.
  due,

  /// Weekly-target habit: judged per week, never on a single day.
  flexible,

  /// Inactive weekday.
  rest,
  paused,

  /// Before creation or after archiving.
  untracked,
}

/// Inclusive range of paused days.
final class Pause {
  const Pause(this.from, this.to);

  final Day from;
  final Day to;

  bool covers(Day d) => from <= d && d <= to;
}

final class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.goal,
    required this.step,
    required this.createdOn,
    this.unit,
    this.scheduleMode = ScheduleMode.days,
    this.activeDays = everyDay,
    this.timesPerWeek = 3,
    this.moment = Moment.anytime,
    this.reminders = const [],
    this.streakDangerAlert = true,
    this.archivedOn,
    this.pauses = const [],
  });

  static const everyDay = {1, 2, 3, 4, 5, 6, 7};

  final int id;
  final String name;
  final HabitType type;
  final HabitColor color;

  /// Phosphor icon name, e.g. `drop`.
  final String icon;

  /// Daily goal in base units: ml or pages (quantity), seconds (duration),
  /// lines (journal), 1 (yes/no, frequency).
  final double goal;

  /// Quick-action increment, in base units.
  final double step;

  /// Display unit, quantity habits only.
  final QuantityUnit? unit;
  final ScheduleMode scheduleMode;

  /// Active weekdays in DateTime numbering, for [ScheduleMode.days].
  final Set<int> activeDays;

  /// Target number of completed days per week, for [ScheduleMode.weekly].
  final int timesPerWeek;
  final Moment moment;

  /// Reminder times, in minutes after midnight.
  final List<int> reminders;
  final bool streakDangerAlert;
  final Day createdOn;
  final Day? archivedOn;
  final List<Pause> pauses;

  bool get isWeekly => scheduleMode == ScheduleMode.weekly;

  double progress(double value) => (value / goal).clamp(0, 1).toDouble();

  bool isCompleted(double value) => value >= goal;

  DayStatus statusOn(Day d) {
    if (d < createdOn || (archivedOn != null && d >= archivedOn!)) {
      return DayStatus.untracked;
    }
    if (pauses.any((p) => p.covers(d))) return DayStatus.paused;
    if (isWeekly) return DayStatus.flexible;
    return activeDays.contains(d.weekday) ? DayStatus.due : DayStatus.rest;
  }
}

/// What was logged for one habit on one logical day.
final class HabitEntry {
  const HabitEntry({
    required this.habitId,
    required this.day,
    required this.value,
    this.note,
    this.mood,
  });

  final int habitId;
  final Day day;

  /// In the habit's base units.
  final double value;

  /// Journal text.
  final String? note;

  /// Journal mood, 0 (bad) to 3 (great).
  final int? mood;
}
