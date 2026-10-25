import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rewards.dart';
import 'package:little_steps/core/domain/rules.dart';
import 'package:little_steps/core/feedback/feedback.dart';
import 'package:little_steps/core/theme/motion.dart';
import 'package:little_steps/core/widgets/celebrations.dart';

import '../helpers.dart';

Habit read({ScheduleMode mode = ScheduleMode.days}) => Habit(
  id: 0,
  name: 'Lire',
  type: HabitType.yesNo,
  color: HabitColor.mint,
  icon: 'book',
  goal: 1,
  step: 1,
  createdOn: Day(2026, 10, 1),
  scheduleMode: mode,
  timesPerWeek: 1,
);

final today = Day(2026, 10, 20);

/// The success haptic in tests: no Android version, so the medium fallback.
const success = 'HapticFeedbackType.mediumImpact';

/// Lets the database emit and a few frames run.
Future<void> emit(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// [emit], then the celebration's wait for the +XP flight, without waiting
/// the burst out.
Future<void> frames(WidgetTester tester) async {
  await emit(tester);
  await tester.pump(Motion.flight);
}

/// Waits a burst out.
Future<void> clear(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// A habit done on [days] (day of October 2026), then the app.
Future<int> boot(
  WidgetTester tester,
  AppDatabase db,
  Iterable<int> days, {
  ScheduleMode mode = ScheduleMode.days,
}) async {
  final id = await tester.runAsync(() async {
    final repo = HabitRepository(db);
    final id = await repo.createHabit(read(mode: mode));
    for (final d in days) {
      await repo.setEntry(
        HabitEntry(habitId: id, day: Day(2026, 10, d), value: 1),
      );
    }
    return id;
  });
  await pumpApp(tester, db, locale: 'fr');
  await frames(tester);
  return id!;
}

Future<void> setDone(WidgetTester tester, AppDatabase db, int id, int day) =>
    tester.runAsync(
      () => HabitRepository(db)
          .setEntry(HabitEntry(habitId: id, day: Day(2026, 10, day), value: 1)),
    );

History history(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Celebrations)))
        .read(historyProvider)
        .requireValue;

int celebrates() => sounds.played.where((s) => s == Sound.celebrate).length;

void main() {
  testApp('confetti burst when the day becomes perfect, then it clears', (
    tester,
    db,
  ) async {
    await tester.runAsync(() => HabitRepository(db).createHabit(read()));
    await pumpApp(tester, db, locale: 'fr');
    expect(find.byKey(Celebrations.burstKey), findsNothing);
    await tester.tap(find.text('Lire'));
    await frames(tester);
    expect(find.byKey(Celebrations.burstKey), findsOneWidget);
    await clear(tester);
    expect(find.byKey(Celebrations.burstKey), findsNothing);
  });

  testApp('the day celebrates after the habit, once its +XP has landed', (
    tester,
    db,
  ) async {
    await tester.runAsync(() => HabitRepository(db).createHabit(read()));
    await pumpApp(tester, db, locale: 'fr');
    await tester.tap(find.text('Lire'));
    await emit(tester);
    expect(sounds.played, [Sound.done]);
    expect(find.byKey(Celebrations.burstKey), findsNothing);
    await tester.pump(Motion.flight);
    expect(sounds.played, [Sound.done, Sound.celebrate]);
    expect(find.byKey(Celebrations.burstKey), findsOneWidget);
    await clear(tester);
  });

  testApp('a perfect day celebrates once, even when redone', (
    tester,
    db,
  ) async {
    final id = await boot(tester, db, const []);
    final haptics = recordHaptics(tester);
    await setDone(tester, db, id, 20);
    await frames(tester);
    expect(find.byKey(Celebrations.burstKey), findsOneWidget);
    expect(haptics, contains(success));
    // Becoming perfect also earns 2 badges: one sound for the lot.
    expect(celebrates(), 1);
    await clear(tester);

    await tester.runAsync(() => HabitRepository(db).clearEntry(id, today));
    await frames(tester);
    await setDone(tester, db, id, 20);
    await frames(tester);
    expect(find.byKey(Celebrations.burstKey), findsNothing);
    expect(celebrates(), 1);
    await clear(tester);
  });

  testApp('a level up celebrates', (tester, db) async {
    // Every day up to the 19th but the 6th: level 4.
    final id = await boot(tester, db, [
      for (var d = 1; d <= 19; d++)
        if (d != 6) d,
    ]);
    expect(levelFor(levelXp(history(tester), today)).level, 4);
    final haptics = recordHaptics(tester);
    await setDone(tester, db, id, 6);
    await settle(tester);
    expect(levelFor(levelXp(history(tester), today)).level, 5);
    expect(find.byKey(Celebrations.burstKey), findsNothing);
    expect(haptics, [success]);
    expect(celebrates(), 1);
  });

  testApp('a new badge celebrates', (tester, db) async {
    final id = await boot(tester, db, const []);
    final haptics = recordHaptics(tester);
    // A past day: no perfect today, no level, but the first badges.
    await setDone(tester, db, id, 5);
    await settle(tester);
    expect(earnedBadges(history(tester), today), isNotEmpty);
    expect(haptics, [success]);
    expect(celebrates(), 1);
  });

  testApp('a challenge completed this week celebrates', (tester, db) async {
    // Once a week: done on the 2nd already, so the first badge is old news.
    final id = await boot(tester, db, const [2], mode: ScheduleMode.weekly);
    final haptics = recordHaptics(tester);
    await setDone(tester, db, id, 19);
    await settle(tester);
    expect(
      weeklyChallenges(history(tester), today).where((c) => c.completed),
      isNotEmpty,
    );
    expect(haptics, [success]);
    expect(celebrates(), 1);
  });

  testApp('nothing on launch: perfect today, level 3 or more, badges', (
    tester,
    db,
  ) async {
    final haptics = recordHaptics(tester);
    await boot(tester, db, [for (var d = 1; d <= 20; d++) d]);
    await frames(tester);
    final h = history(tester);
    expect(h.isPerfect(today), isTrue);
    expect(levelFor(levelXp(h, today)).level, greaterThanOrEqualTo(3));
    expect(earnedBadges(h, today), isNotEmpty);
    expect(find.byKey(Celebrations.burstKey), findsNothing);
    expect(haptics, isEmpty);
    expect(sounds.played, isEmpty);
  });
}
