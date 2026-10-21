import 'package:flutter/material.dart';

import '../domain/day.dart';
import '../theme/sorbet_colors.dart';

/// Look of one day in a [MonthMosaic].
class MosaicCell {
  const MosaicCell({required this.color, this.child, this.ring = false});

  final Color color;

  /// Day number or icon; null leaves the cell empty.
  final Widget? child;

  /// Ink inset outline, for today.
  final bool ring;
}

/// Glued month calendar: weekday letters, then 7 columns of 30 px cells
/// with 1 px gaps inside a 16 px rounded frame.
class MonthMosaic extends StatelessWidget {
  const MonthMosaic({
    super.key,
    required this.days,
    required this.weekdayLetters,
    required this.cellFor,
    required this.semanticLabel,
    this.cellHeight = 30,
  });

  /// From `monthGrid`: whole weeks, nulls outside the month.
  final List<Day?> days;
  final List<String> weekdayLetters;
  final MosaicCell Function(Day day) cellFor;
  final String semanticLabel;
  final double cellHeight;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final letter = Theme.of(context).textTheme.labelSmall!
        .copyWith(color: c.faint);
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 1,
            children: [
              for (final l in weekdayLetters)
                Expanded(
                  child: Text(l, textAlign: TextAlign.center, style: letter),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              spacing: 1,
              children: [
                for (var w = 0; w < days.length; w += 7)
                  Row(
                    spacing: 1,
                    children: [
                      for (final d in days.sublist(w, w + 7))
                        Expanded(child: _cell(c, d)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(SorbetColors c, Day? d) {
    final cell = d == null ? MosaicCell(color: c.cellOff) : cellFor(d);
    return Container(
      height: cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cell.color,
        borderRadius: BorderRadius.circular(3),
      ),
      foregroundDecoration: cell.ring
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: c.ink, width: 2.5),
            )
          : null,
      child: cell.child,
    );
  }
}
