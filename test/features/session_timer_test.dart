import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/time/today_provider.dart';
import 'package:little_steps/features/habit_detail/session_timer.dart';

final today = Day(2026, 10, 20);
final t0 = DateTime(2026, 10, 20, 10);

void main() {
  group('Session', () {
    test('a run starts from the seconds already logged', () {
      final s = Session(day: today, base: 120).start(t0);
      expect(s.running, isTrue);
      expect(s.elapsed(t0.add(const Duration(seconds: 30))), 150);
    });

    test('pause banks the run, resume goes on from there', () {
      final paused = Session(day: today)
          .start(t0)
          .pause(t0.add(const Duration(seconds: 40)));
      expect(paused.running, isFalse);
      expect(paused.elapsed(t0.add(const Duration(hours: 1))), 40);
      final resumed = paused.start(t0.add(const Duration(minutes: 5)));
      expect(
        resumed.elapsed(t0.add(const Duration(minutes: 5, seconds: 2))),
        42,
      );
    });

    test('a run stops at the goal, finished', () {
      final s = Session(day: today, base: 250).start(t0);
      expect(s.tick(t0.add(const Duration(seconds: 49)), 300), same(s));
      final done = s.tick(t0.add(const Duration(seconds: 80)), 300);
      expect(done.running, isFalse);
      expect(done.finished, isTrue);
      expect(done.base, 300);
    });

    test('finish keeps the elapsed time', () {
      final s = Session(day: today)
          .start(t0)
          .finish(t0.add(const Duration(seconds: 90)));
      expect((s.base, s.finished, s.running), (90, true, false));
    });
  });

  group('SessionTimers', () {
    late AppDatabase db;
    late HabitRepository repo;
    late ProviderContainer container;
    late DateTime now;
    late Habit habit;

    Future<double?> stored() async => (await repo.watchEntries().first)
        .where((e) => e.day == today)
        .firstOrNull
        ?.value;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = HabitRepository(db);
      now = t0;
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      final id = await repo.createHabit(
        Habit(
          id: 0,
          name: 'Méditer',
          type: HabitType.duration,
          color: HabitColor.lilac,
          icon: 'lotus',
          goal: 300,
          step: 300,
          createdOn: today.addDays(-3),
        ),
      );
      habit = (await repo.watchHabits().first).singleWhere((h) => h.id == id);
      await repo.setEntry(HabitEntry(habitId: id, day: today, value: 60));
      // Riverpod pauses unlistened providers; the screen listens in the app.
      container.listen(historyProvider, (_, _) {});
      await container.read(historyProvider.future);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    SessionTimers timers() => container.read(sessionTimersProvider.notifier);

    test(
      'start resumes from today’s entry; pause writes the elapsed time',
      () async {
        timers().start(habit);
        now = now.add(const Duration(seconds: 45));
        expect(timers().current(habit).elapsed(now), 105);
        await timers().pause(habit);
        expect(await stored(), 105);
        expect(timers().current(habit).running, isFalse);
      },
    );

    test('reaching the goal stops the run and writes the goal', () async {
      timers().start(habit);
      now = now.add(const Duration(minutes: 10));
      await timers().tick(habit);
      expect(await stored(), 300);
      expect(timers().current(habit).finished, isTrue);
    });

    test('a run going past the day rollover is saved on its own day', () async {
      now = DateTime(2026, 10, 21, 2, 58); // still the 20th (3 am rollover)
      timers().start(habit);
      now = DateTime(2026, 10, 21, 3, 1);
      container.invalidate(todayProvider);
      container.read(todayProvider);
      await pumpEventQueue();
      expect(await stored(), 60 + 180);
      expect(timers().current(habit).day, today.addDays(1));
    });

    test('reset clears today’s entry', () async {
      timers().start(habit);
      await timers().reset(habit);
      expect(await stored(), isNull);
      expect(timers().current(habit).elapsed(now), 0);
    });
  });
}
