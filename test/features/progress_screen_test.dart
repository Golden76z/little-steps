import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/features/habit_detail/yes_no_detail.dart';

import '../helpers.dart';

final monday = Day(2026, 10, 19);

String pct(double f) => NumberFormat.percentPattern('fr').format(f);

Habit make(String name, HabitColor color, String icon) => Habit(
  id: 0,
  name: name,
  type: HabitType.yesNo,
  color: color,
  icon: icon,
  goal: 1,
  step: 1,
  activeDays: Habit.everyDay,
  scheduleMode: ScheduleMode.days,
  moment: Moment.anytime,
  createdOn: monday.addDays(-14),
);

/// Two daily habits since 5 October. Lire: 12–16 and 19–20 October;
/// Méditer: 19 October. Only one perfect day, so no joker sheet.
Future<void> openProgress(WidgetTester tester, AppDatabase db) async {
  await tester.runAsync(() async {
    final repo = HabitRepository(db);
    final read = await repo.createHabit(make('Lire', HabitColor.mint, 'book'));
    final meditate = await repo.createHabit(
      make('Méditer', HabitColor.lilac, 'lotus'),
    );
    for (final d in [
      for (var i = -7; i <= -3; i++) monday.addDays(i),
      monday,
      monday.addDays(1),
    ]) {
      await repo.setEntry(HabitEntry(habitId: read, day: d, value: 1));
    }
    await repo.setEntry(HabitEntry(habitId: meditate, day: monday, value: 1));
  });
  await pumpApp(tester, db, locale: 'fr');
  await tester.tap(find.bySemanticsLabel('Progrès'));
  await settle(tester);
}

void main() {
  testApp('week: range, rate, pills and gap with last week', (
    tester,
    db,
  ) async {
    await openProgress(tester, db);
    expect(find.text('19 – 25 octobre'), findsOneWidget);
    expect(find.text(pct(0.75)), findsOneWidget);
    expect(find.text('3 pilules sur 4'), findsOneWidget);
    // 75 % now, 5 / 14 = 36 % last week.
    expect(find.text('+${pct(0.39)} vs sem. dernière'), findsOneWidget);
    expect(find.text('Par habitude'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Lire')).dy,
      lessThan(tester.getTopLeft(find.text('Méditer')).dy),
    );
    expect(find.bySemanticsLabel(RegExp('^Taux par période')), findsOneWidget);
  });

  testApp('month and year views', (tester, db) async {
    await openProgress(tester, db);
    await tester.tap(find.text('Mois'));
    await tester.pumpAndSettle();
    expect(find.text('octobre 2026'), findsOneWidget);
    // 5 → 20 October, two habits: 8 of 32.
    expect(find.text('8 pilules sur 32'), findsOneWidget);
    expect(find.textContaining('vs mois dernier'), findsNothing);
    await tester.tap(find.text('Année'));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('8 pilules sur 32'), findsOneWidget);
  });

  testApp('arrows move between weeks, next stops at this one', (
    tester,
    db,
  ) async {
    await openProgress(tester, db);
    await tester.tap(find.bySemanticsLabel('Période suivante'));
    await tester.pumpAndSettle();
    expect(find.text('19 – 25 octobre'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Période précédente'));
    await tester.pumpAndSettle();
    expect(find.text('12 – 18 octobre'), findsOneWidget);
    expect(find.text('5 pilules sur 14'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Période suivante'));
    await tester.pumpAndSettle();
    expect(find.text('19 – 25 octobre'), findsOneWidget);
  });

  testApp('tapping a habit row opens its detail', (tester, db) async {
    await openProgress(tester, db);
    await tester.tap(find.text('Méditer'));
    await settle(tester);
    expect(find.byType(YesNoDetail), findsOneWidget);
  });

  testApp('meets the tap-target guideline', (tester, db) async {
    final handle = tester.ensureSemantics();
    await openProgress(tester, db);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testApp('holds with 2x system text', (tester, db) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openProgress(tester, db);
    for (final p in ['Mois', 'Année']) {
      await tester.tap(find.text(p));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
