import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/widgets/perfect_day_confetti.dart';

import '../helpers.dart';

Habit read() => Habit(
  id: 0,
  name: 'Lire',
  type: HabitType.yesNo,
  color: HabitColor.mint,
  icon: 'book',
  goal: 1,
  step: 1,
  createdOn: Day(2026, 10, 1),
);

/// Lets the database emit and a few frames run, without waiting the burst out.
Future<void> frames(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testApp('confetti burst when the day becomes perfect, then it clears', (
    tester,
    db,
  ) async {
    await tester.runAsync(() => HabitRepository(db).createHabit(read()));
    await pumpApp(tester, db, locale: 'fr');
    expect(find.byKey(PerfectDayConfetti.burstKey), findsNothing);
    await tester.tap(find.text('Lire'));
    await frames(tester);
    expect(find.byKey(PerfectDayConfetti.burstKey), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byKey(PerfectDayConfetti.burstKey), findsNothing);
  });

  testApp('no confetti for a day already perfect at launch', (
    tester,
    db,
  ) async {
    await tester.runAsync(() async {
      final repo = HabitRepository(db);
      final id = await repo.createHabit(read());
      await repo.setEntry(
        HabitEntry(habitId: id, day: Day(2026, 10, 20), value: 1),
      );
    });
    await pumpApp(tester, db, locale: 'fr');
    await frames(tester);
    expect(find.byKey(PerfectDayConfetti.burstKey), findsNothing);
  });
}
