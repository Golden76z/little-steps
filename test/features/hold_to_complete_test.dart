import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/widgets/habit_pill.dart';
import 'package:little_steps/features/habit_detail/session_timer.dart';
import 'package:little_steps/core/widgets/rolling_text.dart';

import '../helpers.dart';
import 'today_screen_test.dart' show make, pumpToday, repo, testToday, today;

/// Today's logged values, by habit id.
Future<Map<int, double>> values(WidgetTester tester) async => {
  for (final e in (await tester.runAsync(() => repo.watchEntries().first))!)
    if (e.day == today) e.habitId: e.value,
};

/// Presses [finder], keeps the finger still for [ms], then lifts it.
Future<void> hold(WidgetTester tester, Finder finder, int ms) async {
  final g = await tester.startGesture(tester.getCenter(finder));
  await tester.pump();
  await tester.pump(Duration(milliseconds: ms));
  await g.up();
  await settle(tester);
}

Future<int> glasses(WidgetTester tester, AppDatabase db) async {
  final id = await repo.createHabit(
    make('Verres', HabitType.quantity, goal: 8, step: 1),
  );
  await repo.createHabit(make('Lire', HabitType.yesNo));
  await pumpToday(tester, db);
  return id;
}

void main() {
  testToday('a 900 ms hold on a quantity at 0/8 writes the goal', (
    tester,
    db,
  ) async {
    final id = await glasses(tester, db);
    await hold(tester, find.text('Verres'), 900);
    expect(await values(tester), {id: 8});
    expect(find.text('100 %'), findsOneWidget);
  });

  testToday('letting go at 400 ms writes nothing', (tester, db) async {
    await glasses(tester, db);
    await hold(tester, find.text('Verres'), 400);
    expect(await values(tester), isEmpty);
  });

  testToday('a tap still adds one step', (tester, db) async {
    final id = await glasses(tester, db);
    await tester.tap(find.text('Verres'));
    await settle(tester);
    expect(await values(tester), {id: 1});
  });

  testToday('no hold on a done pill, a journal or a future day', (
    tester,
    db,
  ) async {
    final read = await repo.createHabit(make('Lire', HabitType.yesNo));
    await repo.createHabit(
      make('Journal', HabitType.journal, goal: 3, step: 1),
    );
    await repo.createHabit(make('Verres', HabitType.quantity, goal: 8));
    await repo.setEntry(HabitEntry(habitId: read, day: today, value: 1));
    await pumpToday(tester, db);
    await hold(tester, find.text('Lire'), 900);
    await hold(tester, find.text('Journal'), 900);
    expect(await values(tester), {read: 1});
    expect(find.text('Journal'), findsOneWidget); // no detail opened
    await tester.tap(find.text('21'));
    await tester.pumpAndSettle();
    await hold(tester, find.text('Verres'), 900);
    expect(await values(tester), {read: 1});
  });

  testToday('a slow 300 ms tap on a done pill still unchecks it', (
    tester,
    db,
  ) async {
    final read = await repo.createHabit(make('Lire', HabitType.yesNo));
    await repo.setEntry(HabitEntry(habitId: read, day: today, value: 1));
    await pumpToday(tester, db);
    await hold(tester, find.text('Lire'), 300);
    expect((await values(tester))[read] ?? 0, 0);
  });

  testToday('pill numbers roll with a direction, so a drop comes from above', (
    tester,
    db,
  ) async {
    await glasses(tester, db);
    final rolling = tester.widgetList<RollingText>(
      find.descendant(
        of: find.byType(HabitPill),
        matching: find.byType(RollingText),
      ),
    );
    expect(rolling, isNotEmpty);
    for (final r in rolling) {
      expect(r.value, isNotNull);
    }
  });

  testToday('a hold during a running session is not undone by its pause', (
    tester,
    db,
  ) async {
    final id = await repo.createHabit(
      make('Méditer', HabitType.duration, goal: 600, step: 300),
    );
    await repo.createHabit(make('Lire', HabitType.yesNo));
    await pumpToday(tester, db);
    final container = ProviderScope.containerOf(
      tester.element(find.text('Méditer')),
    );
    final habit = container
        .read(historyProvider)
        .value!
        .habits
        .firstWhere((h) => h.id == id);
    final timers = container.read(sessionTimersProvider.notifier);
    timers.start(habit);
    await tester.pump();
    await hold(tester, find.text('Méditer'), 900);
    unawaited(timers.pause(habit));
    await settle(tester);
    expect((await values(tester))[id], 600);
  });

  testToday('a finger that starts scrolling never completes', (
    tester,
    db,
  ) async {
    await glasses(tester, db);
    final g = await tester.startGesture(tester.getCenter(find.text('Verres')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await g.moveBy(const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 700));
    await g.up();
    await settle(tester);
    expect(await values(tester), isEmpty);
  });

  testToday('with reduced motion, a hold still completes at the threshold', (
    tester,
    db,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final id = await glasses(tester, db);
    await hold(tester, find.text('Verres'), 900);
    expect(await values(tester), {id: 8});
  });

  testToday('a long press on the icon opens the options, not on the pill', (
    tester,
    db,
  ) async {
    await glasses(tester, db);
    await tester.longPress(find.text('Lire'));
    await settle(tester);
    expect(find.text('Archiver'), findsNothing);
    await tester.longPress(find.bySemanticsLabel('Lire, ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Archiver'), findsOneWidget);
  });

  testToday('Complete and Options semantics actions work', (tester, db) async {
    final handle = tester.ensureSemantics();
    final id = await glasses(tester, db);
    final pill = find.semantics.byLabel(RegExp('^Verres, 0'));
    tester.semantics.customAction(
      pill,
      const CustomSemanticsAction(label: 'Compléter'),
    );
    await settle(tester);
    expect(await values(tester), {id: 8});
    tester.semantics.customAction(
      find.semantics.byLabel(RegExp('^Lire, 0')),
      const CustomSemanticsAction(label: 'Options'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Archiver'), findsOneWidget);
    handle.dispose();
  });
}
