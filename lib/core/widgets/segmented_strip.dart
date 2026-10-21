import 'package:flutter/material.dart';

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
  }) : outlined = true;

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

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final strip = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: outlined ? c.surface : c.strip,
        borderRadius: BorderRadius.circular(outlined ? 20 : 22),
        border: outlined ? Border.all(color: c.sheetDivider, width: 1.5) : null,
      ),
      child: Row(
        children: [
          for (var i = 0; i < count; i++) Expanded(child: _cell(context, c, i)),
        ],
      ),
    );
    return onSelected == null ? ExcludeSemantics(child: strip) : strip;
  }

  Widget _cell(BuildContext context, SorbetColors c, int i) {
    final on = i == selected;
    final radius = BorderRadius.circular(outlined ? 16 : 18);
    final content = DefaultTextStyle.merge(
      style: TextStyle(color: on ? c.ink : c.muted),
      child: Center(child: itemBuilder(context, i, on)),
    );
    return Semantics(
      button: onSelected != null,
      selected: on,
      inMutuallyExclusiveGroup: true,
      label: semanticLabels?[i],
      excludeSemantics: semanticLabels != null,
      child: Container(
        constraints: BoxConstraints(minHeight: cellHeight),
        decoration: BoxDecoration(
          color: on ? (outlined ? c.bg : c.surface) : null,
          borderRadius: radius,
          border: on ? Border.all(color: c.selectedBorder, width: 2) : null,
          boxShadow: on && !outlined
              ? [BoxShadow(color: c.shadowPill, offset: const Offset(0, 2))]
              : null,
        ),
        child: onSelected == null
            ? content
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: radius,
                  onTap: () => onSelected!(i),
                  child: content,
                ),
              ),
      ),
    );
  }
}
