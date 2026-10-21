import 'habit.dart';

/// What tapping a habit pill does, given today's value.
sealed class QuickAction {
  const QuickAction();
}

final class SetValue extends QuickAction {
  const SetValue(this.value);

  final double value;

  @override
  bool operator ==(Object other) => other is SetValue && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SetValue($value)';
}

final class OpenDetail extends QuickAction {
  const OpenDetail({required this.startTimer});

  final bool startTimer;

  @override
  bool operator ==(Object other) =>
      other is OpenDetail && other.startTimer == startTimer;

  @override
  int get hashCode => startTimer.hashCode;

  @override
  String toString() => 'OpenDetail(startTimer: $startTimer)';
}

QuickAction quickAction(Habit h, double current) => switch (h.type) {
  HabitType.quantity => SetValue(current + h.step),
  HabitType.yesNo || HabitType.frequency => SetValue(current >= 1 ? 0 : 1),
  HabitType.duration => const OpenDetail(startTimer: true),
  HabitType.journal => const OpenDetail(startTimer: false),
};
