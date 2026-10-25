import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// A value that rolls when it changes (percentages, counts): the new text
/// comes in from below and pushes the old one up. Given [value], a drop
/// rolls the other way. With [perCharacter], only the characters that
/// changed roll (a timer's digits), matched from the right.
class RollingText extends StatefulWidget {
  const RollingText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.alignment = AlignmentDirectional.centerStart,
    this.value,
    this.perCharacter = false,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Where old and new values sit while they cross.
  final AlignmentGeometry alignment;

  /// The number shown, to tell a rise from a drop.
  final num? value;
  final bool perCharacter;

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText> {
  /// 1: the new value comes in from below; -1: from above.
  double _dir = 1;

  @override
  void didUpdateWidget(RollingText old) {
    super.didUpdateWidget(old);
    final (a, b) = (old.value, widget.value);
    if (a != null && b != null && a != b) _dir = b > a ? 1 : -1;
  }

  Widget _roll(String text) => AnimatedSwitcher(
    duration: context.motion(Motion.medium),
    switchInCurve: Motion.curve,
    switchOutCurve: Motion.curve,
    // Outgoing children run their animation backwards, 1 → 0.
    transitionBuilder: (child, animation) {
      final incoming = child.key == ValueKey(text);
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: Offset(0, 0.35 * _dir * (incoming ? 1 : -1)),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
    layoutBuilder: (current, previous) =>
        Stack(alignment: widget.alignment, children: [...previous, ?current]),
    child: Text(
      text,
      key: ValueKey(text),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!widget.perCharacter) return _roll(widget.text);
    final chars = widget.text.characters.toList();
    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < chars.length; i++)
            KeyedSubtree(
              key: ValueKey(chars.length - i),
              child: _roll(chars[i]),
            ),
        ],
      ),
    );
  }
}
