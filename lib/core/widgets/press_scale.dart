import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// "3D button" press: while a finger rests on it, the child goes down by
/// [depth] in about 70 ms; on release it comes back up with [Springs.press]
/// from wherever it is. [builder] gets `pressed` (0 at rest, 1 fully down,
/// briefly below 0 on the rebound) so it can shrink its shadow offset by
/// `depth * pressed`: the child sinks into its shadow. PressSink applies the
/// translation itself.
///
/// Only listens to the pointer, so the child's own gestures are untouched; a
/// finger that moves past the touch slop (a scroll) lets it go. A very short
/// tap still sinks at least 60 %, so it shows.
class PressSink extends StatefulWidget {
  const PressSink({
    super.key,
    required this.depth,
    this.enabled = true,
    required this.builder,
  });

  final double depth;

  /// False for a disabled control: no promise of an action.
  final bool enabled;
  final Widget Function(BuildContext context, double pressed) builder;

  @override
  State<PressSink> createState() => _PressSinkState();
}

class _PressSinkState extends State<PressSink>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this);
  Offset? _down;

  static const _minDepth = 0.6;

  void _press(PointerDownEvent e) {
    if (!widget.enabled) return;
    _down = e.position;
    if (context.reduceMotion) {
      _c.value = 1;
    } else {
      _c.animateTo(
        1,
        duration: Motion.pressDown * (1 - _c.value).clamp(0, 1),
        curve: Motion.curve,
      );
    }
  }

  void _lift({bool tap = false}) {
    if (_down == null) return;
    _down = null;
    if (context.reduceMotion) {
      _c.value = 0;
    } else if (tap && _c.value < _minDepth) {
      // A TickerFuture only completes when the run ends, not when cut short.
      _c
          .animateTo(
            _minDepth,
            duration: Motion.pressDown * (_minDepth - _c.value),
            curve: Motion.curve,
          )
          .then((_) => _springBack());
    } else {
      _springBack();
    }
  }

  void _springBack() => _c.animateWith(
    SpringSimulation(Springs.press, _c.value, 0, _c.velocity, snapToEnd: true),
  );

  @override
  void didUpdateWidget(PressSink old) {
    super.didUpdateWidget(old);
    if (!widget.enabled) _lift();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _press,
    onPointerMove: (e) {
      final start = _down;
      if (start != null && (e.position - start).distance > kTouchSlop) {
        _lift();
      }
    },
    onPointerUp: (_) => _lift(tap: true),
    onPointerCancel: (_) => _lift(),
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Transform.translate(
        offset: Offset(0, widget.depth * _c.value),
        child: widget.builder(context, _c.value),
      ),
    ),
  );
}

/// Shrinks [child] to [scale] while a finger rests on it, for controls
/// without a candy shadow (icon buttons, chips); same press as [PressSink].
class PressScale extends StatelessWidget {
  const PressScale({
    super.key,
    required this.child,
    this.scale = 0.96,
    this.enabled = true,
  });

  final Widget child;
  final double scale;

  /// False for a disabled control: no promise of an action.
  final bool enabled;

  @override
  Widget build(BuildContext context) => PressSink(
    depth: 0,
    enabled: enabled,
    builder: (context, pressed) =>
        Transform.scale(scale: 1 - (1 - scale) * pressed, child: child),
  );
}
