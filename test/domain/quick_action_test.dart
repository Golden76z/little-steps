import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/quick_action.dart';

import 'fixtures.dart';

void main() {
  test('quantity adds one step, past the goal too', () {
    final water = habit(type: HabitType.quantity, goal: 2000, step: 250);
    expect(quickAction(water, 1750), const SetValue(2000));
    expect(quickAction(water, 2000), const SetValue(2250));
  });

  test('yes/no and frequency toggle today', () {
    for (final type in [HabitType.yesNo, HabitType.frequency]) {
      expect(quickAction(habit(type: type), 0), const SetValue(1));
      expect(quickAction(habit(type: type), 1), const SetValue(0));
    }
  });

  test('duration opens the detail with the timer running', () {
    expect(
      quickAction(habit(type: HabitType.duration, goal: 600), 0),
      const OpenDetail(startTimer: true),
    );
  });

  test('journal opens the detail to write', () {
    expect(
      quickAction(habit(type: HabitType.journal, goal: 3), 1),
      const OpenDetail(startTimer: false),
    );
  });
}
