// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v3 numbers existing habits in id order', () async {
    final schema = await verifier.schemaAt(2);
    for (final name in ['A', 'B', 'C']) {
      schema.rawDatabase.execute(
        'INSERT INTO habits (name, type, color, icon, goal, step, '
        'schedule_mode, active_days, times_per_week, moment, reminders, '
        'streak_danger_alert, created_on) '
        "VALUES (?, 'yesNo', 'sky', 'drop', 1, 1, 'days', 127, 3, "
        "'anytime', '', 1, 20000)",
        [name],
      );
    }
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    await db.close();
    final migrated = v3.DatabaseAtV3(schema.newConnection());
    final rows = await (migrated.select(
      migrated.habits,
    )..orderBy([(h) => OrderingTerm.asc(h.position)])).get();
    expect(rows.map((r) => r.name), ['A', 'B', 'C']);
    expect(rows.map((r) => r.position).toSet(), hasLength(3));
    await migrated.close();
  });
}
