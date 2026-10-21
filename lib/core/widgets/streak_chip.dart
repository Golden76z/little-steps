import 'package:flutter/material.dart';

import '../icons/phosphor_icons.dart';
import '../theme/sorbet_colors.dart';

/// Flame chip with the global streak; greyed out at 0.
class StreakChip extends StatelessWidget {
  const StreakChip({
    super.key,
    required this.days,
    required this.semanticLabel,
  });

  final int days;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final on = days > 0;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: on ? c.flameChip : c.chipOff,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            Icon(
              PhosphorIconsFill.fire,
              size: 18,
              color: on ? c.flame : c.flameOff,
            ),
            Text(
              '$days',
              style: Theme.of(context).textTheme.titleSmall!
                  .copyWith(height: 1, color: on ? c.ink : c.faint),
            ),
          ],
        ),
      ),
    );
  }
}
