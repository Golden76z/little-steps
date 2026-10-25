import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers.dart';
import 'audio_sound_player.dart';

/// Haptic levels: selection tick, light impact, success.
enum Haptic { tick, light, success }

/// The three synthesised sounds in assets/sounds/.
enum Sound { pop, done, celebrate }

/// Plays a [Sound]; faked in tests so they never reach the audio plugin.
abstract interface class SoundPlayer {
  Future<void> play(Sound sound);
}

/// Settings keys, '1' or '0'; on when unset.
const hapticsKey = 'haptics', soundsKey = 'sounds';

final hapticsEnabledProvider = Provider<bool>(
  (ref) => ref.watch(settingProvider(hapticsKey)).value != '0',
);
final soundsEnabledProvider = Provider<bool>(
  (ref) => ref.watch(settingProvider(soundsKey)).value != '0',
);

final soundPlayerProvider = Provider<SoundPlayer>((ref) => AudioSoundPlayer());

/// Android API level, read once; 0 off Android, in tests, or on any error.
final sdkIntProvider = FutureProvider<int>((ref) async {
  try {
    return await const MethodChannel('little_steps/device')
            .invokeMethod<int>('sdkInt') ??
        0;
  } catch (_) {
    return 0;
  }
});

final feedbackProvider = Provider<FeedbackService>(
  (ref) => FeedbackService(
    ref.watch(soundPlayerProvider),
    haptics: ref.watch(hapticsEnabledProvider),
    sounds: ref.watch(soundsEnabledProvider),
    sdkInt: ref.watch(sdkIntProvider).value ?? 0,
  ),
);

/// Haptics and sounds, each behind its Profile switch. Fire and forget:
/// never waits, never throws to the caller.
class FeedbackService {
  FeedbackService(
    this._player, {
    required this.haptics,
    required this.sounds,
    required this.sdkInt,
  });

  final SoundPlayer _player;
  final bool haptics, sounds;
  final int sdkInt;

  void haptic(Haptic h) {
    if (!haptics) return;
    _swallow(switch (h) {
      Haptic.tick => HapticFeedback.selectionClick,
      Haptic.light => HapticFeedback.lightImpact,
      // successNotification does nothing before Android 11 (API 30).
      Haptic.success =>
        sdkInt >= 30
            ? HapticFeedback.successNotification
            : HapticFeedback.mediumImpact,
    });
  }

  void sound(Sound s) {
    if (sounds) _swallow(() => _player.play(s));
  }

  static void _swallow(Future<void> Function() run) {
    try {
      unawaited(
        run().catchError((Object e) => debugPrint('Feedback failed: $e')),
      );
    } catch (e) {
      debugPrint('Feedback failed: $e');
    }
  }
}
