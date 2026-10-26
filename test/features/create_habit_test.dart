import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/feedback/feedback.dart';
import 'package:little_steps/core/widgets/fade_through_switcher.dart';
import 'package:little_steps/core/widgets/rolling_text.dart';

import 'package:little_steps/features/today/pill_entrance.dart';

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

  testApp('a created habit pops into Today, once', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Vitamines');
    await tapText(tester, 'Continuer · Vitamines');
    await tapText(tester, 'Continuer');
    final haptics = recordHaptics(tester);
    await tester.tap(find.text('Créer l’habitude'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    // Still covered by the creation screen sliding out: it waits.
    expect(find.text('Quand ?'), findsOneWidget);
    expect(sounds.played, isEmpty);
    var sparkled = false;
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      sparkled |= find.byKey(PillEntrance.sparkleKey).evaluate().isNotEmpty;
    }
    expect(sparkled, isTrue);
    await settle(tester);
    expect(find.byKey(PillEntrance.sparkleKey), findsNothing);
    expect(find.text('Vitamines'), findsOneWidget);
    expect(sounds.played, [Sound.pop]);
    expect(haptics, contains('HapticFeedbackType.lightImpact'));
    // Leaving Today and coming back does not replay it.
    await tester.tap(find.bySemanticsLabel(RegExp('Progrès')).first);
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Aujourd’hui')).first);
    await settle(tester);
    expect(sounds.played, [Sound.pop]);
  });

  testApp('a habit created to rest today pops in too', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Vitamines');
    await tapText(tester, 'Continuer · Vitamines');
    await tapText(tester, 'Continuer');
    // Tuesday (the test day) off.
    await tester.tap(find.text('M').first);
    await tester.pumpAndSettle();
    await tapText(tester, 'Créer l’habitude');
    await settle(tester);
    expect(find.text('Repos aujourd’hui'), findsOneWidget);
    expect(sounds.played, [Sound.pop]);
  });

  testApp('the goal step rolls and ticks; colour and icon tick', (
    tester,
    db,
  ) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Boire de l’eau');
    await tapText(tester, 'Continuer · Boire de l’eau');
    final haptics = recordHaptics(tester);
    await tester.tap(find.bySemanticsLabel('Augmenter l’objectif'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is RollingText && w.text == '2,25'),
      findsOneWidget,
    );
    expect(haptics, ['HapticFeedbackType.selectionClick']);
    await tester.tap(find.bySemanticsLabel('Changer l’icône'));
    await tester.pumpAndSettle();
    expect(haptics, hasLength(2));
  });

  testApp('changing the rhythm fades through', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Vitamines');
    await tapText(tester, 'Continuer · Vitamines');
    await tapText(tester, 'Continuer');
    Finder switched(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byType(FadeThroughSwitcher),
    );
    expect(switched('Tous les jours, sans repos.'), findsOneWidget);
    final haptics = recordHaptics(tester);
    await tester.tap(find.bySemanticsLabel('samedi, actif'));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.selectionClick']);
    await tapText(tester, 'X fois / semaine');
    expect(switched('fois par semaine'), findsOneWidget);
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
    await tester.longPress(find.bySemanticsLabel('Lire, ouvrir'));
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
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await tapText(tester, 'Boire de l’eau');
    await tapText(tester, 'Continuer · Boire de l’eau');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tapText(tester, 'Continuer');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    handle.dispose();
  });

  testApp('colour swatches and weekdays are 48 px targets, drawn as before', (
    tester,
    db,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, db, locale: 'fr');
    await tapText(tester, 'Créer ma première habitude');
    await tapText(tester, 'Boire de l’eau');
    await tapText(tester, 'Continuer · Boire de l’eau');
    final lemon = find.bySemanticsLabel('Citron');
    expect(tester.getSize(lemon).height, 48);
    final swatch = find.descendant(
      of: lemon,
      matching: find.byType(AnimatedContainer),
    );
    expect(tester.getSize(swatch).height, 28);
    expect(
      tester.getSemantics(lemon),
      isSemantics(isButton: true, isSelected: false, hasTapAction: true),
    );
    // The bottom row reaches down: a tap under the drawn swatch still counts.
    await tester.tapAt(tester.getRect(lemon).bottomCenter - const Offset(0, 4));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(lemon), isSemantics(isSelected: true));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await tapText(tester, 'Continuer');
    final monday = find.bySemanticsLabel('lundi, actif');
    expect(tester.getSize(monday).width, greaterThanOrEqualTo(48));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
