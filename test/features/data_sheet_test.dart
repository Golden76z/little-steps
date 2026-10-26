import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/backup.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/feedback/feedback.dart';
import 'package:little_steps/core/theme/motion.dart';
import 'package:little_steps/features/habit_detail/session_timer.dart';
import 'package:little_steps/features/profile/data_sheet.dart';

import '../helpers.dart';
import 'profile_screen_test.dart' show openProfile, yesNo;

/// A backup holding one habit, Méditer (20:00 reminder), from another phone.
Future<String> otherPhoneBackup(
  WidgetTester tester, {
  bool done = false,
}) async => (await tester.runAsync(() async {
  final other = AppDatabase(NativeDatabase.memory());
  final repo = HabitRepository(other);
  final id = await repo.createHabit(
    yesNo('Méditer', Day(2026, 10, 1), [20 * 60]),
  );
  if (done) {
    for (var d = 1; d <= 20; d++) {
      await repo.setEntry(
        HabitEntry(habitId: id, day: Day(2026, 10, d), value: 1),
      );
    }
  }
  final json = encodeBackup(await repo.readBackup(), testNow);
  await other.close();
  return json;
}))!;

Future<List<String>> habitNames(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => HabitRepository(db).watchHabits().first))!
        .map((h) => h.name)
        .toList();

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('Sauvegarder mes données'));
    await tester.pumpAndSettle();
  }

  testApp('exporting shares a dated JSON file of everything', (
    tester,
    db,
  ) async {
    final shared = <(String, String)>[];
    await openProfile(
      tester,
      db,
      overrides: [
        shareFileProvider.overrideWithValue(
          (name, contents) async => shared.add((name, contents)),
        ),
      ],
    );
    await openSheet(tester);
    expect(find.text('L’export CSV reste réservé à Premium.'), findsNothing);
    await tester.tap(find.text('Exporter (JSON)'));
    await settle(tester);
    final (name, contents) = shared.single;
    expect(name, 'little-steps-2026-10-20.json');
    final json = jsonDecode(contents) as Map<String, dynamic>;
    expect(json['format'], 'little-steps');
    expect(json['habits'], hasLength(2));
    expect(find.text('Exporter (JSON)'), findsNothing);
  });

  testApp('importing a backup replaces the data after confirming', (
    tester,
    db,
  ) async {
    late String backup;
    await openProfile(
      tester,
      db,
      overrides: [pickFileProvider.overrideWithValue(() async => backup)],
    );
    backup = await otherPhoneBackup(tester);
    await openSheet(tester);
    await tester.tap(find.text('Importer'));
    await settle(tester);
    expect(find.text('Remplacer toutes tes données ?'), findsOneWidget);
    await tester.tap(find.text('Remplacer'));
    await settle(tester);
    expect(await habitNames(tester, db), ['Méditer']);
    expect(find.text('Données importées'), findsOneWidget);
    // The reminders follow the imported habits.
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(scheduler.scheduled.map((n) => n.title), contains('Méditer'));
  });

  testApp('an import celebrates nothing the file already holds', (
    tester,
    db,
  ) async {
    late String backup;
    await openProfile(
      tester,
      db,
      overrides: [pickFileProvider.overrideWithValue(() async => backup)],
    );
    // Twenty perfect days: badges, a level, today's perfect day.
    backup = await otherPhoneBackup(tester, done: true);
    await openSheet(tester);
    await tester.tap(find.text('Importer'));
    await settle(tester);
    await tester.tap(find.text('Remplacer'));
    await settle(tester);
    await tester.pump(Motion.flight);
    await settle(tester);
    expect(await habitNames(tester, db), ['Méditer']);
    expect(sounds.played, isNot(contains(Sound.celebrate)));
  });

  testApp('an import drops the sessions of the replaced habits', (
    tester,
    db,
  ) async {
    late String backup;
    await openProfile(
      tester,
      db,
      overrides: [pickFileProvider.overrideWithValue(() async => backup)],
    );
    backup = await otherPhoneBackup(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.text('Sauvegarder mes données')),
    );
    container.listen(sessionTimersProvider, (_, _) {});
    final lire = container.read(habitsProvider).value!.first;
    // A 10 min run on Lire's id (already done as a check today).
    final habit = Habit(
      id: lire.id,
      name: lire.name,
      type: HabitType.duration,
      color: lire.color,
      icon: lire.icon,
      goal: 600,
      step: 60,
      createdOn: lire.createdOn,
    );
    container.read(sessionTimersProvider.notifier).start(habit);
    expect(container.read(sessionTimersProvider), isNotEmpty);
    await openSheet(tester);
    await tester.tap(find.text('Importer'));
    await settle(tester);
    await tester.tap(find.text('Remplacer'));
    await settle(tester);
    expect(container.read(sessionTimersProvider), isEmpty);
  });

  testApp('cancelling the confirmation keeps the data', (tester, db) async {
    late String backup;
    await openProfile(
      tester,
      db,
      overrides: [pickFileProvider.overrideWithValue(() async => backup)],
    );
    backup = await otherPhoneBackup(tester);
    await openSheet(tester);
    await tester.tap(find.text('Importer'));
    await settle(tester);
    await tester.tap(find.text('Annuler'));
    await settle(tester);
    expect(await habitNames(tester, db), ['Lire', 'Sport']);
  });

  testApp('an invalid file shows an error and changes nothing', (
    tester,
    db,
  ) async {
    await openProfile(
      tester,
      db,
      overrides: [
        pickFileProvider.overrideWithValue(() async => '{"format": "x"}'),
      ],
    );
    await openSheet(tester);
    await tester.tap(find.text('Importer'));
    await settle(tester);
    expect(find.text('Remplacer toutes tes données ?'), findsNothing);
    expect(
      find.text('Ce fichier n’est pas une sauvegarde Little Steps.'),
      findsOneWidget,
    );
    expect(await habitNames(tester, db), ['Lire', 'Sport']);
  });
}
