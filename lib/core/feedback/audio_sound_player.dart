import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'feedback.dart';

/// [SoundPlayer] on audioplayers: one low-latency pool per sound, on the
/// sonification stream (Android) and the ambient category (iOS), so the
/// phone's silent mode mutes it and music is not interrupted.
class AudioSoundPlayer implements SoundPlayer {
  final _pools = <Sound, Future<AudioPool>>{};

  static final _context = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  /// Longer than the longest sound (celebrate, < 1 s).
  static const _tail = Duration(seconds: 1);

  Future<AudioPool> _pool(Sound s) => _pools[s] ??= AudioPool.create(
    source: AssetSource('sounds/${s.name}.wav'),
    maxPlayers: 3,
    audioContext: _context,
    playerMode: PlayerMode.lowLatency,
  );

  @override
  Future<void> play(Sound sound) async {
    final AudioPool pool;
    try {
      pool = await _pool(sound);
    } catch (_) {
      _pools.remove(sound); // try again next time
      rethrow;
    }
    final stop = await pool.start(volume: 0.8);
    // Low-latency players never report completion: hand them back ourselves.
    Timer(_tail, stop);
  }
}
