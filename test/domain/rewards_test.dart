import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rewards.dart';
import 'package:little_steps/core/domain/rules.dart';

import 'fixtures.dart';

List<HabitEntry> done(Habit h, Iterable<int> offsets, {double? value}) => [
  for (final o in offsets)
    HabitEntry(habitId: h.id, day: monday.addDays(o), value: value ?? h.goal),
];

Iterable<int> range(int a, int b) => [for (var i = a; i <= b; i++) i];

void main() {
  final today = monday.addDays(6); // Sunday 25 October

  group('badges', () {
    Set<Badge> earnedOf(History h) => earnedBadges(h, today);

    test('nothing yet', () {
      expect(
        earnedOf(
          History(
            habits: [habit(createdOn: monday)],
            entries: [],
          ),
        ),
        isEmpty,
      );
    });

    test('first step, perfect day and streaks', () {
      final a = habit(createdOn: monday.addDays(-40));
      final b = earnedOf(
        History(habits: [a], entries: done(a, range(-35, -5))),
      );
      expect(
        b,
        containsAll([
          Badge.firstStep,
          Badge.perfectDay,
          Badge.streak7,
          Badge.streak30,
        ]),
      );
      expect(b, isNot(contains(Badge.streak100)));
    });

    test('perfect week needs a whole Monday-to-Sunday week', () {
      final a = habit(createdOn: monday.addDays(-20));
      expect(
        earnedOf(History(habits: [a], entries: done(a, range(-4, 2)))),
        isNot(contains(Badge.perfectWeek)),
      );
      expect(
        earnedOf(History(habits: [a], entries: done(a, range(-7, -1)))),
        contains(Badge.perfectWeek),
      );
    });

    test('early bird and night owl after 10 completions', () {
      final m = habit(
        id: 1,
        moment: Moment.morning,
        createdOn: monday.addDays(-20),
      );
      final e = habit(
        id: 2,
        moment: Moment.evening,
        createdOn: monday.addDays(-20),
      );
      final h = History(
        habits: [m, e],
        entries: [...done(m, range(-10, -1)), ...done(e, range(-9, -1))],
      );
      expect(earnedOf(h), contains(Badge.earlyBird));
      expect(earnedOf(h), isNot(contains(Badge.nightOwl)));
    });

    test('totals: 100 pages, 10 hours, 20 litres', () {
      final pages = habit(
        id: 1,
        type: HabitType.quantity,
        unit: QuantityUnit.pages,
        goal: 20,
        createdOn: monday.addDays(-20),
      );
      final zen = habit(
        id: 2,
        type: HabitType.duration,
        goal: 3600,
        createdOn: monday.addDays(-20),
      );
      final water = habit(
        id: 3,
        type: HabitType.quantity,
        unit: QuantityUnit.liters,
        goal: 2000,
        createdOn: monday.addDays(-20),
      );
      final h = History(
        habits: [pages, zen, water],
        entries: [
          ...done(pages, range(-5, -1)),
          ...done(zen, range(-10, -1)),
          ...done(water, range(-9, -1)),
        ],
      );
      expect(earnedOf(h), containsAll([Badge.bookworm, Badge.zen]));
      expect(earnedOf(h), isNot(contains(Badge.hydrated)));
    });

    test('rescue after the first joker', () {
      final a = habit(createdOn: monday.addDays(-5));
      expect(
        earnedOf(History(habits: [a], entries: [], jokerDays: {monday})),
        contains(Badge.rescue),
      );
    });

    test('12 badges in display order', () {
      expect(Badge.values, hasLength(12));
      expect(Badge.values.take(6), [
        Badge.firstStep,
        Badge.streak7,
        Badge.earlyBird,
        Badge.bookworm,
        Badge.streak30,
        Badge.zen,
      ]);
    });
  });

  group('weekly challenges', () {
    final read = habit(id: 1, createdOn: monday.addDays(-30));
    final water = habit(
      id: 2,
      type: HabitType.quantity,
      unit: QuantityUnit.glasses,
      goal: 2000,
      createdOn: monday.addDays(-30),
    );
    final sport = habit(
      id: 3,
      type: HabitType.frequency,
      mode: ScheduleMode.weekly,
      timesPerWeek: 3,
      createdOn: monday.addDays(-30),
    );

    test('one of each kind from the habits, with progress this week', () {
      final h = History(
        habits: [read, water, sport],
        entries: [
          ...done(read, [0, 1]),
          ...done(water, [0, 1, 2]),
          ...done(sport, [1]),
        ],
      );
      final cs = weeklyChallenges(h, monday.addDays(2));
      expect(cs.map((c) => c.kind), [
        ChallengeKind.sevenDays,
        ChallengeKind.goalFiveDays,
        ChallengeKind.timesThisWeek,
        ChallengeKind.perfectWeek,
      ]);
      expect(
        [for (final c in cs) (c.progress, c.target)],
        [(2, 7), (3, 5), (1, 3), (2, 7)],
      );
      expect([for (final c in cs) c.xp], [150, 100, 80, 300]);
      expect(cs.first.habit, read);
    });

    test('kinds without a matching habit are left out', () {
      final cs = weeklyChallenges(History(habits: [read], entries: []), monday);
      expect(cs.map((c) => c.kind), [
        ChallengeKind.sevenDays,
        ChallengeKind.perfectWeek,
      ]);
    });

    test('the featured habit rotates week to week', () {
      final other = habit(id: 4, createdOn: monday.addDays(-30));
      final h = History(habits: [read, other], entries: []);
      expect(
        weeklyChallenges(h, monday).first.habit,
        isNot(weeklyChallenges(h, monday.addDays(7)).first.habit),
      );
    });

    test('completed challenges add their XP', () {
      final h = History(habits: [sport], entries: done(sport, [-7, -6, -5, 0]));
      expect(challengeXp(h, today), 80);
      expect(levelXp(h, today), totalXp(h, today) + 80);
    });
  });
}
