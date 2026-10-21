import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/features/create_habit/habit_draft.dart';

import '../domain/fixtures.dart';

void main() {
  final today = Day(2026, 10, 20);

  group('defaults per type', () {
    test('quantity starts at 8 glasses, one glass per tap', () {
      final d = HabitDraft.forType(HabitType.quantity);
      expect((d.unit, d.goal, d.step), (QuantityUnit.glasses, 2000.0, 250.0));
      expect(d.color, HabitColor.sky);
    });

    test('duration 10 min, journal 3 lines, yes/no and frequency 1', () {
      expect(HabitDraft.forType(HabitType.duration).goal, 600);
      expect(HabitDraft.forType(HabitType.journal).goal, 3);
      expect(HabitDraft.forType(HabitType.yesNo).goal, 1);
      expect(HabitDraft.forType(HabitType.frequency).goal, 1);
    });

    test('frequency is always weekly', () {
      final d = HabitDraft.forType(HabitType.frequency)
          .withScheduleMode(ScheduleMode.days);
      expect(d.scheduleMode, ScheduleMode.weekly);
    });
  });

  group('presets', () {
    test('drink water: litres, 2 L, 25 cl, drop, sky', () {
      final d = HabitDraft.fromPreset(Preset.water, name: 'Boire de l’eau');
      expect(
        (d.type, d.unit, d.goal, d.step, d.icon, d.color, d.name),
        (
          HabitType.quantity,
          QuantityUnit.liters,
          2000.0,
          250.0,
          'drop',
          HabitColor.sky,
          'Boire de l’eau',
        ),
      );
    });

    test('run is 3 times a week, vitamins in the morning', () {
      expect(HabitDraft.fromPreset(Preset.run, name: 'x').timesPerWeek, 3);
      expect(
        HabitDraft.fromPreset(Preset.vitamins, name: 'x').moment,
        Moment.morning,
      );
    });
  });

  group('goal', () {
    test('steps by the unit increment and stays positive', () {
      var d = HabitDraft.forType(HabitType.quantity)
          .withUnit(QuantityUnit.liters);
      expect(d.incGoal().goal, 2250);
      d = d.copyWith(goal: 250);
      expect(d.decGoal().goal, 250);
    });

    test('duration moves by 5 minutes, journal by one line within 1–5', () {
      final dur = HabitDraft.forType(HabitType.duration);
      expect(dur.incGoal().goal, 900);
      final j = HabitDraft.forType(HabitType.journal);
      expect(j.copyWith(goal: 5).incGoal().goal, 5);
      expect(j.copyWith(goal: 1).decGoal().goal, 1);
    });
  });

  group('units', () {
    test('switching within volumes keeps the goal, resets the step', () {
      final d = HabitDraft.forType(HabitType.quantity)
          .copyWith(goal: 1500, step: 500)
          .withUnit(QuantityUnit.liters);
      expect((d.goal, d.step), (1500.0, 250.0));
    });

    test('switching family resets goal and step to the unit defaults', () {
      final d = HabitDraft.forType(HabitType.quantity)
          .withUnit(QuantityUnit.kilometers);
      expect((d.goal, d.step), (5000.0, 500.0));
    });

    test('each unit offers three quick steps', () {
      for (final u in QuantityUnit.values) {
        expect(u.stepPresets, hasLength(3), reason: u.name);
      }
    });
  });

  group('schedule', () {
    test('at least one active day is kept', () {
      final d = HabitDraft.forType(HabitType.yesNo).copyWith(activeDays: {3});
      expect(d.toggleDay(3).activeDays, {3});
      expect(d.toggleDay(5).activeDays, {3, 5});
    });

    test('times per week stays within 1–7', () {
      final d = HabitDraft.forType(HabitType.frequency);
      expect(d.copyWith(timesPerWeek: 7).withTimesPerWeek(8).timesPerWeek, 7);
      expect(d.withTimesPerWeek(0).timesPerWeek, 1);
    });

    test('default reminder follows the moment until edited', () {
      var d = HabitDraft.forType(HabitType.yesNo);
      expect(d.reminders, isEmpty); // anytime
      d = d.withMoment(Moment.morning);
      expect(d.reminders, [480]);
      d = d.withMoment(Moment.evening);
      expect(d.reminders, [1200]);
      d = d.withReminderAdded(14 * 60).withMoment(Moment.noon);
      expect(d.reminders, [840, 1200]);
    });

    test('reminders stay sorted and unique', () {
      final d = HabitDraft.forType(HabitType.yesNo)
          .withReminderAdded(840)
          .withReminderAdded(480)
          .withReminderAdded(840);
      expect(d.reminders, [480, 840]);
      expect(d.withReminderRemoved(480).reminders, [840]);
    });
  });

  group('build and edit', () {
    test('builds a habit created today', () {
      final h = HabitDraft.fromPreset(
        Preset.water,
        name: '  Eau  ',
      ).build(today);
      expect(
        (h.name, h.createdOn, h.type, h.unit),
        ('Eau', today, HabitType.quantity, QuantityUnit.liters),
      );
    });

    test('a name is required', () {
      expect(HabitDraft.forType(HabitType.yesNo).isValid, isFalse);
      expect(
        HabitDraft.forType(HabitType.yesNo).copyWith(name: ' x ').isValid,
        isTrue,
      );
    });

    test('editing keeps id, creation day, archive and pauses', () {
      final original = habit(
        id: 7,
        createdOn: today.addDays(-10),
        pauses: [Pause(today, today)],
      );
      final edited = HabitDraft.fromHabit(original)
          .copyWith(name: 'Lire plus')
          .build(today);
      expect(
        (edited.id, edited.createdOn, edited.pauses.length, edited.name),
        (7, today.addDays(-10), 1, 'Lire plus'),
      );
    });
  });

  test('free plan allows 5 active habits', () {
    expect(canCreateHabit(4), isTrue);
    expect(canCreateHabit(5), isFalse);
  });
}
