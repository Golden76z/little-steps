import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/app.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/time/today_provider.dart';

/// Tuesday 20 October 2026, 10 am.
final testNow = DateTime(2026, 10, 20, 10);

/// The whole app on an in-memory database and a fixed clock.
Future<void> pumpApp(
  WidgetTester tester,
  AppDatabase db, {
  String locale = 'en',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => testNow),
      ],
      child: LittleStepsApp(locale: Locale(locale)),
    ),
  );
  await tester.pumpAndSettle();
}

/// testWidgets with a fresh in-memory database, unmounting the app at the
/// end: drift keeps a short timer on cancelled stream queries, which must
/// fire before the pending-timer check.
void testApp(
  String description,
  Future<void> Function(WidgetTester tester, AppDatabase db) body,
) {
  testWidgets(description, (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await body(tester, db);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });
}

/// Lets drift's stream queries emit, then settles the UI.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  await tester.pumpAndSettle();
}
