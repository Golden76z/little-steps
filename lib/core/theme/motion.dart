import 'package:flutter/widgets.dart';

/// Motion tokens: short, soft, never in the way.
abstract final class Motion {
  /// Taps and colour changes.
  static const fast = Duration(milliseconds: 150);

  /// Selections sliding, values rolling, tabs fading in.
  static const medium = Duration(milliseconds: 220);

  /// Progress fills (as in the mockups: pill 0.3 s).
  static const slow = Duration(milliseconds: 300);

  /// Rings catching up with a new value.
  static const ring = Duration(milliseconds: 600);

  static const curve = Curves.easeOutCubic;
}

extension MotionContext on BuildContext {
  /// [d], or no time at all when the system asks for fewer animations.
  Duration motion(Duration d) =>
      (MediaQuery.maybeDisableAnimationsOf(this) ?? false) ? Duration.zero : d;
}
