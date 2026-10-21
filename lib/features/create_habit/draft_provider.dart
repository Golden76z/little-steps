import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/habit.dart';
import 'habit_draft.dart';

/// The habit being created or edited; set before opening P2.
final draftProvider = NotifierProvider<DraftNotifier, HabitDraft>(
  DraftNotifier.new,
);

class DraftNotifier extends Notifier<HabitDraft> {
  @override
  HabitDraft build() => HabitDraft.forType(HabitType.quantity);

  void set(HabitDraft draft) => state = draft;

  void update(HabitDraft Function(HabitDraft) change) => state = change(state);
}
