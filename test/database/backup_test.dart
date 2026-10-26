import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/backup.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

/// Two habits (one archived, one paused), entries, a joker, settings.
Future<void> seed(HabitRepository repo) async {
  final day = Day(2026, 10, 1);
  final water = await repo.createHabit(
    Habit(
      id: 0,
      name: 'Boire de l’eau',
      type: HabitType.quantity,
      color: HabitColor.sky,
      icon: 'drop',
      goal: 2000,
      step: 250,
      unit: QuantityUnit.liters,
      activeDays: const {1, 3, 5},
      moment: Moment.morning,
      reminders: const [480, 1290],
      streakDangerAlert: false,
      createdOn: day,
    ),
  );
  final journal = await repo.createHabit(
    Habit(
      id: 0,
      name: 'Journal',
      type: HabitType.journal,
      color: HabitColor.lilac,
      icon: 'book',
      goal: 3,
      step: 1,
      scheduleMode: ScheduleMode.weekly,
      timesPerWeek: 4,
      createdOn: day,
    ),
  );
  await repo.reorder([journal, water]);
  await repo.archiveHabit(journal, day.addDays(10));
  await repo.pauseHabit(water, Pause(day.addDays(2), day.addDays(4)));
  await repo.setEntry(HabitEntry(habitId: water, day: day, value: 1500));
  await repo.setEntry(
    HabitEntry(habitId: journal, day: day, value: 3, note: 'Bien', mood: 2),
  );
  await repo.useJoker(day.addDays(1));
  await repo.setSetting('firstName', 'Damien');
  await repo.setSetting('rolloverHour', '4');
}

void main() {
  late AppDatabase db;
  late HabitRepository repo;
  final at = DateTime.utc(2026, 10, 25, 9);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HabitRepository(db);
  });
  tearDown(() => db.close());

  Future<String> export() async => encodeBackup(await repo.readBackup(), at);

  test('the export is a versioned document of every table', () async {
    await seed(repo);
    final json = jsonDecode(await export()) as Map<String, dynamic>;
    expect(json['format'], 'little-steps');
    expect(json['version'], 1);
    expect(json['exportedAt'], '2026-10-25T09:00:00.000Z');
    expect(json['habits'], hasLength(2));
    expect(json['entries'], hasLength(2));
    expect(json['pauses'], hasLength(1));
    expect(json['jokers'], ['2026-10-02']);
    expect(json['settings'], {'firstName': 'Damien', 'rolloverHour': '4'});
    final water = (json['habits'] as List).first as Map<String, dynamic>;
    expect(water['type'], 'quantity');
    expect(water['createdOn'], '2026-10-01');
    expect(water['activeDays'], [1, 3, 5]);
  });

  test('importing an export restores the same data', () async {
    await seed(repo);
    final exported = await export();
    final backup = decodeBackup(exported);
    // Data from after the export is replaced, not merged.
    await repo.createHabit(
      Habit(
        id: 0,
        name: 'Plus tard',
        type: HabitType.yesNo,
        color: HabitColor.mint,
        icon: 'drop',
        goal: 1,
        step: 1,
        createdOn: Day(2026, 10, 20),
      ),
    );
    await repo.setSetting('soundsEnabled', '0');
    await repo.restore(backup);
    expect(await export(), exported);
    expect(
      (await repo.watchHabits(includeArchived: true).first).map((h) => h.name),
      ['Journal', 'Boire de l’eau'],
    );
  });

  test('a habit created after an import gets a fresh id, last', () async {
    await seed(repo);
    await repo.restore(decodeBackup(await export()));
    final id = await repo.createHabit(
      Habit(
        id: 0,
        name: 'Neuve',
        type: HabitType.yesNo,
        color: HabitColor.mint,
        icon: 'drop',
        goal: 1,
        step: 1,
        createdOn: Day(2026, 10, 20),
      ),
    );
    expect(id, greaterThan(2));
    expect((await repo.watchHabits().first).last.name, 'Neuve');
  });

  group('an invalid file is refused', () {
    late Map<String, dynamic> valid;
    setUp(() async {
      await seed(repo);
      valid = jsonDecode(await export()) as Map<String, dynamic>;
    });

    Map<String, dynamic> copy() =>
        jsonDecode(jsonEncode(valid)) as Map<String, dynamic>;
    Map<String, dynamic> firstHabit(Map<String, dynamic> j) =>
        (j['habits'] as List).first as Map<String, dynamic>;

    final cases = <String, String Function(Map<String, dynamic> Function())>{
      'not JSON': (_) => 'hello',
      'not an object': (_) => '[1, 2]',
      'another format': (c) => jsonEncode(c()..['format'] = 'other'),
      'a newer version': (c) => jsonEncode(c()..['version'] = 2),
      'a missing table': (c) => jsonEncode(c()..remove('entries')),
      'a missing field': (c) {
        final j = c();
        firstHabit(j).remove('name');
        return jsonEncode(j);
      },
      'an unknown enum name': (c) {
        final j = c();
        firstHabit(j)['type'] = 'teleport';
        return jsonEncode(j);
      },
      'a bad date': (c) {
        final j = c();
        firstHabit(j)['createdOn'] = 'yesterday';
        return jsonEncode(j);
      },
      'an entry of no habit': (c) {
        final j = c();
        ((j['entries'] as List).first as Map)['habitId'] = 99;
        return jsonEncode(j);
      },
    };
    for (final MapEntry(key: label, value: build) in cases.entries) {
      test(label, () {
        expect(() => decodeBackup(build(copy)), throwsFormatException);
      });
    }
  });

  test('a failing restore leaves the data untouched', () async {
    await seed(repo);
    final before = await export();
    final backup = decodeBackup(before);
    // Same habit and day twice: the second insert fails mid-transaction.
    final broken = Backup(
      habits: backup.habits,
      entries: [...backup.entries, backup.entries.first],
      pauses: backup.pauses,
      jokers: backup.jokers,
      settings: backup.settings,
    );
    await expectLater(repo.restore(broken), throwsA(anything));
    expect(await export(), before);
  });
}
