import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/rules.dart';

enum Period { week, month, year }

/// Pills filled out of pills planned: one pill per habit due (or flexible,
/// for a weekly target) on a day up to today.
final class Tally {
  const Tally(this.done, this.planned);

  final int done;
  final int planned;

  double get rate => planned == 0 ? 0 : done / planned;

  Tally operator +(Tally o) => Tally(done + o.done, planned + o.planned);

  @override
  bool operator ==(Object other) =>
      other is Tally && other.done == done && other.planned == planned;

  @override
  int get hashCode => Object.hash(done, planned);

  @override
  String toString() => 'Tally($done / $planned)';
}

/// One tube: a day (week), a week (month) or a month (year).
final class Slice {
  const Slice(this.from, this.to, this.tally);

  final Day from;
  final Day to;
  final Tally tally;
}

final class ProgressData {
  const ProgressData({
    required this.from,
    required this.to,
    required this.total,
    required this.deltaPoints,
    required this.slices,
    required this.current,
    required this.rows,
  });

  final Day from;
  final Day to;
  final Tally total;

  /// Rate gap with the previous period, in rounded percentage points; null
  /// when either period planned nothing.
  final int? deltaPoints;
  final List<Slice> slices;

  /// Index of the slice holding today, if in this period.
  final int? current;

  /// Active habits, most days succeeded first.
  final List<(Habit, Tally)> rows;
}

/// A day of the period [by] periods away from [anchor].
Day shiftPeriod(Period p, Day anchor, int by) => switch (p) {
  Period.week => anchor.addDays(7 * by),
  Period.month => Day(anchor.year, anchor.month + by, 1),
  Period.year => Day(anchor.year + by, 1, 1),
};

(Day, Day) periodBounds(Period p, Day anchor, int firstWeekday) {
  switch (p) {
    case Period.week:
      final start = anchor.weekStart(firstWeekday);
      return (start, start.addDays(6));
    case Period.month:
      return (
        Day(anchor.year, anchor.month, 1),
        Day(anchor.year, anchor.month + 1, 1).addDays(-1),
      );
    case Period.year:
      return (Day(anchor.year, 1, 1), Day(anchor.year, 12, 31));
  }
}

Tally tally(
  History history,
  Iterable<Habit> habits,
  Day from,
  Day to,
  Day today,
) {
  var done = 0, planned = 0;
  for (var d = from; d <= to && d <= today; d = d.addDays(1)) {
    for (final h in habits) {
      final s = h.statusOn(d);
      if (s != DayStatus.due && s != DayStatus.flexible) continue;
      planned++;
      if (history.isDone(h, d)) done++;
    }
  }
  return Tally(done, planned);
}

ProgressData buildProgress({
  required History history,
  required List<Habit> habits,
  required Period period,
  required Day anchor,
  required Day today,
  required int firstWeekday,
}) {
  final (from, to) = periodBounds(period, anchor, firstWeekday);
  Tally all(Day a, Day b) => tally(history, history.habits, a, b, today);

  final bounds = <(Day, Day)>[
    if (period == Period.week)
      for (var i = 0; i < 7; i++) (from.addDays(i), from.addDays(i)),
    if (period == Period.month)
      for (var w = from.weekStart(firstWeekday); w <= to; w = w.addDays(7))
        (w < from ? from : w, w.addDays(6) > to ? to : w.addDays(6)),
    if (period == Period.year)
      for (var m = 1; m <= 12; m++)
        periodBounds(Period.month, Day(from.year, m, 1), firstWeekday),
  ];
  final slices = [for (final (a, b) in bounds) Slice(a, b, all(a, b))];
  final current = slices.indexWhere((s) => s.from <= today && today <= s.to);

  final total = slices.fold(const Tally(0, 0), (t, s) => t + s.tally);
  final (pFrom, pTo) = periodBounds(
    period,
    shiftPeriod(period, anchor, -1),
    firstWeekday,
  );
  final previous = all(pFrom, pTo);
  int points(Tally t) => (t.rate * 100).round();

  final indexed =
      [
        for (final (i, h) in habits.indexed)
          (i, h, tally(history, [h], from, to, today)),
      ]..sort(
        (x, y) => y.$3.done != x.$3.done
            ? y.$3.done.compareTo(x.$3.done)
            : x.$1.compareTo(y.$1),
      );

  return ProgressData(
    from: from,
    to: to,
    total: total,
    deltaPoints: total.planned == 0 || previous.planned == 0
        ? null
        : points(total) - points(previous),
    slices: slices,
    current: current < 0 ? null : current,
    rows: [for (final (_, h, t) in indexed) (h, t)],
  );
}
