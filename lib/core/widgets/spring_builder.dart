import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// Implicit spring animator: follows [value] with [spring], and when the
/// target changes in flight it carries on from the current position and
/// velocity instead of starting over. Unbounded, so bounces are not clipped.
/// With reduced motion it jumps straight to the target.
class SpringBuilder extends StatefulWidget {
  const SpringBuilder({
    super.key,
    required this.value,
    required this.spring,
    required this.builder,
    this.child,
    this.from,
  });

  final double value;
  final SpringDescription spring;
  final Widget Function(BuildContext context, double value, Widget? child)
  builder;
  final Widget? child;

  /// Value on mount (defaults to [value]): the spring runs from it.
  final double? from;

  @override
  State<SpringBuilder> createState() => _SpringBuilderState();
}

class _SpringBuilderState extends State<SpringBuilder>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(
    vsync: this,
    value: widget.from ?? widget.value,
  );

  void _go() {
    if (context.reduceMotion) {
      _c.value = widget.value; // also stops a running spring
    } else if (_c.value != widget.value || _c.isAnimating) {
      _c.animateWith(
        SpringSimulation(
          widget.spring,
          _c.value,
          widget.value,
          _c.velocity,
          snapToEnd: true,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _go();
  }

  @override
  void didUpdateWidget(SpringBuilder old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value || old.spring != widget.spring) _go();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, child) => widget.builder(context, _c.value, child),
    child: widget.child,
  );
}

/// One-off celebration: when [trigger] goes up, [child] squashes to 0.97 for
/// a beat ([anticipate]), then springs up to about [peak] and back to 1 with
/// [Springs.pop]. Never on mount, never with reduced motion.
class Pop extends StatefulWidget {
  const Pop({
    super.key,
    required this.trigger,
    required this.child,
    this.peak = 1.04,
    this.anticipate = true,
  });

  final int trigger;
  final Widget child;
  final double peak;
  final bool anticipate;

  @override
  State<Pop> createState() => _PopState();
}

class _PopState extends State<Pop> with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this, value: 1);

  @override
  void didUpdateWidget(Pop old) {
    super.didUpdateWidget(old);
    if (widget.trigger > old.trigger && !context.reduceMotion) _play();
  }

  void _play() {
    if (!widget.anticipate) return _kick();
    // A TickerFuture only completes when the run ends, not when cut short.
    _c
        .animateTo(0.97, duration: Motion.anticipate, curve: Motion.curve)
        .then((_) => _kick());
  }

  void _kick() {
    final from = _c.value;
    _c.animateWith(
      SpringSimulation(
        Springs.pop,
        from,
        1,
        _launchSpeed(from, widget.peak),
        snapToEnd: true,
      ),
    );
  }

  /// The upward speed that makes the spring top out at [peak].
  static double _launchSpeed(double from, double peak) {
    double top(double v) {
      final sim = SpringSimulation(Springs.pop, from, 1, v);
      var m = from;
      for (var t = 0.0; t < 0.6; t += 1 / 240) {
        m = math.max(m, sim.x(t));
      }
      return m;
    }

    var lo = 0.0, hi = 10.0;
    for (var i = 0; i < 24; i++) {
      final mid = (lo + hi) / 2;
      if (top(mid) < peak) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return hi;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _c, child: widget.child);
}
