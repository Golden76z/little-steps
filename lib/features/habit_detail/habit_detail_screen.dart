import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/domain/habit.dart';
import 'duration_detail.dart';
import 'frequency_detail.dart';
import 'journal_detail.dart';
import 'quantity_detail.dart';
import 'yes_no_detail.dart';

/// Opens the detail screen of the habit's type (T1–T5).
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({
    super.key,
    required this.habitId,
    this.startTimer = false,
  });

  final int habitId;

  /// Duration habits open with the timer running.
  final bool startTimer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref
        .watch(habitsProvider)
        .value
        ?.where((h) => h.id == habitId)
        .firstOrNull;
    if (habit == null) return const Scaffold();
    return switch (habit.type) {
      HabitType.quantity => QuantityDetail(habit: habit),
      HabitType.duration => DurationDetail(
        habit: habit,
        startTimer: startTimer,
      ),
      HabitType.yesNo => YesNoDetail(habit: habit),
      HabitType.journal => JournalDetail(habit: habit),
      HabitType.frequency => FrequencyDetail(habit: habit),
    };
  }
}
