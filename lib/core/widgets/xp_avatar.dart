import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../icons/phosphor_icons.dart';
import '../theme/sorbet_colors.dart';
import '../theme/motion.dart';
import 'spring_builder.dart';

/// Avatar inside the XP ring (accent arc over a pale track): 48 px on
/// Today and Trophies, 56 px with a level pill on Profile. The ring fills
/// with [Springs.fill] and the avatar pops when it grows; given [level], a
/// level up fills the ring to the end, pops, then starts again from 0 (a
/// level lost empties it, then comes back from full).
class XpAvatar extends StatefulWidget {
  const XpAvatar({
    super.key,
    required this.fraction,
    required this.semanticLabel,
    this.onTap,
    this.size = 48,
    this.color,
    this.child,
    this.badge,
    this.level,
  });

  final double size;

  /// Inner disc; lilac by default.
  final Color? color;

  /// Inside the disc; the user glyph by default.
  final Widget? child;

  /// Small ink pill at the bottom right (the level on Profile).
  final String? badge;

  /// Share of the current level done, 0–1; 0 draws the track only.
  final double fraction;
  final String semanticLabel;
  final VoidCallback? onTap;

  /// Current level, so a level change can fill the ring up rather than back.
  final int? level;

  @override
  State<XpAvatar> createState() => _XpAvatarState();
}

class _XpAvatarState extends State<XpAvatar>
    with SingleTickerProviderStateMixin {
  late final _ring = AnimationController.unbounded(
    vsync: this,
    value: widget.fraction,
  );
  var _pops = 0;

  /// True while the ring runs to an end on a level change: fraction
  /// changes then wait for it.
  var _wrapping = false;

  TickerFuture _fill(double to) => _ring.animateWith(
    SpringSimulation(
      Springs.fill,
      _ring.value,
      to,
      _ring.velocity,
      snapToEnd: true,
    ),
  );

  @override
  void didUpdateWidget(XpAvatar old) {
    super.didUpdateWidget(old);
    final (was, now) = (old.level, widget.level);
    final change = was == null || now == null ? 0 : now.compareTo(was);
    if (context.reduceMotion) {
      _wrapping = false;
      _ring.value = widget.fraction;
    } else if (change != 0) {
      _wrapping = true;
      // Cut short by a newer level change, this run never completes.
      _fill(change > 0 ? 1 : 0).then((_) {
        if (!mounted) return;
        if (change > 0) setState(() => _pops++);
        _wrapping = false;
        _ring.value = change > 0 ? 0 : 1;
        _fill(widget.fraction);
      });
    } else if (!_wrapping && widget.fraction != old.fraction) {
      if (widget.fraction > old.fraction) _pops++;
      _fill(widget.fraction);
    }
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final XpAvatar(:size, :color, :child, :badge) = widget;
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Pop(
          trigger: _pops,
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _ring,
                    builder: (context, child) => CustomPaint(
                      painter: _RingPainter(
                        fraction: _ring.value,
                        track: c.track,
                        color: c.accent,
                      ),
                      child: child,
                    ),
                    child: Padding(
                      // Mockup: inset 7 at 48 px, 8 at 56 px.
                      padding: EdgeInsets.all(size / 7),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color ?? c.habit[HabitColor.lilac],
                        ),
                        child: Center(
                          child:
                              child ??
                              Icon(
                                PhosphorIconsFill.user,
                                size: 18,
                                color: c.ink,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    right: -4,
                    bottom: -2,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.ink,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: c.surface, width: 2),
                      ),
                      child: Text(
                        badge,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: c.onAccent,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
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
