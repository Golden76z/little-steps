import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/time/today_provider.dart';

/// One duration habit's session on [day], in seconds. Time is read from
/// the wall clock, so a run goes on while the screen or the app is away.
@immutable
final class Session {
  const Session({
    required this.day,
    this.base = 0,
    this.startedAt,
    this.finished = false,
  });

  final Day day;

  /// Seconds banked before [startedAt].
  final int base;

  /// Start of the current run; null while paused.
  final DateTime? startedAt;
  final bool finished;

  bool get running => startedAt != null;

  int elapsed(DateTime now) =>
      base + (startedAt == null ? 0 : now.difference(startedAt!).inSeconds);

  Session start(DateTime now) => Session(day: day, base: base, startedAt: now);

  Session pause(DateTime now) => Session(day: day, base: elapsed(now));

  Session finish(DateTime now) =>
      Session(day: day, base: elapsed(now), finished: true);

  /// Stops at [goal] once a run reaches it.
  Session tick(DateTime now, int goal) => running && elapsed(now) >= goal
      ? Session(day: day, base: goal, finished: true)
      : this;
}

/// Open sessions by habit id. Not auto-disposed: a run outlives the detail
/// screen, and is lost with the process.
final sessionTimersProvider =
    NotifierProvider<SessionTimers, Map<int, Session>>(SessionTimers.new);

class SessionTimers extends Notifier<Map<int, Session>> {
  /// Fires when a run reaches the goal, even with no screen watching.
  final _alarms = <int, Timer>{};

  @override
  Map<int, Session> build() {
    ref.onDispose(() {
      for (final t in _alarms.values) {
        t.cancel();
      }
    });
    // A run still going at the rollover is banked on the day it started.
    ref.listen(todayProvider, (_, today) {
      for (final MapEntry(key: id, value: s) in state.entries) {
        if (s.day == today || !s.running) continue;
        _alarms.remove(id)?.cancel();
        ref
            .read(habitRepositoryProvider)
            .setEntry(
              HabitEntry(habitId: id, day: s.day, value: s.elapsed(_now) * 1.0),
            );
      }
      state = {
        for (final MapEntry(:key, :value) in state.entries)
          if (value.day == today) key: value,
      };
    });
    return const {};
  }

  DateTime get _now => ref.read(clockProvider)();

  /// Today's session of [h]; without an open one, what is logged today.
  Session current(Habit h) {
    final today = ref.read(todayProvider);
    final open = state[h.id];
    if (open != null && open.day == today) return open;
    final stored =
        ref.read(historyProvider).value?.valueOf(h.id, today).toInt() ?? 0;
    return Session(day: today, base: stored, finished: stored >= h.goal);
  }

  void start(Habit h) {
    final s = current(h);
    if (!s.running && !s.finished) _set(h, s.start(_now));
  }

  // Both tick first, so a run past the goal (late clock) logs the goal.
  Future<void> pause(Habit h) async {
    await tick(h);
    if (current(h).running) await _write(h, current(h).pause(_now));
  }

  Future<void> finish(Habit h) async {
    await tick(h);
    await _write(h, current(h).finish(_now));
  }

  /// "Already done": logs the whole goal.
  Future<void> markDone(Habit h) => _write(
    h,
    Session(day: current(h).day, base: h.goal.toInt(), finished: true),
  );

  Future<void> reset(Habit h) async {
    final day = current(h).day;
    _set(h, Session(day: day));
    await ref.read(habitRepositoryProvider).clearEntry(h.id, day);
  }

  /// Ends a run that reached the goal by the clock.
  Future<void> tick(Habit h) async {
    final s = current(h);
    final next = s.tick(_now, h.goal.toInt());
    if (!identical(next, s)) await _write(h, next);
  }

  /// After a goal change: a run re-arms on the new goal, a stopped session
  /// falls back to what is logged.
  Future<void> goalChanged(Habit h) async {
    final s = state[h.id];
    if (s == null) return;
    if (s.running) {
      _set(h, s);
      await tick(h);
    } else {
      state = {...state}..remove(h.id);
    }
  }

  void _set(Habit h, Session s) {
    _alarms.remove(h.id)?.cancel();
    if (s.running) {
      final left = math.max(0, h.goal.toInt() - s.elapsed(_now));
      _alarms[h.id] = Timer(Duration(seconds: left), () {
        if (current(h).running) markDone(h);
      });
    }
    state = {...state, h.id: s};
  }

  Future<void> _write(Habit h, Session s) {
    _set(h, s);
    return ref
        .read(habitRepositoryProvider)
        .setEntry(HabitEntry(habitId: h.id, day: s.day, value: s.base * 1.0));
  }
}
