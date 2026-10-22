import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/sorbet_colors.dart';

/// Glued segmented control: cells on one tinted band, the selected one
/// white with a soft pink inset outline. Week days, Semaine/Mois/Année,
/// Badges/Défis.
class SegmentedStrip extends StatelessWidget {
  const SegmentedStrip({
    super.key,
    required this.count,
    required this.selected,
    required this.itemBuilder,
    this.onSelected,
    this.semanticLabels,
    this.cellHeight = 48,
    this.columns,
  }) : outlined = false;

  /// Variant used inside sheets: white band with a thin outline (E3 pause).
  const SegmentedStrip.outlined({
    super.key,
    required this.count,
    required this.selected,
    required this.itemBuilder,
    this.onSelected,
    this.semanticLabels,
    this.cellHeight = 38,
  }) : outlined = true,
       columns = null;

  final int count;
  final int? selected;
  final Widget Function(BuildContext context, int index, bool selected)
  itemBuilder;

  /// Null makes the strip decorative.
  final ValueChanged<int>? onSelected;

  /// Full names for assistive tech when cells show abbreviations.
  final List<String>? semanticLabels;
  final double cellHeight;
  final bool outlined;

  /// Cells per row; more cells wrap onto further rows.
  final int? columns;

  /// The sliding selection of a one-row strip (tests find it by this key).
  static const indicatorKey = Key('segmented-strip-indicator');

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    // Cells under 40 px get a taller invisible hit area, up to 48 px; the
    // band then grows by that difference, split above and below.
    final hitPad = math.max(4.0, (48 - cellHeight) / 2);
    final strip = Stack(
      children: [
        Positioned.fill(
          top: hitPad - 4,
          bottom: hitPad - 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: outlined ? c.surface : c.strip,
              borderRadius: BorderRadius.circular(outlined ? 20 : 22),
              border: outlined
                  ? Border.all(color: c.sheetDivider, width: 1.5)
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: (columns ?? count) >= count
              // One row: a single selection slides from cell to cell.
              ? LayoutBuilder(
                  builder: (context, box) {
                    final width = box.maxWidth / count;
                    final at = selected;
                    return Stack(
                      children: [
                        if (at != null && at >= 0)
                          AnimatedPositioned(
                            key: indicatorKey,
                            duration: context.motion(Motion.medium),
                            curve: Motion.curve,
                            left: width * at,
                            width: width,
                            top: hitPad,
                            bottom: hitPad,
                            child: DecoratedBox(decoration: _selection(c)),
                          ),
                        Row(
                          children: [
                            for (var i = 0; i < count; i++)
                              Expanded(
                                child: _cell(
                                  context,
                                  c,
                                  i,
                                  hitPad,
                                  paintsSelection: false,
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                )
              : Column(
                  children: [
                    for (var row = 0; row < count; row += columns!)
                      Row(
                        children: [
                          for (
                            var i = row;
                            i < count && i < row + columns!;
                            i++
                          )
                            Expanded(
                              child: _cell(
                                context,
                                c,
                                i,
                                hitPad,
                                paintsSelection: true,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
        ),
      ],
    );
    return onSelected == null ? ExcludeSemantics(child: strip) : strip;
  }

  BoxDecoration _selection(SorbetColors c) => BoxDecoration(
    color: outlined ? c.bg : c.surface,
    borderRadius: BorderRadius.circular(outlined ? 16 : 18),
    border: Border.all(color: c.selectedBorder, width: 2),
    boxShadow: outlined
        ? null
        : [BoxShadow(color: c.shadowPill, offset: const Offset(0, 2))],
  );

  Widget _cell(
    BuildContext context,
    SorbetColors c,
    int i,
    double hitPad, {
    required bool paintsSelection,
  }) {
    final on = i == selected;
    return Semantics(
      button: onSelected != null,
      selected: on,
      inMutuallyExclusiveGroup: true,
      label: semanticLabels?[i],
      excludeSemantics: semanticLabels != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected == null ? null : () => onSelected!(i),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: hitPad),
          // Several rows cannot share one sliding selection: each cell fades its own.
          child: AnimatedContainer(
            duration: context.motion(Motion.fast),
            constraints: BoxConstraints(minHeight: cellHeight),
            decoration: paintsSelection && on
                ? _selection(c)
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(outlined ? 16 : 18),
                  ),
            child: AnimatedDefaultTextStyle(
              duration: context.motion(Motion.fast),
              style: DefaultTextStyle.of(context).style
                  .copyWith(color: on ? c.ink : c.muted),
              child: Center(child: itemBuilder(context, i, on)),
            ),
          ),
        ),
      ),
    );
  }
}
