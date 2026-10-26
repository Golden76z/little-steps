import 'package:drift/drift.dart';

import '../domain/day.dart';
import '../domain/habit.dart';
import 'app_database.dart';
import 'backup.dart';

class HabitRepository {
  HabitRepository(this._db);

  final AppDatabase _db;

  /// Habits in the user's order, with their pauses. Archived ones are needed
  /// to judge past days (streaks, XP), not for the Today list.
  Stream<List<Habit>> watchHabits({bool includeArchived = false}) {
    final query = _db.select(_db.habits).join([
      leftOuterJoin(_db.pauses, _db.pauses.habitId.equalsExp(_db.habits.id)),
    ]);
    if (!includeArchived) query.where(_db.habits.archivedOn.isNull());
    query.orderBy([
      OrderingTerm.asc(_db.habits.position),
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

  /// Inserts [habit] (its id is ignored) last and returns the new id.
  Future<int> createHabit(Habit habit) => _db.transaction(() async {
    final max = _db.habits.position.max();
    final last = await (_db.selectOnly(
      _db.habits,
    )..addColumns([max])).map((r) => r.read(max)).getSingle();
    return _db
        .into(_db.habits)
        .insert(
          HabitsCompanion.insert(
            position: Value((last ?? -1) + 1),
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
  });

  /// Puts the habits [ids] in this order.
  Future<void> reorder(List<int> ids) => _db.batch((b) {
    for (final (i, id) in ids.indexed) {
      b.update(
        _db.habits,
        HabitsCompanion(position: Value(i)),
        where: (h) => h.id.equals(id),
      );
    }
  });

  /// Rewrites a habit's settings; its entries, pauses and dates stay.
  Future<void> updateHabit(Habit h) =>
      (_db.update(_db.habits)..where((r) => r.id.equals(h.id))).write(
        HabitsCompanion(
          name: Value(h.name),
          color: Value(h.color),
          icon: Value(h.icon),
          goal: Value(h.goal),
          step: Value(h.step),
          unit: Value(h.unit),
          scheduleMode: Value(h.scheduleMode),
          activeDays: Value(h.activeDays),
          timesPerWeek: Value(h.timesPerWeek),
          moment: Value(h.moment),
          reminders: Value(h.reminders),
          streakDangerAlert: Value(h.streakDangerAlert),
        ),
      );

  Future<void> archiveHabit(int id, Day on) =>
      (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(archivedOn: Value(on)),
      );

  Future<void> unarchiveHabit(int id) =>
      (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
        const HabitsCompanion(archivedOn: Value(null)),
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

  /// Lifts the habit's pause from [today]: one under way ends yesterday,
  /// planned ones are dropped, past paused days stay paused.
  Future<void> resumeHabit(int id, Day today) {
    final t = const DayConverter().toSql(today);
    return _db.transaction(() async {
      await (_db.update(_db.pauses)..where(
            (p) =>
                p.habitId.equals(id) &
                p.fromDay.isSmallerThanValue(t) &
                p.toDay.isBiggerOrEqualValue(t),
          ))
          .write(PausesCompanion(toDay: Value(today.addDays(-1))));
      await (_db.delete(_db.pauses)..where(
            (p) => p.habitId.equals(id) & p.fromDay.isBiggerOrEqualValue(t),
          ))
          .go();
    });
  }

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

  Future<String?> getSetting(String key) async => (await (_db.select(
    _db.settings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Stream<String?> watchSetting(String key) => (_db.select(
    _db.settings,
  )..where((s) => s.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  Future<void> setSetting(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  /// Every row of every table, in key order.
  Future<Backup> readBackup() => _db.transaction(
    () async => Backup(
      habits: await (_db.select(
        _db.habits,
      )..orderBy([(h) => OrderingTerm.asc(h.id)])).get(),
      entries:
          await (_db.select(_db.entries)..orderBy([
                (e) => OrderingTerm.asc(e.habitId),
                (e) => OrderingTerm.asc(e.day),
              ]))
              .get(),
      pauses: await (_db.select(
        _db.pauses,
      )..orderBy([(p) => OrderingTerm.asc(p.id)])).get(),
      jokers: await (_db.select(
        _db.jokerDays,
      )..orderBy([(j) => OrderingTerm.asc(j.day)])).get(),
      settings: await (_db.select(
        _db.settings,
      )..orderBy([(s) => OrderingTerm.asc(s.key)])).get(),
    ),
  );

  /// Replaces all the data with [b], all or nothing.
  Future<void> restore(Backup b) => _db.transaction(() async {
    for (final table in _db.allTables) {
      await _db.delete(table).go();
    }
    await _db.batch(
      (batch) => batch
        ..insertAll(_db.habits, b.habits)
        ..insertAll(_db.entries, b.entries)
        ..insertAll(_db.pauses, b.pauses)
        ..insertAll(_db.jokerDays, b.jokers)
        ..insertAll(_db.settings, b.settings),
    );
  });

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
