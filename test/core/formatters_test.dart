import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/l10n/formatters.dart';
import 'package:little_steps/core/l10n/l10n.dart';

import '../domain/fixtures.dart';

HabitFormat fmt(String locale) =>
    HabitFormat(lookupAppLocalizations(Locale(locale)), locale);

Habit qty(QuantityUnit unit, double goal, double step) =>
    habit(type: HabitType.quantity, goal: goal, step: step, unit: unit);

void main() {
  setUpAll(initializeDateFormatting);

  test('percent follows the locale', () {
    expect(fmt('en').percent(0.5), '50%');
    expect(fmt('fr').percent(0.5), '50\u00a0%');
  });

  test('litres use the locale decimal separator', () {
    final water = qty(QuantityUnit.liters, 2000, 250);
    expect(fmt('fr').value(water, 1250), '1,25 / 2 L');
    expect(fmt('en').value(water, 1250), '1.25 / 2 L');
  });

  test('glasses, millilitres, pages and times', () {
    expect(
      fmt('fr').value(qty(QuantityUnit.glasses, 2000, 250), 1250),
      '5 / 8 verres',
    );
    expect(
      fmt('en').value(qty(QuantityUnit.milliliters, 2000, 250), 750),
      '750 / 2,000 ml',
    );
    expect(
      fmt('fr').value(qty(QuantityUnit.pages, 20, 4), 12),
      '12 / 20 pages',
    );
    expect(fmt('fr').value(qty(QuantityUnit.times, 3, 1), 2), '2 / 3 fois');
  });

  test('steps and kilometres', () {
    expect(
      fmt('fr').value(qty(QuantityUnit.steps, 8000, 1000), 4500),
      '4\u202f500 / 8\u202f000 pas',
    );
    expect(
      fmt('fr').value(qty(QuantityUnit.kilometers, 5000, 500), 2500),
      '2,5 / 5 km',
    );
    expect(fmt('en').step(qty(QuantityUnit.kilometers, 5000, 500)), '0.5 km');
    expect(
      fmt('fr').step(qty(QuantityUnit.steps, 8000, 1000)),
      '1\u202f000 pas',
    );
  });

  test('duration in whole minutes, journal in lines', () {
    expect(
      fmt('fr').value(habit(type: HabitType.duration, goal: 600), 329),
      '5 / 10 min',
    );
    expect(
      fmt('fr').value(habit(type: HabitType.journal, goal: 3), 1),
      '1 / 3 lignes',
    );
  });

  test('weekly frequency counts this week', () {
    final sport = habit(
      type: HabitType.frequency,
      mode: ScheduleMode.weekly,
      timesPerWeek: 3,
    );
    expect(fmt('fr').value(sport, 0, weekCount: 1), '1 / 3 cette semaine');
  });

  test('yes/no shows done or its moment', () {
    final screens = habit(type: HabitType.yesNo, moment: Moment.evening);
    expect(fmt('fr').value(screens, 0), 'Ce soir');
    expect(fmt('fr').value(screens, 1), 'C’est fait !');
  });

  test('step labels', () {
    expect(fmt('fr').step(qty(QuantityUnit.liters, 2000, 250)), '25 cl');
    expect(fmt('fr').step(qty(QuantityUnit.glasses, 2000, 250)), '1 verre');
    expect(fmt('en').step(qty(QuantityUnit.glasses, 2000, 500)), '2 glasses');
    expect(fmt('fr').step(qty(QuantityUnit.pages, 20, 4)), '4 pages');
    expect(fmt('fr').step(habit(type: HabitType.yesNo)), isNull);
  });

  test('goal and schedule labels for detail headers', () {
    final f = fmt('fr');
    expect(f.goal(qty(QuantityUnit.glasses, 2000, 250)), '8 verres');
    expect(f.goal(qty(QuantityUnit.liters, 2000, 250)), '2 L');
    expect(f.goal(habit(type: HabitType.duration, goal: 600)), '10 min');
    expect(f.goal(habit(type: HabitType.journal, goal: 3)), '3 lignes');
    expect(f.schedule(habit()), 'chaque jour');
    expect(f.schedule(habit(moment: Moment.evening)), 'chaque soir');
    expect(f.schedule(habit(activeDays: {1, 3, 5})), 'Lun, Mer, Ven');
    expect(
      f.schedule(habit(mode: ScheduleMode.weekly, timesPerWeek: 3)),
      '3 fois par semaine',
    );
    expect(f.weekdayLetters(DateTime.monday), [
      'L',
      'M',
      'M',
      'J',
      'V',
      'S',
      'D',
    ]);
    expect(fmt('en').weekdayLetters(DateTime.sunday).first, 'S');
  });

  test('date ranges for the progress header', () {
    expect(
      fmt('fr').dayRange(Day(2026, 10, 14), Day(2026, 10, 20)),
      '14 – 20 octobre',
    );
    expect(
      fmt('fr').dayRange(Day(2026, 9, 28), Day(2026, 10, 4)),
      '28 sept. – 4 oct.',
    );
    expect(
      fmt('en').dayRange(Day(2026, 10, 14), Day(2026, 10, 20)),
      'October 14 – 20',
    );
    expect(fmt('fr').monthYear(Day(2026, 8, 3)), 'août 2026');
  });

  test('long date and short weekday follow the locale', () {
    expect(fmt('fr').longDate(Day(2026, 10, 27)), 'mardi 27 octobre');
    expect(fmt('en').longDate(Day(2026, 10, 27)), 'Tuesday, October 27');
    expect(fmt('fr').weekdayShort(Day(2026, 10, 19)), 'Lun');
    expect(fmt('en').weekdayShort(Day(2026, 10, 19)), 'Mon');
    expect(fmt('fr').month(Day(2026, 10, 19)), 'octobre');
  });

  test('French plurals print the real count for 0', () {
    final l10n = lookupAppLocalizations(const Locale('fr'));
    expect(l10n.jokersLeft(0), '0 restant');
    expect(l10n.goalMetDays(0), 'objectif atteint 0 jour');
    expect(l10n.linesCount(0), '0 ligne');
    expect(l10n.challengeDaysLeft('7', '7', 0), '7 jours sur 7 · reste 0 jour');
  });
}
