import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/habit.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/round_icon_button.dart';
import '../create_habit/draft_provider.dart';
import '../create_habit/habit_draft.dart';

/// T1–T5 frame: header card (back, habit disc, name, edit, strip),
/// scrolling sections, optional bottom bar 28 px from the edge.
class DetailScaffold extends ConsumerWidget {
  const DetailScaffold({
    super.key,
    required this.habit,
    required this.subtitle,
    required this.children,
    required this.strip,
    this.bottom,
  });

  final Habit habit;
  final String subtitle;

  /// Segmented strip under the header divider (58 px cells).
  final Widget strip;
  final List<Widget> children;

  /// 60 px action bar; the content scrolls clear of it.
  final Widget? bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final inset = math.max(28.0, MediaQuery.viewPaddingOf(context).bottom);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppHeaderCard(
                band: strip,
                top: Row(
                  children: [
                    // 48 px targets shifted 4 px outwards: the 40 px discs keep the
                    // 20 px margin, and the 2 px gaps make 10 px visually.
                    Transform.translate(
                      offset: const Offset(-4, 0),
                      child: RoundIconButton(
                        icon: PhosphorIconsBold.caretLeft,
                        label: l10n.backLabel,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.habit[habit.color],
                      ),
                      child: Icon(
                        habitIcon(habit.icon),
                        size: 22,
                        color: c.ink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(habit.name, style: text.headlineMedium),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: text.bodySmall!.copyWith(color: c.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 2),
                    Transform.translate(
                      offset: const Offset(4, 0),
                      child: RoundIconButton(
                        icon: PhosphorIconsRegular.pencilSimple,
                        iconSize: 19,
                        label: l10n.editHabit,
                        onTap: () {
                          ref
                              .read(draftProvider.notifier)
                              .set(HabitDraft.fromHabit(habit));
                          context.push(Routes.createSettings);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    bottom == null ? inset : inset + 60 + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
          if (bottom != null)
            Positioned(left: 20, right: 20, bottom: inset, child: bottom!),
        ],
      ),
    );
  }
}

/// Section title of a detail card (18/600) with a muted hint on the right.
class DetailCardTitle extends StatelessWidget {
  const DetailCardTitle(this.title, {super.key, this.hint, this.small = false});

  final String title;
  final String? hint;

  /// 17 px titles (T2, T5 history) instead of 18.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(title, style: small ? text.titleSmall : text.titleMedium),
        ),
        // Flexible: with large text the hint wraps instead of overflowing.
        if (hint != null)
          Flexible(
            child: Text(
              hint!,
              textAlign: TextAlign.end,
              style: text.labelMedium!.copyWith(color: context.sorbet.muted),
            ),
          ),
      ],
    );
  }
}
