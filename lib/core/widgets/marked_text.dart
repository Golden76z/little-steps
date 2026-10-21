import 'package:flutter/widgets.dart';

/// Text where `**…**` spans (from the ARB strings) render with [strong].
class MarkedText extends StatelessWidget {
  const MarkedText(
    this.text, {
    super.key,
    this.style,
    required this.strong,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextStyle strong;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    return Text.rich(
      textAlign: textAlign,
      TextSpan(
        style: style,
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(text: parts[i], style: i.isOdd ? strong : null),
        ],
      ),
    );
  }
}
