import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/dashed_border.dart';
import '../../core/widgets/press_scale.dart';
import '../create_habit/draft_provider.dart';
import '../create_habit/habit_draft.dart';

/// E1: first launch, no habit yet.
class EmptyToday extends ConsumerWidget {
  const EmptyToday({super.key, required this.header});

  final Widget header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final ideas = [
      (
        l10n.ideaWater,
        HabitDraft.fromPreset(Preset.water, name: l10n.popWater),
        PhosphorIconsRegular.drop,
      ),
      (
        l10n.ideaRead,
        HabitDraft.fromPreset(
          Preset.read,
          name: l10n.popRead,
        ).copyWith(goal: 10),
        PhosphorIconsRegular.book,
      ),
      (
        l10n.ideaMeditate,
        HabitDraft.fromPreset(Preset.meditate, name: l10n.popMeditate),
        PhosphorIconsRegular.timer,
      ),
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        children: [
          header,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 22),
                const ExcludeSemantics(child: _Illustration()),
                const SizedBox(height: 16),
                Text(
                  l10n.emptyTitle,
                  textAlign: TextAlign.center,
                  style: text.headlineLarge!.copyWith(height: 1.15),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.emptyBody,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: c.inkSoft,
                  ),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    boxShadow: [
                      BoxShadow(color: c.ctaShadow, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: () => context.push(Routes.create),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: c.accent,
                      foregroundColor: c.onAccent,
                      textStyle: text.titleMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      iconSize: 18,
                    ),
                    icon: const Icon(PhosphorIconsBold.plus),
                    label: Text(l10n.emptyCta),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.emptyIdeas,
                  style: text.labelLarge!.copyWith(color: c.muted),
                ),
                const SizedBox(height: 5),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    for (final (label, draft, icon) in ideas)
                      _IdeaChip(
                        label: label,
                        color: c.habit[draft.color]!,
                        icon: icon,
                        onTap: () {
                          ref.read(draftProvider.notifier).set(draft);
                          context.push(Routes.createSettings);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdeaChip extends StatelessWidget {
  const _IdeaChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final radius = BorderRadius.circular(19);
    // 38 px chip inside a 48 px tap target.
    return PressSink(
      depth: 2,
      builder: (context, pressed) => Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: c.shadowPill,
                    offset: Offset(0, 2 - 2 * pressed),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 5, 14, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 7,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      child: Icon(icon, size: 16, color: c.ink),
                    ),
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three tilted dashed pills and a sparkle.
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    Widget pill({Widget? child}) => DashedBorder(
      color: c.dashed,
      radius: 23,
      child: Container(
        height: 46,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsetsDirectional.only(start: 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(23),
        ),
        child: child,
      ),
    );
    const deg = 3.14159265 / 180;
    return SizedBox(
      width: 250,
      height: 162,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 10,
            right: 30,
            top: 8,
            child: Transform.rotate(angle: -4 * deg, child: pill()),
          ),
          Positioned(
            left: 30,
            right: 4,
            top: 62,
            child: Transform.rotate(
              angle: 3 * deg,
              child: pill(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.habit[HabitColor.sky],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 40,
            top: 116,
            child: Transform.rotate(angle: -2 * deg, child: pill()),
          ),
          Positioned(
            right: 0,
            top: -6,
            child: Icon(PhosphorIconsFill.sparkle, size: 34, color: c.accent),
          ),
        ],
      ),
    );
  }
}
