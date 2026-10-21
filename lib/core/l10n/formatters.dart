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

  /// What one quick action adds, e.g. "25 cl"; null when it does not add.
  String? step(Habit h) {
    final s = h.step;
    return switch (h.type) {
      HabitType.quantity => switch (h.unit ?? QuantityUnit.times) {
        QuantityUnit.liters => l10n.stepCl(number(s / 10)),
        QuantityUnit.milliliters => l10n.stepMl(number(s)),
        QuantityUnit.glasses => l10n.stepGlasses(number(s / 250), s / 250),
        QuantityUnit.pages => l10n.stepPages(number(s), s),
        QuantityUnit.times => l10n.stepTimes(number(s), s),
      },
      HabitType.duration => l10n.stepMinutes(number(s ~/ 60)),
      _ => null,
    };
  }

  /// "mardi 27 octobre" / "Tuesday, October 27".
  String longDate(Day d) =>
      DateFormat.MMMMEEEEd(locale).format(d.toLocalDate());

  /// "Lun" / "Mon": the locale abbreviation, capitalised, without its dot.
  String weekdayShort(Day d) {
    final s = DateFormat.E(locale).format(d.toLocalDate()).replaceAll('.', '');
    return s[0].toUpperCase() + s.substring(1);
  }

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
