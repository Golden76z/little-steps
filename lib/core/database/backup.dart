import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/day.dart';
import 'app_database.dart';

/// Every table, as exported to and imported from a JSON file.
final class Backup {
  const Backup({
    required this.habits,
    required this.entries,
    required this.pauses,
    required this.jokers,
    required this.settings,
  });

  final List<HabitRow> habits;
  final List<EntryRow> entries;
  final List<PauseRow> pauses;
  final List<JokerDayRow> jokers;
  final List<SettingRow> settings;
}

const _format = 'little-steps';
const _version = 1;

String encodeBackup(Backup b, DateTime exportedAt) {
  const s = _BackupSerializer();
  return const JsonEncoder.withIndent('  ').convert({
    'format': _format,
    'version': _version,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'habits': [for (final r in b.habits) r.toJson(serializer: s)],
    'entries': [for (final r in b.entries) r.toJson(serializer: s)],
    'pauses': [for (final r in b.pauses) r.toJson(serializer: s)],
    'jokers': [for (final r in b.jokers) s.toJson(r.day)],
    'settings': {for (final r in b.settings) r.key: r.value},
  });
}

/// Parses and checks a whole file; throws [FormatException] on anything
/// unexpected, so a bad file never reaches the database.
Backup decodeBackup(String source) {
  const s = _BackupSerializer();
  try {
    final json = jsonDecode(source) as Map<String, dynamic>;
    if (json['format'] != _format || json['version'] != _version) {
      throw const FormatException('Not a Little Steps backup');
    }
    List<T> rows<T>(String key, T Function(Map<String, dynamic>) parse) => [
      for (final r in json[key] as List) parse(r as Map<String, dynamic>),
    ];
    final backup = Backup(
      habits: rows('habits', (r) => HabitRow.fromJson(r, serializer: s)),
      entries: rows('entries', (r) => EntryRow.fromJson(r, serializer: s)),
      pauses: rows('pauses', (r) => PauseRow.fromJson(r, serializer: s)),
      jokers: [
        for (final d in json['jokers'] as List)
          JokerDayRow(day: s.fromJson<Day>(d)),
      ],
      settings: [
        for (final MapEntry(:key, :value)
            in (json['settings'] as Map<String, dynamic>).entries)
          SettingRow(key: key, value: value as String),
      ],
    );
    final ids = {for (final h in backup.habits) h.id};
    final orphan =
        backup.entries.any((e) => !ids.contains(e.habitId)) ||
        backup.pauses.any((p) => !ids.contains(p.habitId));
    if (orphan) throw const FormatException('Data of an unknown habit');
    return backup;
  } on TypeError catch (e) {
    // A missing field or a value of the wrong type.
    throw FormatException('$e');
  } on ArgumentError catch (e) {
    // An unknown enum name.
    throw FormatException('$e');
  }
}

/// Days as `2026-10-25`, weekday sets and minute lists as JSON arrays.
class _BackupSerializer extends ValueSerializer {
  const _BackupSerializer();

  static const _base = ValueSerializer.defaults();
  static final _date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  @override
  dynamic toJson<T>(T value) => switch (value) {
    Day d =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}',
    Set<int> s => s.toList()..sort(),
    _ => _base.toJson<T>(value),
  };

  @override
  T fromJson<T>(dynamic json) {
    if (json == null) return _base.fromJson<T>(json);
    final type = <T>[];
    if (type is List<Day?>) {
      final m = _date.firstMatch(json as String);
      if (m == null) throw FormatException('Bad date', json);
      final [y, mo, d] = [for (var i = 1; i <= 3; i++) int.parse(m[i]!)];
      return Day(y, mo, d) as T;
    }
    if (type is List<Set<int>?>) return {...(json as List).cast<int>()} as T;
    if (type is List<List<int>?>) return [...(json as List).cast<int>()] as T;
    return _base.fromJson<T>(json);
  }
}
