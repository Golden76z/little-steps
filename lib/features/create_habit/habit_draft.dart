import 'package:flutter/foundation.dart';

import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';

/// Premium is not sold yet: v1 is entirely free, its entry points (banner,
/// theme row, CSV note, habit limit) stay hidden until billing exists.
const premiumOffered = false;

const freeHabitLimit = 5;

/// Free plan: [freeHabitLimit] active habits; beyond, Premium.
bool canCreateHabit(int activeHabits) =>
    !premiumOffered || activeHabits < freeHabitLimit;

/// Popular habits of P1 (and the E1 ideas), with their settings.
enum Preset { water, read, draw, run, vitamins, gratitude, meditate }

/// Default reminder for a moment of the day, in minutes after midnight.
List<int> defaultReminders(Moment m) => switch (m) {
  Moment.morning => const [8 * 60],
  Moment.noon => const [12 * 60],
  Moment.evening => const [20 * 60],
  Moment.anytime => const [],
};

/// The habit being created or edited across P1–P3.
final class HabitDraft {
  const HabitDraft({
    required this.type,
    required this.color,
    required this.icon,
    required this.goal,
    required this.step,
    this.name = '',
    this.unit,
    this.scheduleMode = ScheduleMode.days,
    this.activeDays = Habit.everyDay,
    this.timesPerWeek = 3,
    this.moment = Moment.anytime,
    this.reminders = const [],
    this.streakDangerAlert = true,
    this.source,
  });

  factory HabitDraft.forType(HabitType type) => switch (type) {
    HabitType.quantity => const HabitDraft(
      type: HabitType.quantity,
      color: HabitColor.sky,
      icon: 'hash',
      unit: QuantityUnit.glasses,
      goal: 2000,
      step: 250,
    ),
    HabitType.duration => const HabitDraft(
      type: HabitType.duration,
      color: HabitColor.lilac,
      icon: 'timer',
      goal: 600,
      step: 300,
    ),
    HabitType.yesNo => const HabitDraft(
      type: HabitType.yesNo,
      color: HabitColor.lemon,
      icon: 'checkCircle',
      goal: 1,
      step: 1,
    ),
    HabitType.journal => const HabitDraft(
      type: HabitType.journal,
      color: HabitColor.peach,
      icon: 'note',
      goal: 3,
      step: 1,
    ),
    HabitType.frequency => const HabitDraft(
      type: HabitType.frequency,
      color: HabitColor.pink,
      icon: 'calendarCheck',
      goal: 1,
      step: 1,
      scheduleMode: ScheduleMode.weekly,
    ),
  };

  factory HabitDraft.fromPreset(Preset p, {required String name}) {
    HabitDraft of(HabitType t) => HabitDraft.forType(t).copyWith(name: name);
    return switch (p) {
      Preset.water => of(HabitType.quantity).copyWith(
        unit: QuantityUnit.liters,
        goal: 2000,
        step: 250,
        icon: 'drop',
        color: HabitColor.sky,
      ),
      Preset.read => of(HabitType.quantity).copyWith(
        unit: QuantityUnit.pages,
        goal: 20,
        step: 4,
        icon: 'book',
        color: HabitColor.mint,
      ),
      Preset.draw => of(
        HabitType.duration,
      ).copyWith(goal: 1800, icon: 'brush', color: HabitColor.lilac),
      Preset.run => of(
        HabitType.frequency,
      ).copyWith(icon: 'run', color: HabitColor.pink, timesPerWeek: 3),
      Preset.vitamins =>
        of(HabitType.yesNo)
            .copyWith(icon: 'pill', color: HabitColor.lemon)
            .withMoment(Moment.morning),
      Preset.gratitude => of(
        HabitType.journal,
      ).copyWith(icon: 'note', color: HabitColor.peach),
      Preset.meditate => of(
        HabitType.duration,
      ).copyWith(goal: 300, icon: 'timer', color: HabitColor.lilac),
    };
  }

  factory HabitDraft.fromHabit(Habit h) => HabitDraft(
    type: h.type,
    name: h.name,
    color: h.color,
    icon: h.icon,
    goal: h.goal,
    step: h.step,
    unit: h.unit,
    scheduleMode: h.scheduleMode,
    activeDays: h.activeDays,
    timesPerWeek: h.timesPerWeek,
    moment: h.moment,
    reminders: h.reminders,
    streakDangerAlert: h.streakDangerAlert,
    source: h,
  );

  final HabitType type;
  final String name;
  final HabitColor color;
  final String icon;
  final double goal;
  final double step;
  final QuantityUnit? unit;
  final ScheduleMode scheduleMode;
  final Set<int> activeDays;
  final int timesPerWeek;
  final Moment moment;
  final List<int> reminders;
  final bool streakDangerAlert;

  /// The habit being edited; null when creating.
  final Habit? source;

  bool get isEditing => source != null;

  bool get isWeekly => scheduleMode == ScheduleMode.weekly;

  bool get isValid => name.trim().isNotEmpty;

  HabitDraft copyWith({
    String? name,
    HabitColor? color,
    String? icon,
    double? goal,
    double? step,
    QuantityUnit? unit,
    int? timesPerWeek,
    Set<int>? activeDays,
    bool? streakDangerAlert,
  }) => HabitDraft(
    type: type,
    name: name ?? this.name,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    goal: goal ?? this.goal,
    step: step ?? this.step,
    unit: unit ?? this.unit,
    scheduleMode: scheduleMode,
    activeDays: activeDays ?? this.activeDays,
    timesPerWeek: timesPerWeek ?? this.timesPerWeek,
    moment: moment,
    reminders: reminders,
    streakDangerAlert: streakDangerAlert ?? this.streakDangerAlert,
    source: source,
  );

  HabitDraft _with({
    ScheduleMode? scheduleMode,
    Moment? moment,
    List<int>? reminders,
  }) => HabitDraft(
    type: type,
    name: name,
    color: color,
    icon: icon,
    goal: goal,
    step: step,
    unit: unit,
    scheduleMode: scheduleMode ?? this.scheduleMode,
    activeDays: activeDays,
    timesPerWeek: timesPerWeek,
    moment: moment ?? this.moment,
    reminders: reminders ?? this.reminders,
    streakDangerAlert: streakDangerAlert,
    source: source,
  );

  /// (increment, min, max) of the daily goal, in base units.
  (double, double, double) get _goalRange => switch (type) {
    HabitType.quantity => (unit!.goalStep, unit!.goalStep, double.infinity),
    HabitType.duration => (300, 300, 240 * 60),
    HabitType.journal => (1, 1, 5),
    HabitType.yesNo || HabitType.frequency => (0, 1, 1),
  };

  HabitDraft incGoal() {
    final (by, _, max) = _goalRange;
    return copyWith(goal: (goal + by).clamp(goal, max).toDouble());
  }

  HabitDraft decGoal() {
    final (by, min, _) = _goalRange;
    return copyWith(goal: (goal - by).clamp(min, goal).toDouble());
  }

  /// Within volumes the goal carries over (same ml); another family
  /// starts from that unit's defaults.
  HabitDraft withUnit(QuantityUnit u) {
    final keepGoal = unit != null && unit!.isVolume && u.isVolume;
    return copyWith(
      unit: u,
      goal: keepGoal ? goal : u.defaultGoal,
      step: u.stepPresets.first,
    );
  }

  /// Frequency habits are always counted per week.
  HabitDraft withScheduleMode(ScheduleMode m) => _with(
    scheduleMode: type == HabitType.frequency ? ScheduleMode.weekly : m,
  );

  /// Toggles a weekday, keeping at least one active.
  HabitDraft toggleDay(int weekday) {
    final days = {...activeDays};
    if (!days.remove(weekday)) days.add(weekday);
    return days.isEmpty ? this : copyWith(activeDays: days);
  }

  HabitDraft withTimesPerWeek(int n) => copyWith(timesPerWeek: n.clamp(1, 7));

  /// Changing the moment moves the default reminder, unless reminders were edited.
  HabitDraft withMoment(Moment m) {
    final untouched = listEquals(reminders, defaultReminders(moment));
    return _with(
      moment: m,
      reminders: untouched ? defaultReminders(m) : reminders,
    );
  }

  HabitDraft withReminderAdded(int minutes) =>
      _with(reminders: ({...reminders, minutes}.toList()..sort()));

  HabitDraft withReminderRemoved(int minutes) =>
      _with(reminders: [...reminders]..remove(minutes));

  Habit build(Day today) => Habit(
    id: source?.id ?? 0,
    name: name.trim(),
    type: type,
    color: color,
    icon: icon,
    goal: goal,
    step: step,
    unit: type == HabitType.quantity ? unit : null,
    scheduleMode: scheduleMode,
    activeDays: activeDays,
    timesPerWeek: timesPerWeek,
    moment: moment,
    reminders: reminders,
    streakDangerAlert: streakDangerAlert,
    createdOn: source?.createdOn ?? today,
    archivedOn: source?.archivedOn,
    pauses: source?.pauses ?? const [],
  );
}
