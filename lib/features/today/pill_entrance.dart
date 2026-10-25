import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/feedback.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/spring_builder.dart';

/// The habit just created, and whether the screens that created it have
/// slid away (its pill waits folded until then).
// ponytail: stays set if the new habit has no pill on the day shown; the
// entrance then plays the next time it does.
final justCreatedProvider = NotifierProvider<JustCreated, (int, bool)?>(
  JustCreated.new,
);

class JustCreated extends Notifier<(int, bool)?> {
  @override
  (int, bool)? build() => null;

  void set(int id) => state = (id, false);

  /// The creation screens are gone: the pill may come in.
  void landed() {
    if (state case (final id, false)) state = (id, true);
  }

  /// True once for [id], when it has landed: its pill plays the entrance.
  bool claim(int id) {
    if (state != (id, true)) return false;
    state = null;
    return true;
  }
}

/// A pill that, when its habit was just created, grows in on a pop spring
/// (siblings move aside smoothly) with a sparkle, a light tick and a pop.
class PillEntrance extends ConsumerStatefulWidget {
  const PillEntrance({super.key, required this.habitId, required this.child});

  static const sparkleKey = ValueKey('pill-entrance-sparkle');

  final int habitId;
  final Widget child;

  @override
  ConsumerState<PillEntrance> createState() => _PillEntranceState();
}

class _PillEntranceState extends ConsumerState<PillEntrance> {
  /// Folded (waiting to land) or coming in.
  bool _play = false;
  bool _landed = false;

  @override
  void initState() {
    super.initState();
    // The new pill can show up before its id is known (the stream is faster
    // than the insert's return): Today is still covered then.
    ref.listenManual(justCreatedProvider, (_, next) {
      if (next?.$1 != widget.habitId) return;
      if (!_play) setState(() => _play = true);
      if (next!.$2) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _land());
      }
    }, fireImmediately: true);
  }

  void _land() {
    if (!mounted ||
        !ref.read(justCreatedProvider.notifier).claim(widget.habitId)) {
      return;
    }
    setState(() => _landed = true);
    ref.read(feedbackProvider)
      ..haptic(Haptic.light)
      ..sound(Sound.pop);
  }

  @override
  Widget build(BuildContext context) {
    if (!_play) return widget.child;
    final sparkle = context.sorbet.accent;
    return SpringBuilder(
      from: 0,
      value: _landed ? 1 : 0,
      spring: Springs.pop,
      child: widget.child,
      builder: (context, v, child) {
        final t = v.clamp(0.0, 1.0);
        // Rises then fades as the pill lands.
        final glow = math.sin(math.pi * t);
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: t,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: t,
                child: Transform.scale(scale: 0.9 + 0.1 * v, child: child),
              ),
              if (glow > 0.02)
                PositionedDirectional(
                  end: 6,
                  top: -10,
                  child: Opacity(
                    key: PillEntrance.sparkleKey,
                    opacity: glow,
                    child: Transform.scale(
                      scale: 0.6 + 0.6 * glow,
                      child: Icon(
                        PhosphorIconsFill.sparkle,
                        size: 22,
                        color: sparkle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
