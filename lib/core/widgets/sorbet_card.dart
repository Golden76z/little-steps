import 'package:flutter/material.dart';

import '../theme/sorbet_colors.dart';

/// White section card with the candy drop shadow (radius 26).
class SorbetCard extends StatelessWidget {
  const SorbetCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 14),
    this.radius = 26,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: c.shadowPill, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}
