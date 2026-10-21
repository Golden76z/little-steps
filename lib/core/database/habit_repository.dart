import 'package:drift/drift.dart';

import '../domain/day.dart';
import '../domain/habit.dart';
import 'app_database.dart';

class HabitRepository {
  HabitRepository(this._db);

  final AppDatabase _db;

  /// Habits in creation order, with their pauses. Archived ones are needed
  /// to judge past days (streaks, XP), not for the Today list.
  Stream<List<Habit>> watchHabits({bool includeArchived = false}) {
    final query = _db.select(_db.habits).join([
      leftOuterJoin(_db.pauses, _db.pauses.habitId.equalsExp(_db.habits.id)),
    ]);
    if (!includeArchived) query.where(_db.habits.archivedOn.isNull());
    query.orderBy([
      OrderingTerm.asc(_db.habits.id),
      OrderingTerm.asc(_db.pauses.fromDay),
    ]);
    return query.watch().map((rows) {
      final habits = <int, HabitRow>{};
      final pauses = <int, List<Pause>>{};
      for (final r in rows) {
        final h = r.readTable(_db.habits);
        habits[h.id] = h;
        final list = pauses[h.id] ??= [];
        final p = r.readTableOrNull(_db.pauses);
        if (p != null) list.add(Pause(p.fromDay, p.toDay));
      }
      return [for (final h in habits.values) _toHabit(h, pauses[h.id]!)];
    });
  }

  /// Inserts [habit] (its id is ignored) and returns the new id.
  Future<int> createHabit(Habit habit) => _db
      .into(_db.habits)
      .insert(
        HabitsCompanion.insert(
          name: habit.name,
          type: habit.type,
          color: habit.color,
          icon: habit.icon,
          goal: habit.goal,
          step: habit.step,
          unit: Value(habit.unit),
          scheduleMode: habit.scheduleMode,
          activeDays: habit.activeDays,
          timesPerWeek: habit.timesPerWeek,
          moment: habit.moment,
          reminders: habit.reminders,
          streakDangerAlert: habit.streakDangerAlert,
          createdOn: habit.createdOn,
        ),
      );

  Future<void> archiveHabit(int id, Day on) =>
      (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(archivedOn: Value(on)),
      );

  /// Removes the habit and, by cascade, its entries and pauses.
  Future<void> deleteHabit(int id) =>
      (_db.delete(_db.habits)..where((h) => h.id.equals(id))).go();

  Future<void> pauseHabit(int id, Pause pause) => _db
      .into(_db.pauses)
      .insert(
        PausesCompanion.insert(
          habitId: id,
          fromDay: pause.from,
          toDay: pause.to,
        ),
      );

  Stream<List<HabitEntry>> watchEntries() {
    final query = _db.select(_db.entries)
      ..orderBy([(e) => OrderingTerm.asc(e.day)]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          HabitEntry(
            habitId: r.habitId,
            day: r.day,
            value: r.value,
            note: r.note,
            mood: r.mood,
          ),
      ],
    );
  }

  /// Writes the entry for its habit and day, replacing any previous one.
  Future<void> setEntry(HabitEntry e) => _db
      .into(_db.entries)
      .insertOnConflictUpdate(
        EntriesCompanion.insert(
          habitId: e.habitId,
          day: e.day,
          value: e.value,
          note: Value(e.note),
          mood: Value(e.mood),
        ),
      );

  Future<void> clearEntry(int habitId, Day day) => (_db.delete(
    _db.entries,
  )..where((e) => e.habitId.equals(habitId) & e.day.equalsValue(day))).go();

  /// Marks [day] as saved by a joker. Checking the balance is the caller's job.
  Future<void> useJoker(Day day) => _db
      .into(_db.jokerDays)
      .insert(
        JokerDaysCompanion(day: Value(day)),
        mode: InsertMode.insertOrIgnore,
      );

  Stream<Set<Day>> watchJokerDays() => _db
      .select(_db.jokerDays)
      .watch()
      .map((rows) => {for (final r in rows) r.day});

  Habit _toHabit(HabitRow r, List<Pause> pauses) => Habit(
    id: r.id,
    name: r.name,
    type: r.type,
    color: r.color,
    icon: r.icon,
    goal: r.goal,
    step: r.step,
    unit: r.unit,
    scheduleMode: r.scheduleMode,
    activeDays: r.activeDays,
    timesPerWeek: r.timesPerWeek,
    moment: r.moment,
    reminders: r.reminders,
    streakDangerAlert: r.streakDangerAlert,
    createdOn: r.createdOn,
    archivedOn: r.archivedOn,
    pauses: pauses,
  );
}
