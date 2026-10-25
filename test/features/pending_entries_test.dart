import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rules.dart';
import 'package:little_steps/features/today/pending_entries.dart';

/// Writes that finish only when the test says so.
class SlowRepository extends HabitRepository {
  SlowRepository(super.db);

  final writes = <Completer<void>>[];

  Future<void> _next() => (writes..add(Completer())).last.future;

  @override
  Future<void> setEntry(HabitEntry e) => _next();

  @override
  Future<void> clearEntry(int habitId, Day day) => _next();
}

void main() {
  test(
    'a write landing before the history refreshes keeps the newer tap',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = SlowRepository(db);
      final day = Day(2026, 10, 20);
      final stored = History(habits: const [], entries: const []);
      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repo),
          historyProvider.overrideWith((ref) async => stored),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      container.listen(pendingEntriesProvider, (_, _) {});
      await container.read(historyProvider.future);
      final pending = container.read(pendingEntriesProvider.notifier);

      final check = pending.set(1, day, 1);
      final uncheck = pending.set(1, day, 0);
      // The check lands; the history still says 0, as the uncheck wants, but
      // the uncheck itself is not stored yet.
      repo.writes[0].complete();
      await check;
      expect(container.read(pendingEntriesProvider), {(1, day): 0});

      repo.writes[1].complete();
      await uncheck;
      expect(container.read(pendingEntriesProvider), isEmpty);
    },
  );
}
