import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

void main() {
  late AppDatabase db;
  late HabitRepository repo;
  final day = Day(2026, 10, 21);

  Habit water() => Habit(
    id: 0,
    name: 'Boire de l’eau',
    type: HabitType.quantity,
    color: HabitColor.sky,
    icon: 'drop',
    goal: 2000,
    step: 250,
    unit: QuantityUnit.liters,
    activeDays: const {1, 2, 3, 4, 5},
    moment: Moment.morning,
    reminders: const [480, 1290],
    streakDangerAlert: false,
    createdOn: day,
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HabitRepository(db);
  });
  tearDown(() => db.close());

  test('a created habit round-trips every field', () async {
    final id = await repo.createHabit(water());
    final h = (await repo.watchHabits().first).single;
    expect(h.id, id);
    expect(h.name, 'Boire de l’eau');
    expect(h.type, HabitType.quantity);
    expect(h.color, HabitColor.sky);
    expect(h.icon, 'drop');
    expect((h.goal, h.step, h.unit), (2000, 250, QuantityUnit.liters));
    expect(h.scheduleMode, ScheduleMode.days);
    expect(h.activeDays, {1, 2, 3, 4, 5});
    expect(h.moment, Moment.morning);
    expect(h.reminders, [480, 1290]);
    expect(h.streakDangerAlert, isFalse);
    expect(h.createdOn, day);
    expect(h.archivedOn, isNull);
    expect(h.pauses, isEmpty);
  });

  test('habits keep their creation order', () async {
    await repo.createHabit(water());
    await repo.createHabit(
      Habit(
        id: 0,
        name: 'Lire',
        type: HabitType.quantity,
        color: HabitColor.mint,
        icon: 'book',
        goal: 20,
        step: 4,
        createdOn: day,
      ),
    );
    expect((await repo.watchHabits().first).map((h) => h.name), [
      'Boire de l’eau',
      'Lire',
    ]);
  });

  test('pauses come back with their habit', () async {
    final id = await repo.createHabit(water());
    await repo.pauseHabit(id, Pause(day, day.addDays(6)));
    final h = (await repo.watchHabits().first).single;
    expect(h.statusOn(day.addDays(3)), DayStatus.paused);
  });

  test('archived habits leave the active list but stay in history', () async {
    final id = await repo.createHabit(water());
    await repo.archiveHabit(id, day.addDays(1));
    expect(await repo.watchHabits().first, isEmpty);
    expect(
      (await repo.watchHabits(includeArchived: true).first).single.archivedOn,
      day.addDays(1),
    );
  });

  test('one entry per habit and day: setting again replaces it', () async {
    final id = await repo.createHabit(water());
    await repo.setEntry(HabitEntry(habitId: id, day: day, value: 250));
    await repo.setEntry(HabitEntry(habitId: id, day: day, value: 500));
    await repo.setEntry(
      HabitEntry(habitId: id, day: day.addDays(1), value: 750),
    );
    final entries = await repo.watchEntries().first;
    expect(entries.map((e) => (e.day, e.value)), [
      (day, 500.0),
      (day.addDays(1), 750.0),
    ]);
  });

  test('journal text and mood are stored', () async {
    final id = await repo.createHabit(water());
    await repo.setEntry(
      HabitEntry(
        habitId: id,
        day: day,
        value: 2,
        note: 'Un café\nLe chapitre 4',
        mood: 2,
      ),
    );
    final e = (await repo.watchEntries().first).single;
    expect((e.note, e.mood), ('Un café\nLe chapitre 4', 2));
  });

  test('clearing an entry undoes it', () async {
    final id = await repo.createHabit(water());
    await repo.setEntry(HabitEntry(habitId: id, day: day, value: 250));
    await repo.clearEntry(id, day);
    expect(await repo.watchEntries().first, isEmpty);
  });

  test('deleting a habit removes its entries and pauses', () async {
    final id = await repo.createHabit(water());
    await repo.setEntry(HabitEntry(habitId: id, day: day, value: 250));
    await repo.pauseHabit(id, Pause(day, day));
    await repo.deleteHabit(id);
    expect(await repo.watchEntries().first, isEmpty);
    expect(await db.select(db.pauses).get(), isEmpty);
  });

  test('joker days are recorded once', () async {
    await repo.useJoker(day);
    await repo.useJoker(day);
    expect(await repo.watchJokerDays().first, {day});
  });

  test('the habit stream emits again after a change', () async {
    final stream = repo.watchHabits();
    expectLater(stream.map((l) => l.length), emitsInOrder([0, 1]));
    await pumpEventQueue();
    await repo.createHabit(water());
  });
}
