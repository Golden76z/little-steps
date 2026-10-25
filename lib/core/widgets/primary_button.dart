import 'package:flutter/material.dart';

import '../theme/sorbet_colors.dart';
import 'press_scale.dart';

/// Wide accent call to action with its solid drop shadow.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 60,
    this.fontSize = 19,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final enabled = onPressed != null;
    const depth = 4.0;
    return PressSink(
      depth: depth,
      enabled: enabled,
      builder: (context, pressed) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: enabled ? c.ctaShadow : c.shadowPill,
              offset: Offset(0, depth - depth * pressed),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(height),
            backgroundColor: c.accent,
            foregroundColor: c.onAccent,
            disabledBackgroundColor: c.chipOff,
            disabledForegroundColor: c.faint,
            textStyle: Theme.of(context).textTheme.titleMedium!
                .copyWith(fontSize: fontSize, fontWeight: FontWeight.w500),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              if (icon != null) Icon(icon, size: 18),
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}
