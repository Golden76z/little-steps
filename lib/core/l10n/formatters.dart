import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/day.dart';
import '../domain/habit.dart';
import 'l10n.dart';

/// Locale-aware text for habit values, steps, percentages and dates.
class HabitFormat {
  HabitFormat(this.l10n, this.locale)
    : _number = NumberFormat.decimalPattern(locale)..maximumFractionDigits = 2,
      _percent = NumberFormat.percentPattern(locale);

  final AppLocalizations l10n;
  final String locale;
  final NumberFormat _number;
  final NumberFormat _percent;

  String number(num v) => _number.format(v);

  String percent(double fraction) => _percent.format(fraction);

  /// Native-unit progress line, e.g. "1,25 / 2 L" or "Ce soir".
  String value(Habit h, double value, {int? weekCount}) {
    String pair(double factor, String Function(String, String) build) =>
        build(number(value / factor), number(h.goal / factor));
    return switch (h.type) {
      HabitType.quantity => switch (h.unit ?? QuantityUnit.times) {
        QuantityUnit.liters => pair(1000, (v, g) => l10n.valueLiters(v, g)),
        QuantityUnit.milliliters => pair(1, (v, g) => l10n.valueMl(v, g)),
        QuantityUnit.glasses => pair(
          250,
          (v, g) => l10n.valueGlasses(v, g, h.goal / 250),
        ),
        QuantityUnit.pages => pair(1, (v, g) => l10n.valuePages(v, g, h.goal)),
        QuantityUnit.steps => pair(1, (v, g) => l10n.valueSteps(v, g)),
        QuantityUnit.kilometers => pair(1000, (v, g) => l10n.valueKm(v, g)),
        QuantityUnit.times => pair(1, (v, g) => l10n.valueTimes(v, g, h.goal)),
      },
      HabitType.duration => l10n.valueMinutes(
        number(value ~/ 60),
        number(h.goal ~/ 60),
      ),
      HabitType.journal => pair(1, (v, g) => l10n.valueLines(v, g, h.goal)),
      HabitType.frequency when weekCount != null => l10n.valueThisWeek(
        number(weekCount),
        number(h.timesPerWeek),
      ),
      HabitType.frequency || HabitType.yesNo =>
        h.isCompleted(value) ? l10n.doneLabel : moment(h.moment),
    };
  }

  String moment(Moment m) => switch (m) {
    Moment.morning => l10n.momentMorning,
    Moment.noon => l10n.momentNoon,
    Moment.evening => l10n.momentEvening,
    Moment.anytime => l10n.momentAnytime,
  };

  /// What one quick action adds, e.g. "25 cl", or [amount] in the same
  /// words; null when it does not add.
  String? step(Habit h, [double? amount]) {
    final s = amount ?? h.step;
    return switch (h.type) {
      HabitType.quantity => switch (h.unit ?? QuantityUnit.times) {
        QuantityUnit.liters => l10n.stepCl(number(s / 10)),
        QuantityUnit.milliliters => l10n.stepMl(number(s)),
        QuantityUnit.glasses => l10n.stepGlasses(number(s / 250), s / 250),
        QuantityUnit.pages => l10n.stepPages(number(s), s),
        QuantityUnit.steps => l10n.stepSteps(number(s)),
        QuantityUnit.kilometers => l10n.stepKm(number(s / 1000)),
        QuantityUnit.times => l10n.stepTimes(number(s), s),
      },
      HabitType.duration => l10n.stepMinutes(number(s ~/ 60)),
      _ => null,
    };
  }

  /// Daily goal in words, e.g. "8 verres", "2 L", "10 min".
  String goal(Habit h) {
    final g = h.goal;
    return switch (h.type) {
      HabitType.quantity => switch (h.unit ?? QuantityUnit.times) {
        QuantityUnit.glasses =>
          '${number(g / 250)} ${l10n.wordGlasses(g / 250)}',
        QuantityUnit.liters => '${number(g / 1000)} L',
        QuantityUnit.milliliters => '${number(g)} ml',
        QuantityUnit.pages => '${number(g)} ${l10n.wordPages(g)}',
        QuantityUnit.steps => '${number(g)} ${l10n.wordSteps}',
        QuantityUnit.kilometers => '${number(g / 1000)} km',
        QuantityUnit.times => '${number(g)} ${l10n.wordTimes(g)}',
      },
      HabitType.duration => '${number(g ~/ 60)} min',
      HabitType.journal => '${number(g)} ${l10n.wordLines(g)}',
      HabitType.yesNo || HabitType.frequency => number(g),
    };
  }

  /// "chaque soir", "Lun, Mer, Ven", "3 fois par semaine".
  String schedule(Habit h) {
    if (h.isWeekly) return l10n.timesAWeek(h.timesPerWeek);
    if (h.activeDays.length < 7) {
      final monday = Day(
        2026,
        10,
        19,
      ); // any Monday: only weekday names are used
      return [
        for (final d in h.activeDays.toList()..sort())
          weekdayShort(monday.addDays(d - 1)),
      ].join(', ');
    }
    return switch (h.moment) {
      Moment.morning => l10n.everyMorning,
      Moment.noon => l10n.everyNoon,
      Moment.evening => l10n.everyEvening,
      Moment.anytime => l10n.everyDay,
    };
  }

  /// One-letter weekday names, from [firstWeekday] (DateTime numbering).
  List<String> weekdayLetters(int firstWeekday) {
    final start = Day(2026, 10, 19).weekStart(firstWeekday);
    return [
      for (var i = 0; i < 7; i++)
        DateFormat.EEEEE(locale)
            .format(start.addDays(i).toLocalDate())
            .toUpperCase(),
    ];
  }

  /// "mardi 27 octobre" / "Tuesday, October 27".
  String longDate(Day d) =>
      DateFormat.MMMMEEEEd(locale).format(d.toLocalDate());

  /// "lundi 19" / "Monday 19": short enough for a one-line title.
  String weekdayDay(Day d) =>
      DateFormat('EEEE d', locale).format(d.toLocalDate());

  /// "Lun" / "Mon": the locale abbreviation, capitalised, without its dot.
  String weekdayShort(Day d) {
    final s = DateFormat.E(locale).format(d.toLocalDate()).replaceAll('.', '');
    return s[0].toUpperCase() + s.substring(1);
  }

  /// "14 – 20 octobre", "28 sept. – 4 oct.", "October 14 – 20".
  String dayRange(Day a, Day b) {
    final from = a.toLocalDate(), to = b.toLocalDate();
    if (a.month == b.month && a.year == b.year) {
      final first = DateFormat.MMMMd(locale).format(from);
      final last = DateFormat.MMMMd(locale).format(to);
      // Keep the month once, on the side the locale puts it.
      final monthFirst = first.startsWith(RegExp(r'\D'));
      return monthFirst
          ? '$first – ${DateFormat.d(locale).format(to)}'
          : '${DateFormat.d(locale).format(from)} – $last';
    }
    return '${DateFormat.MMMd(locale).format(from)} – ${DateFormat.MMMd(locale).format(to)}';
  }

  /// First letter upper-cased: "lundi 19 octobre" → "Lundi 19 octobre".
  String capitalized(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// "Sport, Lire et Eau" / "Sport and Read".
  String list(List<String> items) => items.length < 2
      ? items.join()
      : l10n.listAnd(items.sublist(0, items.length - 1).join(', '), items.last);

  /// "août 2026" / "August 2026".
  String monthYear(Day d) => DateFormat.yMMMM(locale).format(d.toLocalDate());

  String dayOfMonth(Day d) => DateFormat.d(locale).format(d.toLocalDate());

  String month(Day d) => DateFormat.MMMM(locale).format(d.toLocalDate());
}

extension FormatContext on BuildContext {
  HabitFormat get habitFormat =>
      HabitFormat(l10n, Localizations.localeOf(this).toString());

  /// The locale's first weekday in DateTime numbering (Monday = 1).
  int get firstWeekday {
    final i = MaterialLocalizations.of(this).firstDayOfWeekIndex;
    return i == 0 ? DateTime.sunday : i;
  }
}
