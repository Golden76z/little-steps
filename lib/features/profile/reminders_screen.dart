import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/providers.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/sorbet_card.dart';
import 'profile_screen.dart';

/// Every active habit with its reminder times; a row opens the habit,
/// where they are edited.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final habits = ref.watch(habitsProvider).value ?? const [];
    return Scaffold(
      body: Column(
        children: [
          AppHeaderCard(
            band: Container(
              constraints: const BoxConstraints(
                minHeight: AppHeaderCard.bandHeight,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.sorbet.strip,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                l10n.remindersSummary(
                  habits.length,
                  habits.fold(0, (n, h) => n + h.reminders.length),
                ),
                style: Theme.of(context).textTheme.bodyMedium!
                    .copyWith(color: context.sorbet.muted),
              ),
            ),
            top: Row(
              children: [
                // 48 px target shifted 4 px outwards: the 40 px disc keeps the
                // 20 px margin, and the 6 px gap makes 10 px visually.
                Transform.translate(
                  offset: const Offset(-4, 0),
                  child: RoundIconButton(
                    icon: PhosphorIconsBold.caretLeft,
                    label: l10n.backLabel,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.remindersTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.paddingOf(context).bottom + 16,
              ),
              children: [
                // Habits added or removed meanwhile: the card grows or shrinks.
                AnimatedSize(
                  duration: context.motion(Motion.resize),
                  curve: SpringCurve(Springs.smooth, Motion.resize),
                  alignment: Alignment.topCenter,
                  child: habits.isEmpty
                      ? const SizedBox(width: double.infinity)
                      : SorbetCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          child: Column(
                            children: [
                              for (final h in habits)
                                ProfileRow(
                                  leading: ProfileIconBox(
                                    color: c.habit[h.color]!,
                                    icon: habitIcon(h.icon),
                                    circle: true,
                                  ),
                                  label: h.name,
                                  value: h.reminders.isEmpty
                                      ? l10n.noReminder
                                      : formatReminders(context, h.reminders),
                                  onTap: () => context.push(Routes.habit(h.id)),
                                  last: h == habits.last,
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
