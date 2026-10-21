import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

import '../helpers.dart';

Habit yesNo(String name) => Habit(
  id: 0,
  name: name,
  type: HabitType.yesNo,
  color: HabitColor.mint,
  icon: 'book',
  goal: 1,
  step: 1,
  createdOn: Day(2026, 10, 1),
);

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> openCreate(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Nouvelle habitude'));
  await tester.pumpAndSettle();
}

void main() {
  testApp('P1 continues with the picked type or popular habit', (
    tester,
    db,
  ) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('Continuer · Quantité'), findsOneWidget);
    await tapText(tester, 'Oui / non');
    expect(find.text('Continuer · Oui / non'), findsOneWidget);
    await tapText(tester, 'Boire de l’eau');
    expect(find.text('Continuer · Boire de l’eau'), findsOneWidget);
  });

  testApp('creating water from the popular tile', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Boire de l’eau');
    await tapText(tester, 'Continuer · Boire de l’eau');
    expect(find.text('2/3'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Boire de l’eau'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Augmenter l’objectif'));
    await tester.pumpAndSettle();
    expect(find.text('2,25'), findsOneWidget);
    await tapText(tester, 'Continuer');
    expect(find.text('Quand ?'), findsOneWidget);
    await tapText(tester, 'Créer l’habitude');
    await settle(tester);
    expect(find.text('Habitude créée'), findsOneWidget);
    expect(find.text('0 / 2,25 L'), findsOneWidget);
    final h = (await tester.runAsync(
      () => HabitRepository(db).watchHabits().first,
    ))!.single;
    expect(
      (h.goal, h.step, h.unit, h.icon),
      (2250.0, 250.0, QuantityUnit.liters, 'drop'),
    );
  });

  testApp('the search text becomes the name', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tester.enterText(find.byType(TextField), 'Tricot');
    await tester.pumpAndSettle();
    await tapText(tester, 'Durée');
    await tapText(tester, 'Continuer · Durée');
    expect(find.widgetWithText(TextField, 'Tricot'), findsOneWidget);
    expect(find.text('min'), findsWidgets);
    expect(find.text('10'), findsOneWidget);
  });

  testApp('a name is required to continue', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Continuer · Quantité');
    final cta = find.widgetWithText(FilledButton, 'Continuer');
    expect(tester.widget<FilledButton>(cta).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Marcher');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(cta).onPressed, isNotNull);
  });

  testApp('rest days are explained', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Vitamines');
    await tapText(tester, 'Continuer · Vitamines');
    await tapText(tester, 'Continuer');
    expect(find.text('Tous les jours, sans repos.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('samedi, actif'));
    await tester.tap(find.bySemanticsLabel('dimanche, actif'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        '5 jours actifs · repos le samedi et dimanche. Ces jours-là ne comptent pas dans la série.',
      ),
      findsOneWidget,
    );
  });

  testApp('frequency is set in times per week', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Courir');
    await tapText(tester, 'Continuer · Courir');
    expect(find.text('Objectif par jour'), findsNothing);
    await tapText(tester, 'Continuer');
    expect(find.text('Jours précis'), findsNothing);
    expect(find.text('fois par semaine'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Plus'));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
  });

  testApp('the moment sets a default reminder, a tap removes it', (
    tester,
    db,
  ) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Oui / non');
    await tester.enterText(find.byType(TextField), 'Étirements');
    await tapText(tester, 'Continuer · Oui / non');
    await tapText(tester, 'Continuer');
    await tapText(tester, 'Matin');
    expect(find.text('08:00'), findsOneWidget);
    await tapText(tester, '08:00');
    expect(find.text('08:00'), findsNothing);
  });

  testApp('beyond 5 habits the + opens Premium', (tester, db) async {
    final repo = HabitRepository(db);
    await tester.runAsync(() async {
      for (var i = 0; i < 5; i++) {
        await repo.createHabit(yesNo('H$i'));
      }
    });
    await pumpApp(tester, db, locale: 'fr');
    await openCreate(tester);
    expect(find.text('Little Steps Premium'), findsOneWidget);
  });

  testApp('Modifier edits the habit in place', (tester, db) async {
    await tester.runAsync(() => HabitRepository(db).createHabit(yesNo('Lire')));
    await pumpApp(tester, db, locale: 'fr');
    await tester.longPress(find.text('Lire'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Modifier l’habitude');
    expect(find.text('2/3'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Lire le soir');
    await tapText(tester, 'Continuer');
    await tapText(tester, 'Enregistrer');
    await settle(tester);
    expect(find.text('Lire le soir'), findsOneWidget);
    expect(
      (await tester.runAsync(() => HabitRepository(db).watchHabits().first))!
          .length,
      1,
    );
  });

  testApp('an E1 idea opens P2 prefilled', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Boire 2 L');
    expect(find.text('2/3'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Boire de l’eau'), findsOneWidget);
  });

  testApp('the flow meets tap-target guidelines and holds 2x text', (
    tester,
    db,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tapText(tester, 'Boire de l’eau');
    await tapText(tester, 'Continuer · Boire de l’eau');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tapText(tester, 'Continuer');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    handle.dispose();
  });
}
