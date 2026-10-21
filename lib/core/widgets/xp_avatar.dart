import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../icons/phosphor_icons.dart';
import '../theme/sorbet_colors.dart';

/// 48 px avatar inside the XP ring (accent arc over a pale track).
class XpAvatar extends StatelessWidget {
  const XpAvatar({
    super.key,
    required this.fraction,
    required this.semanticLabel,
    this.onTap,
  });

  /// Share of the current level done, 0–1; 0 draws the track only.
  final double fraction;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 48,
          child: CustomPaint(
            painter: _RingPainter(
              fraction: fraction,
              track: c.track,
              color: c.accent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.habit[HabitColor.lilac],
                ),
                child: Icon(PhosphorIconsFill.user, size: 18, color: c.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.track,
    required this.color,
  });

  final double fraction;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Mockup: r 27, stroke 5 in a 60 viewBox.
    final scale = size.width / 60;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: 27 * scale,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scale;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction.clamp(0, 1),
        false,
        paint
          ..color = color
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track;
}
