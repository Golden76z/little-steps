import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

import '../helpers.dart';

final today = Day(2026, 10, 20);

/// "Lire", daily yes/no since Monday, done Monday and today: two perfect
/// days, no joker in reserve, so no joker sheet on Today.
Future<void> seed(WidgetTester tester, AppDatabase db) =>
    tester.runAsync(() async {
      final repo = HabitRepository(db);
      final id = await repo.createHabit(
        Habit(
          id: 0,
          name: 'Lire',
          type: HabitType.yesNo,
          color: HabitColor.mint,
          icon: 'book',
          goal: 1,
          step: 1,
          activeDays: Habit.everyDay,
          scheduleMode: ScheduleMode.days,
          moment: Moment.anytime,
          createdOn: today.addDays(-1),
        ),
      );
      for (final d in [today.addDays(-1), today]) {
        await repo.setEntry(HabitEntry(habitId: id, day: d, value: 1));
      }
    });

Future<void> openTrophies(WidgetTester tester, AppDatabase db) async {
  await seed(tester, db);
  await pumpApp(tester, db, locale: 'fr');
  await tester.tap(find.bySemanticsLabel('Trophées'));
  await settle(tester);
}

void main() {
  testApp('header shows the level and its XP', (tester, db) async {
    await openTrophies(tester, db);
    // 2 habits done + 2 perfect days = 60 XP, level 1 costs 200.
    expect(find.text('60 / 200 XP'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Niveau 1, 30')), findsOneWidget);
    expect(find.bySemanticsLabel('Série de 2 jours'), findsOneWidget);
  });

  testApp('badges tab: count, earned and locked badges, challenge', (
    tester,
    db,
  ) async {
    await openTrophies(tester, db);
    expect(find.text('2 sur 12'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // jokers
    expect(find.text('2 j'), findsOneWidget); // best streak
    expect(find.bySemanticsLabel('Premier pas, obtenu'), findsOneWidget);
    expect(find.bySemanticsLabel('30 jours, verrouillé'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Défi de la semaine'), 200);
    expect(find.text('Lire 7 jours d’affilée'), findsOneWidget);
    expect(find.text('+150 XP'), findsOneWidget);
    expect(find.bySemanticsLabel('2 jours sur 7'), findsOneWidget);
  });

  testApp('challenges tab lists each challenge with its progress', (
    tester,
    db,
  ) async {
    await openTrophies(tester, db);
    await tester.tap(find.text('Défis'));
    await tester.pumpAndSettle();
    expect(find.text('Lire 7 jours d’affilée'), findsOneWidget);
    expect(find.text('2 jours sur 7 · reste 5 jours'), findsOneWidget);
    expect(find.text('Une semaine parfaite'), findsOneWidget);
    expect(find.text('2 journées parfaites sur 7'), findsOneWidget);
    expect(find.text('+300 XP'), findsOneWidget);
  });

  testApp('tap targets meet the guideline', (tester, db) async {
    final handle = tester.ensureSemantics();
    await openTrophies(tester, db);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tester.tap(find.text('Défis'));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testApp('holds with 2x system text', (tester, db) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openTrophies(tester, db);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Défis'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
