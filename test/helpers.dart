import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/app.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';
import 'package:little_steps/core/domain/rewards.dart';
import 'package:little_steps/core/feedback/celebrated.dart';
import 'package:little_steps/core/feedback/feedback.dart';
import 'package:little_steps/core/notifications/reminder_scheduler.dart';
import 'package:little_steps/core/time/today_provider.dart';

/// Tuesday 20 October 2026, 10 am.
final testNow = DateTime(2026, 10, 20, 10);

/// Records what the app asks to schedule, instead of the real plugin.
class FakeScheduler implements ReminderScheduler {
  List<ScheduledNotification> scheduled = [];
  int calls = 0;

  @override
  Future<void> replaceAll(
    List<ScheduledNotification> notifications, {
    required String channelName,
    required String channelDescription,
  }) async {
    calls++;
    scheduled = notifications;
  }
}

/// The scheduler of the last [pumpApp].
late FakeScheduler scheduler;

/// Records the sounds the app plays, instead of the audio plugin.
class FakeSoundPlayer implements SoundPlayer {
  final played = <Sound>[];

  @override
  Future<void> play(Sound sound) async => played.add(sound);
}

/// The sound player of the last [pumpApp].
late FakeSoundPlayer sounds;

/// Records the `HapticFeedback.vibrate` types sent to the platform, such as
/// 'HapticFeedbackType.lightImpact', until the end of the test.
List<String> recordHaptics(WidgetTester tester) {
  final log = <String>[];
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      log.add(call.arguments as String);
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return log;
}

/// The whole app on an in-memory database and a fixed clock.
Future<void> pumpApp(
  WidgetTester tester,
  AppDatabase db, {
  String locale = 'en',
}) async {
  // A common Android phone (412 × 915 dp) rather than the 800 × 600 default.
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => testNow),
        reminderSchedulerProvider.overrideWithValue(
          scheduler = FakeScheduler(),
        ),
        soundPlayerProvider.overrideWithValue(sounds = FakeSoundPlayer()),
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

/// Adds a second, unchecked habit (today cannot become perfect) and marks the
/// first-step badge as already celebrated, so completing another habit plays
/// only its own celebration.
Future<void> addOtherHabit(WidgetTester tester, AppDatabase db) async {
  ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
      .read(celebratedProvider.notifier)
      .claim('badge:${Badge.firstStep.name}');
  await tester.runAsync(
    () => HabitRepository(db).createHabit(
      Habit(
        id: 0,
        name: 'Autre',
        type: HabitType.yesNo,
        color: HabitColor.sky,
        icon: 'drop',
        goal: 1,
        step: 1,
        activeDays: Habit.everyDay,
        scheduleMode: ScheduleMode.days,
        moment: Moment.anytime,
        createdOn: Day(2026, 9, 1),
      ),
    ),
  );
}
