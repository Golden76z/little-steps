import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

import '../helpers.dart';

/// Tuesday: the French week started yesterday, Monday 19 October.
final today = Day(2026, 10, 20);

Habit sport({int times = 3}) => Habit(
  id: 0,
  name: 'Sport',
  type: HabitType.frequency,
  color: HabitColor.pink,
  icon: 'barbell',
  goal: 1,
  step: 1,
  scheduleMode: ScheduleMode.weekly,
  timesPerWeek: times,
  createdOn: Day(2026, 8, 1),
);

/// Monday this week, three full weeks before it, then a week of two.
final history = [
  -1,
  for (final w in [1, 2, 3]) ...[-1 - 7 * w, -1 - 7 * w + 2, -1 - 7 * w + 4],
  -29,
  -27,
];

/// Creates Sport with a session on each offset from today, opens its detail.
Future<void> openDetail(
  WidgetTester tester,
  AppDatabase db, {
  List<int> sessions = const [],
  int times = 3,
}) async {
  final repo = HabitRepository(db);
  await tester.runAsync(() async {
    final id = await repo.createHabit(sport(times: times));
    for (final d in sessions) {
      await repo.setEntry(
        HabitEntry(habitId: id, day: today.addDays(d), value: 1),
      );
    }
  });
  await pumpApp(tester, db, locale: 'fr');
  await tester.tap(find.bySemanticsLabel('Sport, ouvrir'));
  await tester.pumpAndSettle();
}

Future<double> todayValue(WidgetTester tester, AppDatabase db) async {
  final entries = (await tester.runAsync(
    () => HabitRepository(db).watchEntries().first,
  ))!;
  return entries.where((e) => e.day == today).firstOrNull?.value ?? 0;
}

void main() {
  testApp('this week: sessions count and what is left until Sunday', (
    tester,
    db,
  ) async {
    await openDetail(tester, db, sessions: history);
    expect(find.text('3 fois par semaine'), findsOneWidget);
    expect(find.text('Cette semaine'), findsOneWidget);
    expect(find.text('1 / 3 séances'), findsOneWidget);
    expect(
      find.text('Encore 2 séances d’ici dimanche, il te reste 6 jours.'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Séances de la semaine, jour par jour'),
      findsOneWidget,
    );
  });

  testApp('8 weeks: goal kept count and week labels', (tester, db) async {
    await openDetail(tester, db, sessions: history);
    expect(find.text('8 dernières semaines'), findsOneWidget);
    expect(find.text('objectif tenu 3 fois'), findsOneWidget);
    expect(find.text('S36'), findsOneWidget);
    expect(find.text('S43'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Séances par semaine sur 8 semaines'),
      findsOneWidget,
    );
  });

  testApp('the button logs then removes today’s session', (tester, db) async {
    await openDetail(tester, db, sessions: [-1]);
    await tester.tap(find.text('Noter une séance aujourd’hui'));
    await settle(tester);
    expect(await todayValue(tester, db), 1);
    expect(find.text('2 / 3 séances'), findsOneWidget);
    expect(find.text('Séance notée aujourd’hui'), findsOneWidget);
    await tester.tap(find.text('Séance notée aujourd’hui'));
    await settle(tester);
    expect(await todayValue(tester, db), 0);
    expect(find.text('1 / 3 séances'), findsOneWidget);
  });

  testApp('reaching the target says so', (tester, db) async {
    await openDetail(tester, db, sessions: [-1, 0], times: 2);
    expect(
      find.text('Objectif de la semaine atteint, bravo !'),
      findsOneWidget,
    );
  });

  testApp('history tab: 26 weeks, three labels', (tester, db) async {
    await openDetail(tester, db, sessions: history);
    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
    expect(find.text('26 dernières semaines'), findsOneWidget);
    expect(find.text('Cette semaine'), findsNothing);
    expect(find.text('objectif tenu 3 fois'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Séances par semaine sur 26 semaines'),
      findsOneWidget,
    );
    // 26 weeks back from week 43 starts at week 18; the 13th is week 30.
    for (final w in ['S18', 'S30', 'S43']) {
      expect(find.text(w), findsOneWidget);
    }
    expect(find.text('S19'), findsNothing);
  });

  testApp('meets tap-target guidelines and holds 2x text', (tester, db) async {
    final handle = tester.ensureSemantics();
    await openDetail(tester, db, sessions: history);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
}
