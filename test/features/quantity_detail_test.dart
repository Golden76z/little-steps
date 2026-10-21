import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

import '../helpers.dart';

final today = Day(2026, 10, 20);

Habit quantity(
  String name,
  QuantityUnit unit, {
  double goal = 2000,
  double step = 250,
}) => Habit(
  id: 0,
  name: name,
  type: HabitType.quantity,
  color: HabitColor.sky,
  icon: 'drop',
  goal: goal,
  step: step,
  unit: unit,
  createdOn: Day(2026, 10, 1),
);

/// Creates [h] with [values] (offset from today → value) and opens its detail.
Future<int> openDetail(
  WidgetTester tester,
  AppDatabase db,
  Habit h, {
  Map<int, double> values = const {},
}) async {
  final repo = HabitRepository(db);
  final id = (await tester.runAsync(() async {
    final id = await repo.createHabit(h);
    for (final MapEntry(:key, :value) in values.entries) {
      await repo.setEntry(
        HabitEntry(habitId: id, day: today.addDays(key), value: value),
      );
    }
    return id;
  }))!;
  await pumpApp(tester, db, locale: 'fr');
  await tester.tap(find.bySemanticsLabel('${h.name}, ouvrir'));
  await tester.pumpAndSettle();
  return id;
}

Future<Habit> stored(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => HabitRepository(db).watchHabits().first))!
        .single;

Future<double> todayValue(WidgetTester tester, AppDatabase db) async {
  final entries = (await tester.runAsync(
    () => HabitRepository(db).watchEntries().first,
  ))!;
  return entries.where((e) => e.day == today).firstOrNull?.value ?? 0;
}

void main() {
  testApp('litres: big value, glasses below, header subtitle', (
    tester,
    db,
  ) async {
    await openDetail(
      tester,
      db,
      quantity('Boire de l’eau', QuantityUnit.liters),
      values: {0: 1250},
    );
    expect(find.text('2 L · chaque jour'), findsOneWidget);
    expect(find.text('1,25'), findsWidgets);
    expect(find.text('5 verres de 25 cl'), findsOneWidget);
  });

  testApp('the button adds a step, minus removes one', (tester, db) async {
    await openDetail(
      tester,
      db,
      quantity('Boire de l’eau', QuantityUnit.liters),
      values: {0: 250},
    );
    await tester.tap(find.widgetWithText(FilledButton, '+25 cl'));
    await settle(tester);
    expect(await todayValue(tester, db), 500);
    await tester.tap(find.bySemanticsLabel('Retirer 25 cl'));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Retirer 25 cl'));
    await settle(tester);
    expect(await todayValue(tester, db), 0);
  });

  testApp('switching to glasses keeps the amount', (tester, db) async {
    await openDetail(
      tester,
      db,
      quantity('Boire de l’eau', QuantityUnit.liters),
      values: {0: 1250},
    );
    await tester.tap(find.text('Verres'));
    await settle(tester);
    expect((await stored(tester, db)).unit, QuantityUnit.glasses);
    expect(find.text('1,25 L sur 2 L'), findsOneWidget);
    expect(find.text('+1 verre'), findsWidgets);
  });

  testApp('“Ajouter par” changes the quick step', (tester, db) async {
    await openDetail(
      tester,
      db,
      quantity('Boire de l’eau', QuantityUnit.liters),
    );
    await tester.tap(find.text('+50 cl').first);
    await settle(tester);
    expect((await stored(tester, db)).step, 500);
  });

  testApp('stats: streak, record and this month', (tester, db) async {
    await openDetail(
      tester,
      db,
      quantity('Boire de l’eau', QuantityUnit.liters),
      values: {-3: 2000, -2: 2000, -1: 2000, -5: 2000},
    );
    expect(find.text('jours de suite'), findsOneWidget);
    expect(find.text('record'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('objectif atteint 4 jours'), findsOneWidget);
    // 4 days met out of 20 since October 1st.
    expect(find.text('20 %'), findsOneWidget);
  });

  testApp('pages: no unit switch, share of the goal below', (tester, db) async {
    await openDetail(
      tester,
      db,
      quantity('Lire', QuantityUnit.pages, goal: 20, step: 4),
      values: {0: 12},
    );
    expect(find.text('Verres'), findsNothing);
    expect(
      find.textContaining('/ 20 pages', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('60 % de l’objectif'), findsOneWidget);
  });

  testApp('meets tap-target guidelines and holds 2x text', (tester, db) async {
    final handle = tester.ensureSemantics();
    await openDetail(
      tester,
      db,
      quantity('Boire de l’eau', QuantityUnit.liters),
      values: {0: 1250},
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    handle.dispose();
  });
}
