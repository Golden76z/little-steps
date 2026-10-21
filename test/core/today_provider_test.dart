import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/time/today_provider.dart';

void main() {
  testWidgets('today is the logical day and rolls over at 3 am', (
    tester,
  ) async {
    var now = DateTime(2026, 10, 21, 2, 59, 30);
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    container.listen(todayProvider, (_, _) {});

    expect(container.read(todayProvider), Day(2026, 10, 20));
    now = DateTime(2026, 10, 21, 3, 0, 1);
    await tester.pump(const Duration(seconds: 31));
    expect(container.read(todayProvider), Day(2026, 10, 21));
    container.dispose(); // cancels the next rollover timer
  });

  test('rollover hour comes from its provider', () {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 21, 4)),
        rolloverHourProvider.overrideWithValue(5),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(todayProvider), Day(2026, 10, 20));
  });

  test('the stored rollover hour wins over the default', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await HabitRepository(db).setSetting('rolloverHour', '5');
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 21, 4)),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    container.listen(rolloverHourProvider, (_, _) {});
    await container.read(settingProvider('rolloverHour').future);
    expect(container.read(todayProvider), Day(2026, 10, 20));
  });
}
