import 'package:flutter/material.dart';

import '../theme/sorbet_colors.dart';

/// White card under the status bar, bottom corners rounded to 32.
class AppHeaderCard extends StatelessWidget {
  const AppHeaderCard({super.key, required this.child});

  final Widget child;

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
      child: child,
    );
  }
}
