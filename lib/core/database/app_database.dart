import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/day.dart';
import '../domain/habit.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

// Enums are stored by name (textEnum) so reordering them never corrupts data.

@DataClassName('HabitRow')
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<HabitType>()();
  TextColumn get color => textEnum<HabitColor>()();
  TextColumn get icon => text()();
  RealColumn get goal => real()();
  RealColumn get step => real()();
  TextColumn get unit => textEnum<QuantityUnit>().nullable()();
  TextColumn get scheduleMode => textEnum<ScheduleMode>()();
  IntColumn get activeDays => integer().map(const WeekdaysConverter())();
  IntColumn get timesPerWeek => integer()();
  TextColumn get moment => textEnum<Moment>()();
  TextColumn get reminders => text().map(const MinutesConverter())();
  BoolColumn get streakDangerAlert => boolean()();
  IntColumn get createdOn => integer().map(const DayConverter())();
  IntColumn get archivedOn => integer().map(const DayConverter()).nullable()();

  /// Place in the user's order; ties fall back to the id.
  IntColumn get position => integer().withDefault(const Constant(0))();
}

@DataClassName('PauseRow')
class Pauses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  IntColumn get fromDay => integer().map(const DayConverter())();
  IntColumn get toDay => integer().map(const DayConverter())();
}

@DataClassName('EntryRow')
class Entries extends Table {
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  IntColumn get day => integer().map(const DayConverter())();
  RealColumn get value => real()();
  TextColumn get note => text().nullable()();
  IntColumn get mood => integer().nullable()();

  @override
  Set<Column> get primaryKey => {habitId, day};
}

@DataClassName('JokerDayRow')
class JokerDays extends Table {
  IntColumn get day => integer().map(const DayConverter())();

  @override
  Set<Column> get primaryKey => {day};
}

/// Small app preferences, as text by key.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class DayConverter extends TypeConverter<Day, int> {
  const DayConverter();

  @override
  Day fromSql(int fromDb) => Day.fromIndex(fromDb);

  @override
  int toSql(Day value) => value.index;
}

/// Weekdays (1–7) as a bitmask, bit 0 = Monday.
class WeekdaysConverter extends TypeConverter<Set<int>, int> {
  const WeekdaysConverter();

  @override
  Set<int> fromSql(int fromDb) => {
    for (var d = 1; d <= 7; d++)
      if (fromDb & (1 << (d - 1)) != 0) d,
  };

  @override
  int toSql(Set<int> value) =>
      value.fold(0, (mask, d) => mask | (1 << (d - 1)));
}

/// Minutes after midnight as `480,1290`.
class MinutesConverter extends TypeConverter<List<int>, String> {
  const MinutesConverter();

  @override
  List<int> fromSql(String fromDb) =>
      fromDb.isEmpty ? const [] : fromDb.split(',').map(int.parse).toList();

  @override
  String toSql(List<int> value) => value.join(',');
}

@DriftDatabase(tables: [Habits, Pauses, Entries, JokerDays, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'little_steps'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Each version bump: `dart run drift_dev make-migrations`, then add a step.
    onUpgrade: stepByStep(
      from1To2: (m, schema) => m.createTable(schema.settings),
      from2To3: (m, schema) async {
        await m.addColumn(schema.habits, schema.habits.position);
        await customStatement('UPDATE habits SET position = id');
      },
    ),
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
