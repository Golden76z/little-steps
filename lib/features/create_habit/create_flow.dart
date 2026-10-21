import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/round_icon_button.dart';

/// P1–P3 frame: header card with step chip and progress, scrolling
/// sections, call to action pinned 28 px from the bottom.
class CreateFlowScaffold extends StatelessWidget {
  const CreateFlowScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.children,
    required this.cta,
    this.closes = false,
  });

  final int step;
  final String title;
  final List<Widget> children;
  final Widget cta;

  /// P1 shows a close button, P2 and P3 a back caret.
  final bool closes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final bottom = math.max(28.0, MediaQuery.viewPaddingOf(context).bottom);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppHeaderCard(
                child: Column(
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        // 48 px target; shifted so the 40 px disc keeps the 20 px margin.
                        Transform.translate(
                          offset: const Offset(-4, 0),
                          child: RoundIconButton(
                            icon: closes
                                ? PhosphorIconsBold.x
                                : PhosphorIconsBold.caretLeft,
                            iconSize: closes ? 16 : 18,
                            label: closes ? l10n.close : l10n.back,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: text.headlineSmall,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          constraints: const BoxConstraints(minHeight: 28),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: c.bg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            l10n.stepOf(step, 3),
                            style: text.labelMedium!.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.inkSoft,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
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
                    Semantics(
                      label: l10n.stepProgress(step, 3),
                      excludeSemantics: true,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: c.strip,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          spacing: 3,
                          children: [
                            for (var i = 1; i <= 3; i++)
                              Expanded(
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i <= step ? c.accent : null,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                // Short form: a plain scroll view keeps every section built.
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 60 + 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
          Positioned(left: 20, right: 20, bottom: bottom, child: cta),
        ],
      ),
    );
  }
}

/// Section title inside a card (15/500), optional hint on the right.
class CardTitle extends StatelessWidget {
  const CardTitle(this.title, {super.key, this.hint});

  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(title, style: text.bodyMedium)),
        if (hint != null)
          Text(
            hint!,
            style: text.labelMedium!.copyWith(color: context.sorbet.muted),
          ),
      ],
    );
  }
}
