import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// A value that rolls in from below when it changes (percentages, counts).
class RollingText extends StatelessWidget {
  const RollingText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Where old and new values sit while they cross.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: context.motion(Motion.medium),
    switchInCurve: Motion.curve,
    switchOutCurve: Motion.curve,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.35),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    layoutBuilder: (current, previous) =>
        Stack(alignment: alignment, children: [...previous, ?current]),
    child: Text(
      text,
      key: ValueKey(text),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    ),
  );
}
