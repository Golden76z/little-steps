import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';

import '../helpers.dart';
import 'profile_screen_test.dart' show openProfile;

/// Saves nothing: every reorder fails.
class FailingReorder extends HabitRepository {
  FailingReorder(super.db);

  @override
  Future<void> reorder(List<int> ids) async => throw StateError('disk full');
}

Future<void> dragSportUp(WidgetTester tester) async {
  final handle = find.bySemanticsLabel('Déplacer Sport');
  final gesture = await tester.startGesture(tester.getCenter(handle));
  for (var i = 0; i < 10; i++) {
    await gesture.moveBy(const Offset(0, -12));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await settle(tester);
}

void main() {
  testApp('dragging a habit changes its order everywhere', (tester, db) async {
    await openProfile(tester, db);
    await tester.tap(find.text('Organiser mes habitudes'));
    await tester.pumpAndSettle();
    expect(find.text('Organiser mes habitudes'), findsOneWidget);
    final handle = find.bySemanticsLabel('Déplacer Sport');
    expect(tester.getSize(handle), const Size(48, 48));
    final haptics = recordHaptics(tester);

    final gesture = await tester.startGesture(tester.getCenter(handle));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -12));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await settle(tester);

    final habits = await tester.runAsync(
      () => HabitRepository(db).watchHabits().first,
    );
    expect(habits!.map((h) => h.name), ['Sport', 'Lire']);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
  });

  testApp('a reorder that fails puts the stored order back', (
    tester,
    db,
  ) async {
    await openProfile(
      tester,
      db,
      overrides: [
        habitRepositoryProvider.overrideWithValue(FailingReorder(db)),
      ],
    );
    await tester.tap(find.text('Organiser mes habitudes'));
    await tester.pumpAndSettle();
    await dragSportUp(tester);
    final names = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .where((s) => s == 'Lire' || s == 'Sport')
        .toList();
    expect(names, ['Lire', 'Sport']);
  });
}
