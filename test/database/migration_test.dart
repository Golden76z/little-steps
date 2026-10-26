import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';

import 'app_database/generated/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('upgrading a v1 database adds the settings table', () async {
    final schema = await SchemaVerifier(GeneratedHelper()).schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    final repo = HabitRepository(db);
    await repo.setSetting('k', 'v');
    expect(await repo.getSetting('k'), 'v');
  });
}
