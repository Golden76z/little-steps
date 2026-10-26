import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/rules.dart';

/// Values written from Today but not back from the database yet, so a pill
/// fills on the frame of the tap. Each one goes when the history confirms
/// it, or when its write fails.
final pendingEntriesProvider =
    NotifierProvider<PendingEntries, Map<(int, Day), double>>(
      PendingEntries.new,
    );

class PendingEntries extends Notifier<Map<(int, Day), double>> {
  /// Writes not finished yet, per key: a history read meanwhile is stale.
  final _writing = <(int, Day), int>{};

  @override
  Map<(int, Day), double> build() {
    ref.watch(dataReplacedProvider);
    ref.listen(historyProvider, (_, next) {
      if (next.value case final history?) _confirm(history);
    });
    return const {};
  }

  void _confirm(History history) {
    final left = {
      for (final MapEntry(:key, :value) in state.entries)
        if ((_writing[key] ?? 0) > 0 ||
            history.valueOf(key.$1, key.$2) != value)
          key: value,
    };
    if (left.length != state.length) state = left;
  }

  /// Shows [value] for habit [id] on [day] at once, then stores it (0
  /// clears the entry).
  Future<void> set(int id, Day day, double value) async {
    final key = (id, day);
    state = {...state, key: value};
    final repo = ref.read(habitRepositoryProvider);
    _writing[key] = (_writing[key] ?? 0) + 1;
    try {
      await (value == 0
          ? repo.clearEntry(id, day)
          : repo.setEntry(HabitEntry(habitId: id, day: day, value: value)));
    } catch (e) {
      debugPrint('Entry not saved: $e');
      // Back to the stored value, unless a newer tap took over.
      if (state[key] == value) state = {...state}..remove(key);
      return;
    } finally {
      _writing[key] = _writing[key]! - 1;
    }
    // Unchanged in the database: no new history comes to confirm it.
    if (ref.read(historyProvider).value case final history?) {
      _confirm(history);
    }
  }
}
