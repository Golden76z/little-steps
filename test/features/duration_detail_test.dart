import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/app.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/notifications/reminder_scheduler.dart';
import 'package:little_steps/core/time/today_provider.dart';

import '../helpers.dart';

final today = Day(2026, 10, 20);

/// Moved forward by the tests to let the timer run.
late DateTime now;
late HabitRepository repo;
late int habitId;

/// The app in French on a clock the test drives, the Méditer habit
/// (5 min every morning) already created, its detail screen open.
Future<void> openDetail(
  WidgetTester tester,
  AppDatabase db, {
  double logged = 0,
  bool viaPill = false,
}) async {
  now = testNow;
  repo = HabitRepository(db);
  await tester.runAsync(() async {
    habitId = await repo.createHabit(
      Habit(
        id: 0,
        name: 'Méditer',
        type: HabitType.duration,
        color: HabitColor.lilac,
        icon: 'lotus',
        goal: 300,
        step: 300,
        moment: Moment.morning,
        createdOn: today.addDays(-10),
      ),
    );
    if (logged > 0) {
      await repo.setEntry(
        HabitEntry(habitId: habitId, day: today, value: logged),
      );
    }
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        reminderSchedulerProvider.overrideWithValue(FakeScheduler()),
      ],
      child: const LittleStepsApp(locale: Locale('fr')),
    ),
  );
  await settle(tester);
  await tester.tap(
    viaPill ? find.text('Méditer') : find.bySemanticsLabel('Méditer, ouvrir'),
  );
  await settle(tester);
}

Future<double?> todayValue(WidgetTester tester) async {
  final entries = await tester.runAsync(() => repo.watchEntries().first);
  return entries!.where((e) => e.day == today).firstOrNull?.value;
}

/// Advances the clock and lets the 1 s refresh run.
Future<void> wait(WidgetTester tester, Duration d) async {
  await tester.pump();
  now = now.add(d);
  await tester.pump(const Duration(seconds: 1));
  await settle(tester);
}

void main() {
  testApp('header shows goal and schedule; a preset sets the goal', (
    tester,
    db,
  ) async {
    await openDetail(tester, db);
    expect(find.text('5 min · chaque matin'), findsOneWidget);
    await tester.tap(find.text('15 min'));
    await settle(tester);
    final habit = await tester.runAsync(() => repo.watchHabits().first);
    expect(habit!.single.goal, 900);
    expect(find.text('15 min · chaque matin'), findsOneWidget);
    expect(find.text('15:00'), findsOneWidget);
  });

  testApp('“already done” logs the goal', (tester, db) async {
    await openDetail(tester, db, logged: 60);
    expect(find.text('04:00'), findsOneWidget);
    await tester.tap(find.text('Déjà fait, noter 5 min'));
    await settle(tester);
    expect(await todayValue(tester), 300);
    expect(find.text('Séance terminée !'), findsOneWidget);
    expect(find.text('5 min au total'), findsOneWidget);
  });

  testApp('play runs from the logged time; pause writes it', (
    tester,
    db,
  ) async {
    await openDetail(tester, db, logged: 60);
    expect(find.text('sur 05:00'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Démarrer'));
    await wait(tester, const Duration(minutes: 2));
    expect(find.text('02:00'), findsOneWidget);
    expect(find.text('En cours…'), findsOneWidget);
    expect(find.bySemanticsLabel('3 minutes sur 5'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Mettre en pause'));
    await settle(tester);
    expect(await todayValue(tester), 180);
    expect(find.text('sur 05:00'), findsOneWidget);
  });

  testApp('the run stops at the goal and logs it', (tester, db) async {
    await openDetail(tester, db);
    await tester.tap(find.bySemanticsLabel('Démarrer'));
    await wait(tester, const Duration(minutes: 7));
    expect(find.text('Séance terminée !'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(await todayValue(tester), 300);
  });

  testApp('restart clears today; finish logs the elapsed time', (
    tester,
    db,
  ) async {
    await openDetail(tester, db, logged: 120);
    await tester.tap(find.bySemanticsLabel('Recommencer'));
    await settle(tester);
    expect(await todayValue(tester), isNull);
    expect(find.text('05:00'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Démarrer'));
    await wait(tester, const Duration(seconds: 90));
    await tester.tap(find.bySemanticsLabel('Terminer la séance'));
    await settle(tester);
    expect(await todayValue(tester), 90);
    expect(find.text('Séance terminée !'), findsOneWidget);
  });

  testApp('tapping the pill opens the detail with the timer running', (
    tester,
    db,
  ) async {
    await openDetail(tester, db, viaPill: true);
    expect(find.text('En cours…'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Mettre en pause'));
    await settle(tester);
  });

  testApp('meets tap-target and label guidelines', (tester, db) async {
    final handle = tester.ensureSemantics();
    await openDetail(tester, db);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testApp('holds with 2x system text', (tester, db) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openDetail(tester, db, logged: 200);
    expect(tester.takeException(), isNull);
  });
}
