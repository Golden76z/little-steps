import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/habit.dart';

import 'fixtures.dart';

void main() {
  group('progress', () {
    test('is value over goal', () {
      expect(habit(goal: 2000).progress(500), 0.25);
    });

    test('is capped at 1', () {
      expect(habit(goal: 20).progress(28), 1);
    });

    test('never goes below 0', () {
      expect(habit(goal: 3).progress(-1), 0);
    });

    test('completion means reaching the goal', () {
      final h = habit(goal: 3);
      expect(h.isCompleted(2), isFalse);
      expect(h.isCompleted(3), isTrue);
    });
  });

  group('statusOn', () {
    test('a scheduled day is due', () {
      expect(habit().statusOn(monday), DayStatus.due);
    });

    test('an inactive weekday is rest', () {
      final h = habit(activeDays: {1, 2, 3, 4, 5});
      expect(h.statusOn(monday.addDays(5)), DayStatus.rest);
      expect(h.statusOn(monday.addDays(4)), DayStatus.due);
    });

    test('a weekly habit is flexible every day', () {
      expect(
        habit(mode: ScheduleMode.weekly).statusOn(monday),
        DayStatus.flexible,
      );
    });

    test('a pause covers its bounds inclusively', () {
      final h = habit(pauses: [Pause(monday, monday.addDays(6))]);
      expect(h.statusOn(monday), DayStatus.paused);
      expect(h.statusOn(monday.addDays(6)), DayStatus.paused);
      expect(h.statusOn(monday.addDays(7)), DayStatus.due);
    });

    test('pause wins over rest', () {
      final h = habit(activeDays: {1}, pauses: [Pause(monday, monday)]);
      expect(h.statusOn(monday), DayStatus.paused);
    });

    test('untracked before creation and from archiving on', () {
      final h = habit(createdOn: monday, archivedOn: monday.addDays(3));
      expect(h.statusOn(monday.addDays(-1)), DayStatus.untracked);
      expect(h.statusOn(monday.addDays(2)), DayStatus.due);
      expect(h.statusOn(monday.addDays(3)), DayStatus.untracked);
    });
  });
}
