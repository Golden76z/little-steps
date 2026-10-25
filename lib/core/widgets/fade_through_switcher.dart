import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// Fade-through between children: the old one fades out in the first 30 %,
/// then the new one fades in (gliding 8 px along [direction], the way the
/// content travels, when there is one), so there is never a double image.
/// The height follows with [Springs.smooth] instead of jumping. Children
/// must carry a key that changes with the content.
class FadeThroughSwitcher extends StatelessWidget {
  const FadeThroughSwitcher({
    super.key,
    required this.child,
    this.direction,
    this.alignment = AlignmentDirectional.topStart,
  });

  final Widget child;
  final AxisDirection? direction;
  final AlignmentGeometry alignment;

  static const _out = Interval(0.7, 1, curve: Motion.curve);
  static const _in = Interval(0.3, 1, curve: Motion.curve);
  static const _glide = 8.0;

  @override
  Widget build(BuildContext context) {
    final unit = switch (direction) {
      AxisDirection.up => const Offset(0, -1),
      AxisDirection.down => const Offset(0, 1),
      AxisDirection.left => const Offset(-1, 0),
      AxisDirection.right => const Offset(1, 0),
      null => Offset.zero,
    };
    return AnimatedSize(
      duration: context.motion(Motion.resize),
      curve: SpringCurve(Springs.smooth, Motion.resize),
      alignment: alignment,
      child: AnimatedSwitcher(
        duration: context.motion(Motion.medium),
        // Outgoing children run their animation backwards, 1 → 0.
        transitionBuilder: (c, animation) {
          final incoming = c.key == child.key;
          final opacity = CurvedAnimation(
            parent: animation,
            curve: incoming ? _in : _out,
          );
          final glide = unit * _glide * (incoming ? -1 : 1);
          return FadeTransition(
            opacity: opacity,
            child: unit == Offset.zero
                ? c
                : AnimatedBuilder(
                    animation: opacity,
                    builder: (context, c) => Transform.translate(
                      offset: glide * (1 - opacity.value),
                      child: c,
                    ),
                    child: c,
                  ),
          );
        },
        layoutBuilder: (current, previous) =>
            Stack(alignment: alignment, children: [...previous, ?current]),
        child: child,
      ),
    );
  }
}
