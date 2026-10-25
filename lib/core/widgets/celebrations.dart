import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers.dart';
import '../domain/day.dart';
import '../domain/rewards.dart';
import '../domain/rules.dart';
import '../feedback/celebrated.dart';
import '../feedback/feedback.dart';
import '../theme/motion.dart';
import '../theme/sorbet_colors.dart';
import '../time/today_provider.dart';

/// The app-wide celebrations, wherever the user is: today becoming a
/// perfect day (with a shower of Sorbet confetti), a level up, a new badge,
/// a challenge of the week completed. Each one plays once in the app's
/// life, with the success haptic and a single `celebrate` sound however
/// many come at once. Never on launch, never blocks taps.
class Celebrations extends ConsumerStatefulWidget {
  const Celebrations({super.key});

  /// Present only while a burst is falling (tests look for it).
  static const burstKey = Key('perfect-day-confetti');

  @override
  ConsumerState<Celebrations> createState() => _CelebrationsState();
}

class _CelebrationsState extends ConsumerState<Celebrations>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2200);
  late final _controller = AnimationController(vsync: this, duration: _duration)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() => _pieces = const []);
    });
  final _random = math.Random();
  List<_Piece> _pieces = const [];

  /// What was already true at the first look: never celebrated.
  Set<String>? _known;

  /// The celebration waiting for the habit's own (its +XP flight) to end.
  Timer? _pending;
  bool _withBurst = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(historyProvider, (_, next) {
      final history = next.value;
      if (history == null) return;
      final now = _achievements(history, ref.read(todayProvider));
      final known = _known;
      if (known == null) {
        _known = now;
        return;
      }
      final celebrated = ref.read(celebratedProvider.notifier);
      final fresh = [
        for (final k in now)
          if (!known.contains(k) && celebrated.claim(k)) k,
      ];
      if (fresh.isEmpty) return;
      _withBurst |= fresh.any((k) => k.startsWith('perfect:'));
      _pending?.cancel();
      _pending = Timer(Motion.flight, () {
        ref.read(feedbackProvider)
          ..haptic(Haptic.success)
          ..sound(Sound.celebrate);
        if (_withBurst) _burst();
        _withBurst = false;
      });
    }, fireImmediately: true);
  }

  /// Everything worth celebrating that is true now, as celebrated keys.
  static Set<String> _achievements(History history, Day today) {
    final week = today.weekStart(DateTime.monday);
    final level = levelFor(levelXp(history, today)).level;
    return {
      if (history.isPerfect(today) ?? false) 'perfect:$today',
      for (var n = 2; n <= level; n++) 'level:$n',
      for (final b in earnedBadges(history, today)) 'badge:${b.name}',
      for (final c in weeklyChallenges(history, today))
        if (c.completed) 'challenge:$week:${c.kind.name}',
    };
  }

  @override
  void dispose() {
    _pending?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _burst() {
    if (context.motion(_duration) == Duration.zero) return;
    final c = context.sorbet;
    final colors = [...c.habit.values, c.accent];
    _pieces = [
      for (var i = 0; i < 70; i++)
        _Piece(
          x: _random.nextDouble(),
          delay: _random.nextDouble() * 0.25,
          drift: (_random.nextDouble() - 0.5) * 0.3,
          fall: 120 + _random.nextDouble() * 160,
          spin: (_random.nextDouble() - 0.5) * 12,
          size: Size(
            6 + _random.nextDouble() * 5,
            3 + _random.nextDouble() * 3,
          ),
          color: colors[_random.nextInt(colors.length)],
        ),
    ];
    setState(() {});
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_pieces.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      key: Celebrations.burstKey,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_pieces, _controller, _duration),
          ),
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.drift,
    required this.fall,
    required this.spin,
    required this.size,
    required this.color,
  });

  /// Start, as a share of the width.
  final double x;

  /// Share of the burst before it starts falling.
  final double delay;

  /// Sideways speed, in widths per second.
  final double drift;

  /// Initial falling speed, px/s.
  final double fall;

  /// Rotation speed, rad/s.
  final double spin;
  final Size size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.progress, this.duration)
    : super(repaint: progress);

  final List<_Piece> pieces;
  final Animation<double> progress;
  final Duration duration;

  static const _gravity = 700.0;

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = progress.value * duration.inMilliseconds / 1000;
    final paint = Paint();
    for (final p in pieces) {
      final t = seconds - p.delay * duration.inMilliseconds / 1000;
      if (t <= 0) continue;
      final y = -20 + p.fall * t + _gravity * t * t / 2;
      if (y > size.height + 20) continue;
      final x =
          size.width * (p.x + p.drift * t) + math.sin(t * 6 + p.x * 10) * 8;
      final fade = progress.value < 0.8 ? 1.0 : (1 - progress.value) / 0.2;
      paint.color = p.color.withValues(alpha: p.color.a * fade);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.spin * t)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size.width,
              height: p.size.height,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.pieces != pieces;
}
