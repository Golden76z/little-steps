import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/domain/day.dart';

void main() {
  group('logicalDay', () {
    test('before 3 am still belongs to the previous day', () {
      expect(logicalDay(DateTime(2026, 10, 21, 2, 59)), Day(2026, 10, 20));
    });

    test('from 3 am it is the calendar day', () {
      expect(logicalDay(DateTime(2026, 10, 21, 3)), Day(2026, 10, 21));
    });

    test('rollover hour is configurable', () {
      expect(
        logicalDay(DateTime(2026, 10, 21, 4), rolloverHour: 5),
        Day(2026, 10, 20),
      );
      expect(
        logicalDay(DateTime(2026, 10, 21, 0, 30), rolloverHour: 0),
        Day(2026, 10, 21),
      );
    });

    test('crosses month and year boundaries', () {
      expect(logicalDay(DateTime(2027, 1, 1, 1)), Day(2026, 12, 31));
    });
  });

  group('Day', () {
    test('adds days across a DST change without drifting', () {
      expect(Day(2026, 10, 24).addDays(2), Day(2026, 10, 26));
      expect(Day(2026, 3, 28).addDays(1), Day(2026, 3, 29));
    });

    test('round-trips through its epoch index', () {
      final d = Day(2026, 10, 21);
      expect(Day.fromIndex(d.index), d);
      expect(Day(1970, 1, 2).index, 1);
    });

    test('weekday uses DateTime numbering (Monday = 1)', () {
      expect(Day(2026, 10, 19).weekday, DateTime.monday);
      expect(Day(2026, 10, 25).weekday, DateTime.sunday);
    });

    test('weekStart follows the locale first day', () {
      final wed = Day(2026, 10, 21);
      expect(wed.weekStart(DateTime.monday), Day(2026, 10, 19));
      expect(wed.weekStart(DateTime.sunday), Day(2026, 10, 18));
      expect(Day(2026, 10, 18).weekStart(DateTime.sunday), Day(2026, 10, 18));
    });

    test('compares chronologically', () {
      expect(Day(2026, 10, 20) < Day(2026, 10, 21), isTrue);
      expect(Day(2026, 10, 21).difference(Day(2026, 10, 1)), 20);
    });
  });

  test('addMonths keeps the day, clamped to the end of the month', () {
    expect(Day(2026, 10, 20).addMonths(1), Day(2026, 11, 20));
    expect(Day(2027, 1, 31).addMonths(1), Day(2027, 2, 28));
    expect(Day(2026, 12, 15).addMonths(1), Day(2027, 1, 15));
  });
}
