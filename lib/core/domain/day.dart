/// A calendar date with no time or zone, stored as days since 1970-01-01.
/// UTC arithmetic underneath, so DST never shifts a day.
final class Day implements Comparable<Day> {
  Day(int year, int month, int day)
    : index =
          DateTime.utc(year, month, day).millisecondsSinceEpoch ~/ _msPerDay;

  const Day.fromIndex(this.index);

  static const _msPerDay = Duration.millisecondsPerDay;

  final int index;

  DateTime get _utc =>
      DateTime.fromMillisecondsSinceEpoch(index * _msPerDay, isUtc: true);

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  /// [DateTime.monday] (1) … [DateTime.sunday] (7).
  int get weekday => _utc.weekday;

  /// Local midnight of this date, for formatting with `intl`.
  DateTime toLocalDate() => DateTime(year, month, day);

  Day addDays(int n) => Day.fromIndex(index + n);

  /// Same day [n] months later, clamped to that month's last day (Jan 31 → Feb 28).
  Day addMonths(int n) {
    final last = Day(year, month + n + 1, 1).addDays(-1);
    return Day(last.year, last.month, day < last.day ? day : last.day);
  }

  /// Days from [other] to this one.
  int difference(Day other) => index - other.index;

  /// First day of the week holding this date; [firstWeekday] uses DateTime numbering.
  Day weekStart(int firstWeekday) => addDays(-((weekday - firstWeekday) % 7));

  bool operator <(Day other) => index < other.index;
  bool operator <=(Day other) => index <= other.index;
  bool operator >(Day other) => index > other.index;
  bool operator >=(Day other) => index >= other.index;

  @override
  int compareTo(Day other) => index.compareTo(other.index);

  @override
  bool operator ==(Object other) => other is Day && other.index == index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() =>
      'Day($year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')})';
}

/// The habit day [now] (local wall-clock time) belongs to: before
/// [rolloverHour] it still counts as the previous day.
Day logicalDay(DateTime now, {int rolloverHour = 3}) {
  final today = Day(now.year, now.month, now.day);
  return now.hour < rolloverHour ? today.addDays(-1) : today;
}
