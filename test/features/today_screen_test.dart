import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/feedback/feedback.dart';

import '../helpers.dart';

final today = Day(2026, 10, 20);

Habit make(
  String name,
  HabitType type, {
  double goal = 1,
  double step = 1,
  QuantityUnit? unit,
  Set<int> activeDays = Habit.everyDay,
  ScheduleMode mode = ScheduleMode.days,
  Moment moment = Moment.anytime,
}) => Habit(
  id: 0,
  name: name,
  type: type,
  color: HabitColor.sky,
  icon: 'drop',
  goal: goal,
  step: step,
  unit: unit,
  activeDays: activeDays,
  scheduleMode: mode,
  moment: moment,
  createdOn: today.addDays(-30),
);

late HabitRepository repo;

Future<void> pumpToday(WidgetTester tester, AppDatabase db) =>
    pumpApp(tester, db, locale: 'fr');

void testToday(
  String description,
  Future<void> Function(WidgetTester tester, AppDatabase db) body,
) => testApp(description, (tester, db) {
  repo = HabitRepository(db);
  return body(tester, db);
});

void main() {
  testToday('no habit: the empty state invites to create one', (
    tester,
    db,
  ) async {
    await pumpToday(tester, db);
    expect(find.text('Ta journée est toute vide'), findsOneWidget);
    await tester.tap(find.text('Créer ma première habitude'));
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle habitude'), findsOneWidget);
  });

  testToday('a pill shows name, native value and percentage', (
    tester,
    db,
  ) async {
    final id = await repo.createHabit(
      make(
        'Boire de l’eau',
        HabitType.quantity,
        goal: 2000,
        step: 250,
        unit: QuantityUnit.liters,
      ),
    );
    await repo.setEntry(HabitEntry(habitId: id, day: today, value: 1250));
    await pumpToday(tester, db);
    expect(find.text('Boire de l’eau'), findsOneWidget);
    expect(find.text('1,25 / 2 L'), findsOneWidget);
    expect(find.text('63 %'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Boire de l’eau, 63')),
      findsOneWidget,
    );
  });

  testToday('tapping a quantity pill adds a step, Annuler reverts it', (
    tester,
    db,
  ) async {
    await repo.createHabit(
      make(
        'Boire de l’eau',
        HabitType.quantity,
        goal: 2000,
        step: 250,
        unit: QuantityUnit.liters,
      ),
    );
    await pumpToday(tester, db);
    await tester.tap(find.text('Boire de l’eau'));
    await settle(tester);
    expect(find.text('0,25 / 2 L'), findsOneWidget);
    expect(find.text('Boire de l’eau : +25 cl'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await settle(tester);
    expect(find.text('0 / 2 L'), findsOneWidget);
  });

  testToday('tapping a yes/no pill checks it', (tester, db) async {
    await repo.createHabit(
      make('Pas d’écran au lit', HabitType.yesNo, moment: Moment.evening),
    );
    await pumpToday(tester, db);
    expect(find.text('Ce soir'), findsOneWidget);
    await tester.tap(find.text('Pas d’écran au lit'));
    await settle(tester);
    expect(find.text('C’est fait !'), findsOneWidget);
  });

  testToday('tapping a duration pill opens its detail', (tester, db) async {
    await repo.createHabit(
      make('Méditer', HabitType.duration, goal: 600, step: 300),
    );
    await pumpToday(tester, db);
    await tester.tap(find.text('Méditer'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Navigation principale'), findsNothing);
    expect(find.text('Méditer'), findsOneWidget);
  });

  testToday('long press on the icon opens the options sheet', (
    tester,
    db,
  ) async {
    await repo.createHabit(make('Sport', HabitType.yesNo));
    await pumpToday(tester, db);
    await tester.longPress(find.bySemanticsLabel('Sport, ouvrir'));
    await tester.pumpAndSettle();
    for (final label in [
      'Modifier l’habitude',
      'Mettre en pause',
      'Archiver',
      'Supprimer',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    // The sheet's scrim covers the floating bar: a tap there only closes it.
    await tester.tap(find.bySemanticsLabel('Progrès'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Progrès'), findsNothing);
  });

  Habit water() => make(
    'Boire de l’eau',
    HabitType.quantity,
    goal: 2000,
    step: 250,
    unit: QuantityUnit.liters,
  );

  Future<Map<int, double>> values(WidgetTester tester) async => {
    for (final e in (await tester.runAsync(() => repo.watchEntries().first))!)
      if (e.day == today) e.habitId: e.value,
  };

  testToday('a burst of taps shows one message, Annuler undoes it all', (
    tester,
    db,
  ) async {
    await repo.createHabit(water());
    await pumpToday(tester, db);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Boire de l’eau'));
      await tester.pump();
    }
    await settle(tester);
    expect(find.text('0,75 / 2 L'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    // The message sums the burst: what Annuler takes back.
    expect(find.text('Boire de l’eau : +75 cl'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await settle(tester);
    expect(find.text('0 / 2 L'), findsOneWidget);
    // No queued message comes in after it.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testToday('Annuler after a burst on A then a tap on B only undoes B', (
    tester,
    db,
  ) async {
    final a = await repo.createHabit(water());
    final b = await repo.createHabit(make('Lire', HabitType.yesNo));
    await pumpToday(tester, db);
    await tester.tap(find.text('Boire de l’eau'));
    await tester.pump();
    await tester.tap(find.text('Boire de l’eau'));
    await tester.pump();
    await tester.tap(find.text('Lire'));
    await settle(tester);
    expect(await values(tester), {a: 500, b: 1});
    await tester.tap(find.text('Annuler'));
    await settle(tester);
    expect(await values(tester), {a: 500});
  });

  testToday('the pill shows the new value on the frame of the tap', (
    tester,
    db,
  ) async {
    await repo.createHabit(water());
    await pumpToday(tester, db);
    await tester.tap(find.text('Boire de l’eau'));
    await tester.pump();
    expect(find.text('13 %'), findsOneWidget);
    await settle(tester);
  });

  testToday('completing plays success and done once; recheck is light', (
    tester,
    db,
  ) async {
    final read = await repo.createHabit(make('Lire', HabitType.yesNo));
    final sport = await repo.createHabit(make('Sport', HabitType.yesNo));
    // First step already earned: no badge celebration on top.
    await repo.setEntry(
      HabitEntry(habitId: sport, day: today.addDays(-1), value: 1),
    );
    await pumpToday(tester, db);
    final haptics = recordHaptics(tester);
    await tester.tap(find.text('Lire'));
    await settle(tester);
    expect(haptics, ['HapticFeedbackType.mediumImpact']);
    expect(sounds.played, [Sound.done]);
    expect(await values(tester), {read: 1});
    await tester.tap(find.text('Lire'));
    await settle(tester);
    await tester.tap(find.text('Lire'));
    await settle(tester);
    expect(haptics, [
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.lightImpact',
    ]);
    expect(sounds.played, [Sound.done]);
  });

  testToday('completing sends the XP it earns flying', (tester, db) async {
    await repo.createHabit(make('Lire', HabitType.yesNo));
    await repo.createHabit(make('Sport', HabitType.yesNo));
    await pumpToday(tester, db);
    await tester.tap(find.text('Lire'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('+10 XP'), findsOneWidget);
    await settle(tester);
    expect(find.text('+10 XP'), findsNothing);
  });

  testToday('pills are keyed by habit id', (tester, db) async {
    final a = await repo.createHabit(make('Lire', HabitType.yesNo));
    final b = await repo.createHabit(make('Sport', HabitType.yesNo));
    await pumpToday(tester, db);
    expect(find.byKey(ValueKey(a)), findsOneWidget);
    expect(find.byKey(ValueKey(b)), findsOneWidget);
  });

  testToday('archiving removes the habit from Today', (tester, db) async {
    await repo.createHabit(make('Sport', HabitType.yesNo));
    await repo.createHabit(make('Lire', HabitType.yesNo));
    await pumpToday(tester, db);
    await tester.longPress(find.bySemanticsLabel('Sport, ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archiver'));
    await settle(tester);
    expect(find.text('Sport'), findsNothing);
    expect(find.text('Habitude archivée'), findsOneWidget);
  });

  testToday('deleting asks for confirmation first', (tester, db) async {
    await repo.createHabit(make('Sport', HabitType.yesNo));
    await repo.createHabit(make('Lire', HabitType.yesNo));
    await pumpToday(tester, db);
    await tester.longPress(find.bySemanticsLabel('Sport, ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer Sport et son historique ?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await settle(tester);
    expect(find.text('Sport'), findsNothing);
    expect(await tester.runAsync(() => repo.watchHabits().first), hasLength(1));
  });

  testToday('pausing for a week moves the habit to the rest group', (
    tester,
    db,
  ) async {
    await repo.createHabit(make('Sport', HabitType.yesNo));
    await pumpToday(tester, db);
    await tester.longPress(find.bySemanticsLabel('Sport, ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mettre en pause').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('mardi 27 octobre'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Mettre en pause'));
    await settle(tester);
    expect(find.text('Repos aujourd’hui'), findsOneWidget);
    expect(find.text('En pause jusqu’au lundi 26 octobre'), findsOneWidget);
  });

  testToday('rest-day habits are grouped at the bottom', (tester, db) async {
    await repo.createHabit(make('Lire', HabitType.yesNo));
    await repo.createHabit(
      make('Sport', HabitType.yesNo, activeDays: {1, 3, 5}),
    );
    await pumpToday(tester, db);
    expect(find.text('Repos aujourd’hui'), findsOneWidget);
    expect(find.text('Jour de repos'), findsOneWidget);
  });

  testToday('picking a past day shows and edits that day', (tester, db) async {
    final id = await repo.createHabit(make('Lire', HabitType.yesNo));
    await repo.setEntry(
      HabitEntry(habitId: id, day: today.addDays(-1), value: 1),
    );
    await pumpToday(tester, db);
    expect(find.text('Aujourd’hui'), findsWidgets);
    await tester.tap(find.text('19'));
    await tester.pumpAndSettle();
    expect(find.text('Lundi 19'), findsOneWidget);
    expect(find.text('C’est fait !'), findsOneWidget);
  });

  testToday('future days are read-only', (tester, db) async {
    await repo.createHabit(make('Lire', HabitType.yesNo));
    await pumpToday(tester, db);
    await tester.tap(find.text('21'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lire'));
    await settle(tester);
    expect(await tester.runAsync(() => repo.watchEntries().first), isEmpty);
  });

  testToday('holds with 2x system text', (tester, db) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await repo.createHabit(
      make(
        'Boire de l’eau',
        HabitType.quantity,
        goal: 2000,
        step: 250,
        unit: QuantityUnit.liters,
      ),
    );
    await repo.createHabit(make('Sport', HabitType.yesNo, activeDays: {1}));
    await pumpToday(tester, db);
    expect(tester.takeException(), isNull);
  });

  testToday('pills meet tap-target and label guidelines', (tester, db) async {
    final handle = tester.ensureSemantics();
    await repo.createHabit(make('Lire', HabitType.yesNo));
    await pumpToday(tester, db);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
