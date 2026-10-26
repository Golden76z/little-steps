// The real app on a device: real file database, plugins, sounds and haptics.
// Run with `flutter test integration_test -d <device>` (see docs/testing.md).
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:little_steps/app.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/notifications/reminder_scheduler.dart';
import 'package:little_steps/core/time/today_provider.dart';

/// Its own file, so a run never touches the real 'little_steps' database.
AppDatabase openDb() => AppDatabase(driftDatabase(name: 'little_steps_it'));

/// The database of the running app, replaced by a restart.
late AppDatabase db;

/// Tuesday 20 October 2026, 10 am; moved forward by the timer test.
late DateTime now;
final today = Day(2026, 10, 20);

/// No notification is scheduled, so no permission dialog shows up.
class NoReminders implements ReminderScheduler {
  @override
  Future<void> replaceAll(
    List<ScheduledNotification> notifications, {
    required String channelName,
    required String channelDescription,
  }) async {}
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        reminderSchedulerProvider.overrideWithValue(NoReminders()),
      ],
      child: const LittleStepsApp(locale: Locale('fr')),
    ),
  );
  await settle(tester);
}

/// Unmounts the app; drift's short timer on cancelled queries runs out first.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}

/// Lets the database write and its streams emit, then settles the UI.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await settle(tester);
}

/// Today's logged value of the only habit, null when nothing is logged.
Future<double?> todayValue(WidgetTester tester) async {
  final entries = await tester.runAsync(
    () => HabitRepository(db).watchEntries().first,
  );
  return entries!.where((e) => e.day == today).firstOrNull?.value;
}

/// testWidgets on an emptied file database, the app closed at the end.
void testDevice(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    now = DateTime(2026, 10, 20, 10);
    db = openDb();
    await tester.runAsync(() async {
      for (final t in db.allTables) {
        await db.delete(t).go();
      }
    });
    await body(tester);
    await unmount(tester);
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testDevice('create a habit in 3 steps, tap, undo, then hold to complete', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Ta journée est toute vide'), findsOneWidget);

    await tapText(tester, 'Créer ma première habitude');
    expect(find.text('1/3'), findsOneWidget);
    await tapText(tester, 'Boire de l’eau');
    await tapText(tester, 'Continuer · Boire de l’eau');
    expect(find.text('2/3'), findsOneWidget);
    await tapText(tester, 'Continuer');
    expect(find.text('Quand ?'), findsOneWidget);
    await tapText(tester, 'Créer l’habitude');
    expect(find.text('Boire de l’eau'), findsOneWidget);
    expect(find.text('0 / 2 L'), findsOneWidget);

    await tapText(tester, 'Boire de l’eau');
    expect(find.text('0,25 / 2 L'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Boire de l’eau, 13')),
      findsOneWidget,
    );
    expect(await todayValue(tester), 250);
    await tapText(tester, 'Annuler');
    expect(find.text('0 / 2 L'), findsOneWidget);
    expect(await todayValue(tester) ?? 0, 0);

    final hold = await tester.startGesture(
      tester.getCenter(find.text('Boire de l’eau')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await hold.up();
    await settle(tester);
    expect(await todayValue(tester), 2000);
    expect(
      find.bySemanticsLabel(RegExp('^Boire de l’eau, 100')),
      findsOneWidget,
    );
  });

  testDevice('a timed session is saved and survives a restart', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Méditer 5 min');
    await tapText(tester, 'Continuer');
    await tapText(tester, 'Créer l’habitude');
    // Tapping a duration pill opens its detail with the session running.
    await tapText(tester, 'Méditer');
    expect(find.text('En cours…'), findsOneWidget);
    now = now.add(const Duration(minutes: 2));
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(find.bySemanticsLabel('2 minutes sur 5'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Mettre en pause'));
    await settle(tester);
    expect(await todayValue(tester), 120);

    // Restart: a new app on a new connection to the same file.
    await unmount(tester);
    db = openDb();
    await pumpApp(tester);
    expect(find.text('Ta journée est toute vide'), findsNothing);
    expect(find.text('Méditer'), findsOneWidget);
    expect(await todayValue(tester), 120);
  });
}
