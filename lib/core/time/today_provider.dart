import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers.dart';
import '../domain/day.dart';

final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// Hour the logical day starts (0–6), set in Profile; 3 am by default.
final rolloverHourProvider = Provider<int>(
  (ref) =>
      int.tryParse(ref.watch(settingProvider(rolloverHourKey)).value ?? '') ??
      3,
);

const rolloverHourKey = 'rolloverHour';

/// The current logical day; rebuilds itself at the next rollover.
final todayProvider = NotifierProvider<TodayNotifier, Day>(TodayNotifier.new);

class TodayNotifier extends Notifier<Day> {
  @override
  Day build() {
    final now = ref.watch(clockProvider)();
    final hour = ref.watch(rolloverHourProvider);
    var next = DateTime(now.year, now.month, now.day, hour);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month, now.day + 1, hour);
    }
    // A timer due while the phone slept fires on wake, so resume is covered.
    final timer = Timer(next.difference(now), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
    return logicalDay(now, rolloverHour: hour);
  }
}
