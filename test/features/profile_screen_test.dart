import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/feedback/feedback.dart';
import 'package:little_steps/features/profile/profile_screen.dart';
import 'package:little_steps/core/time/today_provider.dart';

import '../helpers.dart';

Habit yesNo(String name, Day createdOn, List<int> reminders) => Habit(
  id: 0,
  name: name,
  type: HabitType.yesNo,
  color: HabitColor.mint,
  icon: 'book',
  goal: 1,
  step: 1,
  reminders: reminders,
  createdOn: createdOn,
);

/// Lire since 15 August (07:30, 21:00), Sport since 1 September (07:30).
/// Both done 2–5 September and 19–20 October, Lire also on 18 October:
/// streak 2, record 4, 13 pills filled, 6 perfect days (no joker yet).
Future<void> openProfile(
  WidgetTester tester,
  AppDatabase db, {
  List<Override> overrides = const [],
}) async {
  // The mockup's 390 × 844 screen, so every row clears the floating bar.
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final repo = HabitRepository(db);
  await tester.runAsync(() async {
    final read = await repo.createHabit(
      yesNo('Lire', Day(2026, 8, 15), const [7 * 60 + 30, 21 * 60]),
    );
    final sport = await repo.createHabit(
      yesNo('Sport', Day(2026, 9, 1), const [7 * 60 + 30]),
    );
    final both = [
      for (var d = 2; d <= 5; d++) Day(2026, 9, d),
      Day(2026, 10, 19),
      Day(2026, 10, 20),
    ];
    for (final day in both) {
      for (final id in [read, sport]) {
        await repo.setEntry(HabitEntry(habitId: id, day: day, value: 1));
      }
    }
    await repo.setEntry(
      HabitEntry(habitId: read, day: Day(2026, 10, 18), value: 1),
    );
  });
  await pumpApp(tester, db, locale: 'fr', overrides: overrides);
  await tester.tap(find.bySemanticsLabel('Profil'));
  await settle(tester);
}

void main() {
  testApp('header: name placeholder, member since and stats', (
    tester,
    db,
  ) async {
    await openProfile(tester, db);
    expect(find.text('Ton prénom'), findsOneWidget);
    expect(find.text('Membre depuis août 2026'), findsOneWidget);
    expect(find.text('2 j'), findsOneWidget);
    expect(find.text('4 j'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);
    expect(find.text('pilules remplies'), findsOneWidget);
  });

  testApp('the gear edits the first name, which is stored', (tester, db) async {
    await openProfile(tester, db);
    await tester.tap(find.bySemanticsLabel('Réglages'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Damien ');
    await tester.tap(find.text('Enregistrer'));
    await settle(tester);
    expect(find.text('Damien'), findsOneWidget);
    expect(
      await tester.runAsync(() => HabitRepository(db).getSetting('firstName')),
      'Damien',
    );
  });

  testApp('settings rows show their values', (tester, db) async {
    await openProfile(tester, db);
    expect(find.text('07:30 · 21:00'), findsOneWidget);
    expect(find.text('Sorbet'), findsOneWidget);
    expect(find.text('JSON'), findsOneWidget);
    expect(find.text('Bientôt'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget);
  });

  for (final label in ['Thème', 'Essayer']) {
    testApp('$label opens Premium', (tester, db) async {
      await openProfile(tester, db);
      if (label != 'Essayer') {
        // Scroll the last rows clear of the floating bar.
        await tester.drag(find.text('Sorbet'), const Offset(0, -300));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.text('Little Steps Premium'), findsOneWidget);
    });
  }

  testApp('the dark mode switch is off and disabled', (tester, db) async {
    await openProfile(tester, db);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Mode sombre')),
      isSemantics(
        hasToggledState: true,
        isToggled: false,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
  });

  for (final (label, key) in [
    ('Vibrations', hapticsKey),
    ('Sons', soundsKey),
  ]) {
    testApp('the $label switch is on by default and persists', (
      tester,
      db,
    ) async {
      await openProfile(tester, db);
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        isSemantics(hasToggledState: true, isToggled: true),
      );
      await tester.tap(find.bySemanticsLabel(label));
      await settle(tester);
      expect(
        await tester.runAsync(() => HabitRepository(db).getSetting(key)),
        '0',
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        isSemantics(hasToggledState: true, isToggled: false),
      );
    });
  }

  testApp('once sounds are off, a completion plays nothing', (
    tester,
    db,
  ) async {
    await openProfile(tester, db);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileScreen)),
    );
    container.read(feedbackProvider).sound(Sound.done);
    await tester.pump();
    expect(sounds.played, [Sound.done]);
    sounds.played.clear();
    await tester.tap(find.bySemanticsLabel('Sons'));
    await settle(tester);
    container.read(feedbackProvider).sound(Sound.done);
    await tester.pump();
    expect(sounds.played, isEmpty);
  });

  testApp('the day start moves to 5 am', (tester, db) async {
    await openProfile(tester, db);
    // Scroll the last row clear of the floating bar.
    await tester.drag(find.text('Sorbet'), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Début de la journée'));
    await tester.pumpAndSettle();
    expect(
      find.text('Jusqu’à cette heure, la nuit compte encore pour la veille.'),
      findsOneWidget,
    );
    await tester.tap(find.text('05:00'));
    await settle(tester);
    expect(find.text('05:00'), findsOneWidget);
    expect(
      await tester.runAsync(
        () => HabitRepository(db).getSetting(rolloverHourKey),
      ),
      '5',
    );
  });

  testApp('Reminders lists each habit and opens its sheet', (tester, db) async {
    await openProfile(tester, db);
    await tester.tap(find.text('Rappels'));
    await tester.pumpAndSettle();
    expect(find.text('Lire'), findsOneWidget);
    expect(find.text('07:30 · 21:00'), findsOneWidget);
    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('07:30'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tester.tap(find.text('Sport'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Modifier l’habitude'), findsOneWidget);
  });

  testApp('tap targets meet the guideline', (tester, db) async {
    await openProfile(tester, db);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testApp('text at 200 % lays out without overflow', (tester, db) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openProfile(tester, db);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Rappels'), 100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rappels'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
