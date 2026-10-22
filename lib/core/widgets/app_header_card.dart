import 'package:flutter/material.dart';

import '../theme/sorbet_colors.dart';

/// White card under the status bar, bottom corners rounded to 32. Same
/// height on every screen: a 56 px top row, the divider, then a 66 px
/// band (a 58 px strip in its 4 px frame, or anything centred there).
class AppHeaderCard extends StatelessWidget {
  const AppHeaderCard({super.key, required this.top, required this.band});

  /// Title row: avatar or back button, title, actions.
  final Widget top;

  /// Under the divider.
  final Widget band;

  static const topHeight = 56.0;
  static const bandHeight = 66.0;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Container(
      width: double.infinity,
      // 52 in the 390×844 mockup = 44 status bar + 8.
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.viewPaddingOf(context).top + 8,
        20,
        16,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: c.cardShadow,
            offset: const Offset(0, 6),
            blurRadius: 20,
          ),
        ],
      ),
      // Minimum heights: larger system text may still grow them.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: topHeight),
            alignment: AlignmentDirectional.centerStart,
            // One line per text, so every header keeps the same height.
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              child: top,
            ),
          ),
          Container(
            height: 1.5,
            margin: const EdgeInsets.fromLTRB(4, 16, 4, 0),
            decoration: BoxDecoration(
              color: c.divider,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            constraints: const BoxConstraints(minHeight: bandHeight),
            alignment: Alignment.center,
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              child: band,
            ),
          ),
        ],
      ),
    );
  }
}
