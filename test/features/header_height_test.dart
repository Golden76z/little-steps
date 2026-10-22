import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/widgets/app_header_card.dart';

import '../helpers.dart';

Habit make(
  String name,
  HabitType type, {
  QuantityUnit? unit,
  double goal = 1,
}) => Habit(
  id: 0,
  name: name,
  type: type,
  color: HabitColor.sky,
  icon: 'drop',
  goal: goal,
  step: 1,
  unit: unit,
  reminders: const [480],
  createdOn: Day(2026, 10, 1),
);

void main() {
  testApp('every header card has the same height', (tester, db) async {
    await tester.runAsync(() async {
      final repo = HabitRepository(db);
      await repo.createHabit(make('Lire', HabitType.yesNo));
      await repo.createHabit(
        make('Pages', HabitType.quantity, unit: QuantityUnit.pages, goal: 20),
      );
    });
    await pumpApp(tester, db, locale: 'fr');
    double header() => tester.getSize(find.byType(AppHeaderCard).last).height;
    final heights = <String, double>{'today': header()};
    for (final tab in ['Progrès', 'Trophées', 'Profil']) {
      await tester.tap(find.bySemanticsLabel(tab));
      await tester.pumpAndSettle();
      heights[tab] = header();
    }
    await tester.tap(find.bySemanticsLabel('Aujourd’hui'));
    await tester.pumpAndSettle();
    for (final name in ['Lire', 'Pages']) {
      await tester.tap(find.bySemanticsLabel('$name, ouvrir'));
      await tester.pumpAndSettle();
      heights['detail $name'] = header();
      await tester.tap(find.bySemanticsLabel('Retour'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.bySemanticsLabel('Nouvelle habitude'));
    await tester.pumpAndSettle();
    heights['create'] = header();
    await tester.tap(find.bySemanticsLabel('Fermer'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Profil'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Rappels'));
    await tester.tap(find.text('Rappels'));
    await tester.pumpAndSettle();
    heights['reminders'] = header();
    expect(heights.values.toSet(), hasLength(1), reason: '$heights');
  });
}
