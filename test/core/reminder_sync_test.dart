import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

import '../helpers.dart';

Habit reading({List<int> reminders = const [20 * 60]}) => Habit(
  id: 0,
  name: 'Lire',
  type: HabitType.yesNo,
  color: HabitColor.mint,
  icon: 'book',
  goal: 1,
  step: 1,
  reminders: reminders,
  createdOn: Day(2026, 10, 1),
);

/// Lets the debounced sync run.
Future<void> sync(WidgetTester tester) async {
  await settle(tester);
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testApp('reminders are scheduled with localized texts and a route', (
    tester,
    db,
  ) async {
    final id = (await tester.runAsync(
      () => HabitRepository(db).createHabit(reading()),
    ))!;
    await pumpApp(tester, db, locale: 'fr');
    await sync(tester);
    expect(scheduler.scheduled, hasLength(14));
    final first = scheduler.scheduled.first;
    expect(
      (first.title, first.body, first.payload),
      ('Lire', 'Un petit pas maintenant ?', '/habit/$id'),
    );
    expect(first.at, DateTime(2026, 10, 20, 20));
  });

  testApp('doing the habit drops today’s reminder', (tester, db) async {
    await tester.runAsync(() => HabitRepository(db).createHabit(reading()));
    await pumpApp(tester, db, locale: 'fr');
    await sync(tester);
    await tester.tap(find.text('Lire'));
    await sync(tester);
    expect(scheduler.scheduled.first.at, DateTime(2026, 10, 21, 20));
  });

  testApp('the streak alert lists the habits at risk', (tester, db) async {
    await tester.runAsync(() async {
      final repo = HabitRepository(db);
      final id = await repo.createHabit(reading(reminders: []));
      await repo.setEntry(
        HabitEntry(habitId: id, day: Day(2026, 10, 19), value: 1),
      );
    });
    await pumpApp(tester, db, locale: 'fr');
    await sync(tester);
    final alert = scheduler.scheduled.first;
    expect(
      (alert.title, alert.body, alert.payload),
      (
        'Ta série est en danger',
        'Encore Lire aujourd’hui pour garder ta flamme.',
        '/today',
      ),
    );
    expect(alert.at, DateTime(2026, 10, 20, 21));
  });

  testApp('nothing to schedule without reminders', (tester, db) async {
    await tester.runAsync(
      () => HabitRepository(db).createHabit(reading(reminders: [])),
    );
    await pumpApp(tester, db, locale: 'fr');
    await sync(tester);
    expect(scheduler.calls, greaterThan(0));
    expect(scheduler.scheduled, isEmpty);
  });

  testApp('an unchanged plan is not sent again', (tester, db) async {
    final id = (await tester.runAsync(
      () => HabitRepository(db).createHabit(reading()),
    ))!;
    await pumpApp(tester, db, locale: 'fr');
    await sync(tester);
    final calls = scheduler.calls;
    // A past entry changes the history but not the upcoming reminders.
    await tester.runAsync(
      () => HabitRepository(db)
          .setEntry(HabitEntry(habitId: id, day: Day(2026, 10, 5), value: 1)),
    );
    await sync(tester);
    expect(scheduler.calls, calls);
  });
}
