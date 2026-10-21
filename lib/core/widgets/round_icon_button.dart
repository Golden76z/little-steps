import 'package:flutter/material.dart';

import '../theme/sorbet_colors.dart';

/// Pale round button (close, back, −/+), with at least a 48 px target.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 40,
    this.iconSize = 18,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final target = size < 48 ? 48.0 : size;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: target / 2,
        child: SizedBox.square(
          dimension: target,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.bg),
              child: Icon(
                icon,
                size: iconSize,
                color: onTap == null ? c.faint : c.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
