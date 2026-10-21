import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

/// Monday 19 October 2026.
final monday = Day(2026, 10, 19);

Habit habit({
  int id = 1,
  HabitType type = HabitType.yesNo,
  double goal = 1,
  double step = 1,
  QuantityUnit? unit,
  Moment moment = Moment.anytime,
  Set<int> activeDays = Habit.everyDay,
  ScheduleMode mode = ScheduleMode.days,
  int timesPerWeek = 3,
  Day? createdOn,
  Day? archivedOn,
  List<Pause> pauses = const [],
}) => Habit(
  id: id,
  name: 'Habit $id',
  type: type,
  color: HabitColor.sky,
  icon: 'drop',
  goal: goal,
  step: step,
  unit: unit,
  moment: moment,
  scheduleMode: mode,
  activeDays: activeDays,
  timesPerWeek: timesPerWeek,
  createdOn: createdOn ?? monday.addDays(-60),
  archivedOn: archivedOn,
  pauses: pauses,
);
