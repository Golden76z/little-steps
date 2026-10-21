import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';

void main() {
  test('upgrading a v1 database adds the settings table', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) => raw.execute('PRAGMA user_version = 1'),
      ),
    );
    addTearDown(db.close);
    final repo = HabitRepository(db);
    await repo.setSetting('k', 'v');
    expect(await repo.getSetting('k'), 'v');
  });
}
