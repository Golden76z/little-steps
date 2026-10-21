import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

import '../helpers.dart';

final today = Day(2026, 10, 20);

final screens = Habit(
  id: 0,
  name: 'Pas d’écran au lit',
  type: HabitType.yesNo,
  color: HabitColor.lemon,
  icon: 'moon',
  goal: 1,
  step: 1,
  moment: Moment.evening,
  reminders: const [22 * 60 + 30],
  createdOn: Day(2026, 9, 1),
);

Future<void> open(
  WidgetTester tester,
  AppDatabase db, {
  List<int> done = const [],
  Set<int> jokers = const {},
}) async {
  final repo = HabitRepository(db);
  await tester.runAsync(() async {
    final id = await repo.createHabit(screens);
    for (final o in done) {
      await repo.setEntry(
        HabitEntry(habitId: id, day: today.addDays(o), value: 1),
      );
    }
    for (final o in jokers) {
      await repo.useJoker(today.addDays(o));
    }
  });
  await pumpApp(tester, db, locale: 'fr');
  await tester.tap(find.bySemanticsLabel('Pas d’écran au lit, ouvrir'));
  await tester.pumpAndSettle();
}

void main() {
  testApp('header, streak in evenings and the record', (tester, db) async {
    await open(tester, db, done: [-3, -2, -1, -6]);
    expect(find.text('dès 22:30 · chaque soir'), findsOneWidget);
    expect(find.text('Série en cours'), findsOneWidget);
    expect(find.text('soirs de suite'), findsOneWidget);
    expect(find.text('record : 3 · rappel à 22:30'), findsOneWidget);
  });

  testApp('the big button checks and unchecks today', (tester, db) async {
    await open(tester, db);
    await tester.tap(find.text('Je l’ai fait'));
    await settle(tester);
    expect(find.text('C’est fait !'), findsOneWidget);
    final entries = (await tester.runAsync(
      () => HabitRepository(db).watchEntries().first,
    ))!;
    expect(entries.single.day, today);
    await tester.tap(find.text('C’est fait !'));
    await settle(tester);
    expect(find.text('Je l’ai fait'), findsOneWidget);
  });

  testApp('month count and legend', (tester, db) async {
    await open(tester, db, done: [-1, -2], jokers: {-3});
    expect(find.text('2 soirs sur 20'), findsOneWidget);
    for (final l in ['Fait', 'Joker', 'Raté']) {
      expect(find.text(l), findsOneWidget);
    }
  });

  testApp('the joker tip shows the reserve', (tester, db) async {
    await open(tester, db);
    expect(
      find.textContaining('Un soir raté', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Il t’en reste 0', findRichText: true),
      findsOneWidget,
    );
  });

  testApp('the year view lists the months', (tester, db) async {
    await open(tester, db, done: [-1]);
    await tester.tap(find.text('Année'));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsOneWidget);
  });

  testApp('meets tap-target guidelines and holds 2x text', (tester, db) async {
    final handle = tester.ensureSemantics();
    await open(tester, db, done: [-1]);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    handle.dispose();
  });
}
