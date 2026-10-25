import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/widgets/fade_through_switcher.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

import '../helpers.dart';

final today = Day(2026, 10, 20);

Habit yesNo(String name) => Habit(
  id: 0,
  name: name,
  type: HabitType.yesNo,
  color: HabitColor.pink,
  icon: 'barbell',
  goal: 1,
  step: 1,
  createdOn: today.addDays(-20),
);

/// Two habits, perfect from day −15 to −2 (14 days: 2 jokers), [missYesterday]
/// leaves Sport undone yesterday.
Future<void> seed(
  WidgetTester tester,
  AppDatabase db, {
  bool missYesterday = true,
  int perfectFrom = -15,
}) async {
  final repo = HabitRepository(db);
  await tester.runAsync(() async {
    final read = await repo.createHabit(yesNo('Lire'));
    final sport = await repo.createHabit(yesNo('Sport'));
    for (var o = perfectFrom; o <= -1; o++) {
      await repo.setEntry(
        HabitEntry(habitId: read, day: today.addDays(o), value: 1),
      );
      if (o < -1 || !missYesterday) {
        await repo.setEntry(
          HabitEntry(habitId: sport, day: today.addDays(o), value: 1),
        );
      }
    }
  });
}

void main() {
  testApp('opens on Today when yesterday broke the streak', (tester, db) async {
    await seed(tester, db);
    await pumpApp(tester, db, locale: 'fr');
    await settle(tester);
    expect(find.text('Ta série est en danger'), findsOneWidget);
    expect(
      find.textContaining('Hier, tu n’as pas fait Sport', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('série de 14 jours', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Utiliser un joker · 2 restants'), findsOneWidget);
  });

  testApp('using a joker saves yesterday', (tester, db) async {
    await seed(tester, db);
    await pumpApp(tester, db, locale: 'fr');
    await settle(tester);
    await tester.tap(find.text('Utiliser un joker · 2 restants'));
    await settle(tester);
    expect(find.text('Série sauvée !'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FadeThroughSwitcher),
        matching: find.text('Série sauvée !'),
      ),
      findsOneWidget,
    );
    expect(
      find.text('Toujours 14 jours de suite. Il te reste 1 joker.'),
      findsOneWidget,
    );
    expect(
      await tester.runAsync(() => HabitRepository(db).watchJokerDays().first),
      {today.addDays(-1)},
    );
    await tester.tap(find.text('C’est reparti'));
    await settle(tester);
    expect(find.text('Série sauvée !'), findsNothing);
  });

  testApp('letting it go explains the fresh start', (tester, db) async {
    await seed(tester, db);
    await pumpApp(tester, db, locale: 'fr');
    await settle(tester);
    await tester.tap(find.text('Laisser passer'));
    await tester.pumpAndSettle();
    expect(find.text('On repart de zéro'), findsOneWidget);
    expect(
      await tester.runAsync(() => HabitRepository(db).watchJokerDays().first),
      isEmpty,
    );
  });

  testApp('shown once a day', (tester, db) async {
    await seed(tester, db);
    await pumpApp(tester, db, locale: 'fr');
    await settle(tester);
    await tester.tap(find.text('Laisser passer'));
    await tester.pumpAndSettle();
    await pumpApp(tester, db, locale: 'fr');
    await settle(tester);
    expect(find.text('Ta série est en danger'), findsNothing);
  });

  testApp('nothing when yesterday was perfect or without jokers', (
    tester,
    db,
  ) async {
    await seed(tester, db, missYesterday: false);
    await pumpApp(tester, db, locale: 'fr');
    await settle(tester);
    expect(find.text('Ta série est en danger'), findsNothing);
  });

  testApp('no joker in reserve: no sheet', (tester, db) async {
    await seed(tester, db, perfectFrom: -5);
    await pumpApp(tester, db, locale: 'fr');
    await settle(tester);
    expect(find.text('Ta série est en danger'), findsNothing);
  });
}
