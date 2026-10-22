import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// Sinks [child] slightly while a finger rests on it. Only listens to the
/// pointer, so the child's own gestures are untouched; a finger that moves
/// past the touch slop (a scroll) lets it go.
class PressScale extends StatefulWidget {
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
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  Offset? _down;

  void _set(Offset? down) {
    if ((down == null) != (_down == null)) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (e) => _set(widget.enabled ? e.position : null),
    onPointerMove: (e) {
      final start = _down;
      if (start != null && (e.position - start).distance > kTouchSlop) {
        _set(null);
      }
    },
    onPointerUp: (_) => _set(null),
    onPointerCancel: (_) => _set(null),
    child: AnimatedScale(
      scale: _down != null ? widget.scale : 1,
      duration: context.motion(Motion.fast),
      curve: Motion.curve,
      child: widget.child,
    ),
  );
}
