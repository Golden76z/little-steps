import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/feedback/feedback.dart';

import '../helpers.dart';

final today = Day(2026, 10, 20);

final journal = Habit(
  id: 0,
  name: 'Écrire 3 lignes',
  type: HabitType.journal,
  color: HabitColor.peach,
  icon: 'note',
  goal: 3,
  step: 1,
  createdOn: Day(2026, 10, 1),
);

/// Creates the journal with [entries] and opens its detail.
Future<int> openJournal(
  WidgetTester tester,
  AppDatabase db, {
  List<HabitEntry Function(int id)> entries = const [],
}) async {
  final repo = HabitRepository(db);
  final id = (await tester.runAsync(() async {
    final id = await repo.createHabit(journal);
    for (final e in entries) {
      await repo.setEntry(e(id));
    }
    return id;
  }))!;
  await pumpApp(tester, db, locale: 'fr');
  await tester.tap(find.bySemanticsLabel('${journal.name}, ouvrir'));
  await settle(tester);
  return id;
}

Future<List<HabitEntry>> stored(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => HabitRepository(db).watchEntries().first))!;

Future<void> write(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
}

void main() {
  testApp('header, empty page and a disabled button', (tester, db) async {
    await openJournal(tester, db);
    expect(find.text('journal · chaque jour'), findsOneWidget);
    expect(find.text('Une ligne par idée…'), findsOneWidget);
    expect(find.text('0 / 3 lignes'), findsOneWidget);
    expect(find.text('Encore 3 lignes'), findsOneWidget);
  });

  testApp('the button unlocks at 3 lines and saves text and mood', (
    tester,
    db,
  ) async {
    final id = await openJournal(tester, db);
    await write(tester, 'Un café en terrasse\n\n');
    expect(find.text('1 / 3 lignes'), findsOneWidget);
    expect(find.text('Encore 2 lignes'), findsOneWidget);
    await tester.tap(find.text('Encore 2 lignes'));
    await settle(tester);
    expect(await stored(tester, db), isEmpty);

    const note = 'Un café en terrasse\nLe chapitre 4\nUn appel';
    await write(tester, note);
    expect(find.text('3 / 3 lignes'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Super'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await settle(tester);
    expect(find.text('Enregistré !'), findsOneWidget);
    final e = (await stored(tester, db)).single;
    expect(
      [e.habitId, e.day, e.value, e.note, e.mood],
      [id, today, 3, note, 3],
    );

    await write(tester, '$note\nEncore');
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testApp('saving the page celebrates once; moods tick', (tester, db) async {
    await openJournal(tester, db);
    await addOtherHabit(tester, db);
    final haptics = recordHaptics(tester);
    await write(tester, 'Une\nDeux\nTrois');
    await tester.tap(find.bySemanticsLabel('Super'));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.selectionClick']);
    await tester.tap(find.text('Enregistrer'));
    await settle(tester);
    expect(haptics.last, 'HapticFeedbackType.mediumImpact');
    expect(sounds.played, [Sound.done]);
    await write(tester, 'Une\nDeux\nTrois\nQuatre');
    await tester.tap(find.text('Enregistrer'));
    await settle(tester);
    expect(haptics.last, 'HapticFeedbackType.lightImpact');
    expect(sounds.played, [Sound.done]);
  });

  testApp('another question rotates the prompt', (tester, db) async {
    await openJournal(tester, db);
    expect(
      find.text('Qu’est-ce qui t’a fait sourire aujourd’hui ?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Autre question'));
    await tester.pumpAndSettle();
    expect(find.text('Une chose que tu as apprise ?'), findsOneWidget);
  });

  testApp('prefills today and lists past entries, newest first', (
    tester,
    db,
  ) async {
    await openJournal(
      tester,
      db,
      entries: [
        (id) => HabitEntry(
          habitId: id,
          day: today.addDays(-2),
          value: 1,
          note: 'Brunch',
          mood: 1,
        ),
        (id) => HabitEntry(
          habitId: id,
          day: today.addDays(-1),
          value: 2,
          note: 'Footing\nAppel avec maman',
          mood: 3,
        ),
        (id) => HabitEntry(habitId: id, day: today, value: 1, note: 'Soleil'),
      ],
    );
    expect(find.text('Soleil'), findsOneWidget);
    expect(find.text('1 / 3 lignes'), findsOneWidget);

    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
    expect(find.text('Encore 2 lignes'), findsNothing);
    expect(find.text('Footing\nAppel avec maman'), findsOneWidget);
    expect(find.text('2 lignes'), findsOneWidget);
    final monday = tester.getTopLeft(find.text('Lundi 19 octobre')).dy;
    final sunday = tester.getTopLeft(find.text('Dimanche 18 octobre')).dy;
    expect(monday, lessThan(sunday));
  });

  testApp('history without notes says so', (tester, db) async {
    await openJournal(tester, db);
    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
    expect(find.text('Rien d’écrit pour l’instant.'), findsOneWidget);
  });

  testApp('meets tap-target guidelines and holds 2x text', (tester, db) async {
    final handle = tester.ensureSemantics();
    await openJournal(tester, db);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await write(tester, 'Une\nDeux\nTrois');
    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    handle.dispose();
  });
}
