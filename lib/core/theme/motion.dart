import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Motion tokens for effects (colours, opacities): short, soft, never in the
/// way. Anything that moves in space uses [Springs] instead.
abstract final class Motion {
  /// Taps and colour changes.
  static const fast = Duration(milliseconds: 150);

  /// Selections sliding, values rolling, tabs fading in.
  static const medium = Duration(milliseconds: 220);

  /// Progress fills (as in the mockups: pill 0.3 s).
  static const slow = Duration(milliseconds: 300);

  /// Rings catching up with a new value.
  static const ring = Duration(milliseconds: 600);

  /// A finger going down on a pressable: nearly instant.
  static const pressDown = Duration(milliseconds: 70);

  /// The short squash before a [Pop].
  static const anticipate = Duration(milliseconds: 80);

  /// Sizes following [Springs.smooth], through [SpringCurve].
  static const resize = Duration(milliseconds: 350);

  /// Bottom sheets coming in and going away.
  static const sheetIn = Duration(milliseconds: 350);
  static const sheetOut = Duration(milliseconds: 250);

  /// The "+XP" label flying from a pill to the header avatar.
  static const flight = Duration(milliseconds: 700);

  static const curve = Curves.easeOutCubic;
}

/// Named springs, as perceived duration and bounce.
abstract final class Springs {
  static SpringDescription _s(int ms, double bounce) =>
      SpringDescription.withDurationAndBounce(
        duration: Duration(milliseconds: ms),
        bounce: bounce,
      );

  /// Coming back up after a press.
  static final press = _s(300, 0.30);

  /// Indicators, thumbs, switches, ticks, selections.
  static final snappy = _s(250, 0.15);

  /// Sizes, content appearing, space fades.
  static final smooth = _s(350, 0);

  /// Fills: pills, wave, rings, bars, XP.
  static final fill = _s(500, 0);

  /// One-off celebrations.
  static final pop = _s(350, 0.45);
}

/// A curve drawn from a spring without bounce, for widgets that only take a
/// curve (AnimatedSize & co.). Normalised so it ends exactly on 1.
class SpringCurve extends Curve {
  const SpringCurve(this.spring, this.duration);

  final SpringDescription spring;
  final Duration duration;

  @override
  double transformInternal(double t) {
    final sim = SpringSimulation(spring, 0, 1, 0);
    final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
    return sim.x(t * seconds) / sim.x(seconds);
  }
}

extension MotionContext on BuildContext {
  /// True when the system asks for fewer animations.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// [d], or no time at all when the system asks for fewer animations.
  Duration motion(Duration d) => reduceMotion ? Duration.zero : d;
}
