import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/sorbet_colors.dart';

/// Flies "+[xp] XP" from the end of [from] (a pill, where its button is) to
/// the centre of [to] (the avatar), then fades it. Never blocks a touch;
/// nothing with reduced motion or no XP.
void showXpFlight(
  BuildContext context, {
  required GlobalKey from,
  required GlobalKey to,
  required int xp,
}) {
  if (xp <= 0 || context.reduceMotion) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final a = from.currentContext?.findRenderObject() as RenderBox?;
  final b = to.currentContext?.findRenderObject() as RenderBox?;
  if (overlay == null || a == null || b == null) return;
  final space = overlay.context.findRenderObject()! as RenderBox;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  // The middle of the 40 px button, 11 px in from the pill's end.
  final start = a.localToGlobal(
    Offset(rtl ? 31 : a.size.width - 31, a.size.height / 2),
    ancestor: space,
  );
  final end = b.localToGlobal(b.size.center(Offset.zero), ancestor: space);
  final label = context.l10n.xpGained(xp);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _XpFlight(
      start: start,
      end: end,
      label: label,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _XpFlight extends StatefulWidget {
  const _XpFlight({
    required this.start,
    required this.end,
    required this.label,
    required this.onDone,
  });

  final Offset start, end;
  final String label;
  final VoidCallback onDone;

  @override
  State<_XpFlight> createState() => _XpFlightState();
}

class _XpFlightState extends State<_XpFlight>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: Motion.flight)
    ..forward().then((_) => widget.onDone());
  late final _move = CurvedAnimation(parent: _c, curve: Motion.curve);
  late final _fade = ReverseAnimation(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0.6, 1, curve: Motion.curve),
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _move,
        builder: (context, child) {
          final p = Offset.lerp(widget.start, widget.end, _move.value)!;
          return Stack(
            children: [
              Positioned(
                left: p.dx,
                top: p.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: child,
                ),
              ),
            ],
          );
        },
        child: FadeTransition(
          opacity: _fade,
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge!
                .copyWith(color: c.accent, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
