import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/widgets/placeholder_screen.dart';

// ponytail: stand-in until the per-type detail screens (T1–T5, step 5).
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
    return Scaffold(
      appBar: AppBar(),
      body: PlaceholderScreen(title: habit?.name ?? ''),
    );
  }
}
