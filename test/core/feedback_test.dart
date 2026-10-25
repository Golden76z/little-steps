import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/providers.dart';
import 'package:little_steps/core/feedback/celebrated.dart';
import 'package:little_steps/core/feedback/feedback.dart';

import '../helpers.dart';

class _BrokenPlayer implements SoundPlayer {
  @override
  Future<void> play(Sound sound) => Future.error(StateError('no audio'));
}

class _ThrowingPlayer implements SoundPlayer {
  @override
  Future<void> play(Sound sound) => throw StateError('no audio');
}

void main() {
  Future<(ProviderContainer, FakeSoundPlayer)> boot(
    WidgetTester tester, {
    Map<String, String> settings = const {},
    SoundPlayer? player,
    int? sdk,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    final fake = FakeSoundPlayer();
    if (sdk != null) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('little_steps/device'),
        (call) async => call.method == 'sdkInt' ? sdk : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('little_steps/device'),
          null,
        ),
      );
    }
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        soundPlayerProvider.overrideWithValue(player ?? fake),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });
    await tester.runAsync(() async {
      for (final e in settings.entries) {
        await db
            .into(db.settings)
            .insert(SettingsCompanion.insert(key: e.key, value: e.value));
      }
    });
    // Drift streams only run in real async: subscribe inside runAsync.
    await tester.runAsync(() async {
      container.listen(feedbackProvider, (_, _) {});
      await container.read(settingProvider(hapticsKey).future);
      await container.read(settingProvider(soundsKey).future);
      await container.read(sdkIntProvider.future);
    });
    return (container, fake);
  }

  testWidgets('each level sends its haptic type', (tester) async {
    final haptics = recordHaptics(tester);
    final (c, _) = await boot(tester, sdk: 34);
    c.read(feedbackProvider)
      ..haptic(Haptic.tick)
      ..haptic(Haptic.light)
      ..haptic(Haptic.success);
    await tester.pump();
    expect(haptics, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.successNotification',
    ]);
  });

  testWidgets('success falls back to a medium impact before Android 11', (
    tester,
  ) async {
    final haptics = recordHaptics(tester);
    final (c, _) = await boot(tester, sdk: 29);
    c.read(feedbackProvider).haptic(Haptic.success);
    await tester.pump();
    expect(haptics, ['HapticFeedbackType.mediumImpact']);
  });

  testWidgets('no device channel means the fallback too', (tester) async {
    final haptics = recordHaptics(tester);
    final (c, _) = await boot(tester);
    c.read(feedbackProvider).haptic(Haptic.success);
    await tester.pump();
    expect(haptics, ['HapticFeedbackType.mediumImpact']);
  });

  testWidgets('sounds reach the player, haptics and sounds on by default', (
    tester,
  ) async {
    final haptics = recordHaptics(tester);
    final (c, fake) = await boot(tester);
    c.read(feedbackProvider)
      ..sound(Sound.done)
      ..haptic(Haptic.light);
    await tester.pump();
    expect(fake.played, [Sound.done]);
    expect(haptics, hasLength(1));
  });

  testWidgets('nothing is sent once the settings are off', (tester) async {
    final haptics = recordHaptics(tester);
    final (c, fake) = await boot(
      tester,
      settings: {hapticsKey: '0', soundsKey: '0'},
    );
    c.read(feedbackProvider)
      ..haptic(Haptic.success)
      ..sound(Sound.celebrate);
    await tester.pump();
    expect(haptics, isEmpty);
    expect(fake.played, isEmpty);
  });

  testWidgets('a failing player or haptic channel never reaches the caller', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => throw PlatformException(code: 'boom'),
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    for (final player in [_BrokenPlayer(), _ThrowingPlayer()]) {
      final (c, _) = await boot(tester, player: player);
      c.read(feedbackProvider)
        ..sound(Sound.pop)
        ..haptic(Haptic.success);
      await tester.pump();
    }
    expect(tester.takeException(), isNull);
  });

  test('Celebrated.claim is true the first time only', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final celebrated = c.read(celebratedProvider.notifier);
    expect(celebrated.claim('habit:1:2026-10-20'), isTrue);
    expect(celebrated.claim('habit:1:2026-10-20'), isFalse);
    expect(celebrated.claim('habit:2:2026-10-20'), isTrue);
  });
}
