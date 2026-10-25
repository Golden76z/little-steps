import 'package:flutter/material.dart';

import '../icons/phosphor_icons.dart';
import '../theme/sorbet_colors.dart';
import 'rolling_text.dart';
import 'spring_builder.dart';

/// Flame chip with the global streak; greyed out at 0. Pops when the streak
/// grows, its number rolling the way it changed.
class StreakChip extends StatefulWidget {
  const StreakChip({
    super.key,
    required this.days,
    required this.semanticLabel,
  });

  final int days;
  final String semanticLabel;

  @override
  State<StreakChip> createState() => _StreakChipState();
}

class _StreakChipState extends State<StreakChip> {
  var _pops = 0;

  @override
  void didUpdateWidget(StreakChip old) {
    super.didUpdateWidget(old);
    if (widget.days > old.days) _pops++;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final days = widget.days;
    final on = days > 0;
    return Semantics(
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: Pop(
        trigger: _pops,
        peak: 1.08,
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
              RollingText(
                '$days',
                value: days,
                style: Theme.of(context).textTheme.titleSmall!
                    .copyWith(height: 1, color: on ? c.ink : c.faint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
