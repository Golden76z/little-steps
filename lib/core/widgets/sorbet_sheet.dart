import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../icons/phosphor_icons.dart';
import '../theme/sorbet_colors.dart';

/// Bottom sheet in the E2/E3 style: white, top corners 32, grab handle,
/// ink scrim.
Future<T?> showSorbetSheet<T>(BuildContext context, WidgetBuilder builder) {
  final c = context.sorbet;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: c.barrier,
    builder: (context) => DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: c.sheetShadow,
            offset: const Offset(0, -10),
            blurRadius: 30,
          ),
        ],
      ),
      child: SingleChildScrollView(
        // 28 from the bottom edge, as in the mockup, unless the system inset is taller.
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          math.max(28.0, MediaQuery.viewPaddingOf(context).bottom),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: c.handle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            builder(context),
          ],
        ),
      ),
    ),
  );
}

/// Sheet title row: habit disc, name, round close button.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.closeLabel,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, size: 20, color: c.ink),
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall!
                  .copyWith(height: null),
            ),
          ),
          // 48 px target; shifted so the 40 px disc keeps the 20 px margin.
          Transform.translate(
            offset: const Offset(4, 0),
            child: Semantics(
              button: true,
              label: closeLabel,
              excludeSemantics: true,
              child: InkResponse(
                onTap: () => Navigator.pop(context),
                radius: 24,
                child: SizedBox.square(
                  dimension: 48,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.bg,
                      ),
                      child: Icon(PhosphorIconsBold.x, size: 15, color: c.ink),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
