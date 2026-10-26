import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/feedback/feedback.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/notifications/reminder_planner.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/dashed_border.dart';
import '../../core/widgets/fade_through_switcher.dart';
import '../../core/widgets/press_scale.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/rolling_text.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/sorbet_card.dart';
import '../../core/widgets/sorbet_switch.dart';
import 'create_flow.dart';
import 'draft_provider.dart';
import 'habit_draft.dart';
import 'labels.dart';
import '../../core/theme/motion.dart';
import '../today/pill_entrance.dart';

/// P3: rhythm, moment of the day, reminders.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final draft = ref.watch(draftProvider);
    void update(HabitDraft Function(HabitDraft) change) =>
        ref.read(draftProvider.notifier).update(change);
    // Days, times a week and reminders: a tick with each change.
    void pick(HabitDraft Function(HabitDraft) change) {
      ref.read(feedbackProvider).haptic(Haptic.tick);
      update(change);
    }

    String time(int minutes) =>
        MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        );

    return CreateFlowScaffold(
      step: 3,
      title: l10n.scheduleTitle,
      cta: PrimaryButton(
        label: draft.isEditing ? l10n.saveHabit : l10n.createHabit,
        icon: PhosphorIconsBold.check,
        onPressed: () => _save(context, ref, draft),
      ),
      children: [
        SorbetCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(l10n.rhythm),
              if (draft.type != HabitType.frequency) ...[
                const SizedBox(height: 10),
                Semantics(
                  label: l10n.rhythm,
                  container: true,
                  child: SegmentedStrip(
                    count: 2,
                    cellHeight: 40,
                    selected: draft.scheduleMode.index,
                    onSelected: (i) => update(
                      (d) => d.withScheduleMode(ScheduleMode.values[i]),
                    ),
                    itemBuilder: (context, i, on) => Text(
                      [l10n.rhythmDays, l10n.rhythmWeekly][i],
                      style: text.bodyMedium!.copyWith(
                        color: on ? c.ink : c.muted,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              FadeThroughSwitcher(
                child: KeyedSubtree(
                  key: ValueKey(draft.isWeekly),
                  child: draft.isWeekly
                      ? _TimesPerWeek(draft: draft, onChange: pick)
                      : _ActiveDays(draft: draft, onChange: pick),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SorbetCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(l10n.momentTitle),
              const SizedBox(height: 10),
              Semantics(
                label: l10n.momentLabel,
                container: true,
                child: SegmentedStrip(
                  count: 4,
                  cellHeight: 52,
                  selected: draft.moment.index,
                  onSelected: (i) =>
                      update((d) => d.withMoment(Moment.values[i])),
                  itemBuilder: (context, i, on) => Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 3,
                    children: [
                      Icon(
                        [
                          PhosphorIconsRegular.sunHorizon,
                          PhosphorIconsRegular.sun,
                          PhosphorIconsRegular.moon,
                          PhosphorIconsRegular.clock,
                        ][i],
                        size: 18,
                        color: on ? c.ink : c.muted,
                      ),
                      Text(
                        momentShort(l10n, Moment.values[i]),
                        style: text.labelMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: on ? c.ink : c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SorbetCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(l10n.remindersTitle),
              const SizedBox(height: 5),
              FadeThroughSwitcher(
                child: Wrap(
                  key: ValueKey(draft.reminders.join(',')),
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final m in draft.reminders)
                      _ReminderChip(
                        label: time(m),
                        semanticLabel: l10n.removeReminder(time(m)),
                        onTap: () => pick((d) => d.withReminderRemoved(m)),
                      ),
                    _AddReminder(
                      label: l10n.addReminder,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (picked != null) {
                          pick(
                            (d) => d.withReminderAdded(
                              picked.hour * 60 + picked.minute,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.streakDanger, style: text.bodyMedium),
                        Text(
                          l10n.streakDangerHint(time(streakDangerMinutes)),
                          style: text.labelMedium!.copyWith(color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  SorbetSwitch(
                    value: draft.streakDangerAlert,
                    label: l10n.streakDangerLabel,
                    onChanged: (v) =>
                        update((d) => d.copyWith(streakDangerAlert: v)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    HabitDraft draft,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(habitRepositoryProvider);
    final habit = draft.build(ref.read(todayProvider));
    if (draft.isEditing) {
      await repo.updateHabit(habit);
    } else {
      ref.read(justCreatedProvider.notifier).set(await repo.createHabit(habit));
    }
    if (!context.mounted) return;
    final route = ModalRoute.of(context)?.animation;
    final created = ref.read(justCreatedProvider.notifier);
    context.go(Routes.today);
    // The new pill comes in once this screen has slid away.
    void slidAway(AnimationStatus s) {
      if (s != AnimationStatus.dismissed) return;
      route?.removeStatusListener(slidAway);
      created.landed();
    }

    route == null ? created.landed() : route.addStatusListener(slidAway);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(draft.isEditing ? l10n.toastSaved : l10n.toastCreated),
        ),
      );
  }
}

class _ActiveDays extends StatelessWidget {
  const _ActiveDays({required this.draft, required this.onChange});

  final HabitDraft draft;
  final void Function(HabitDraft Function(HabitDraft)) onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    // Any week works: only the weekday names are needed, from the locale's first day.
    final start = Day(2026, 10, 19).weekStart(context.firstWeekday);
    final week = [for (var i = 0; i < 7; i++) start.addDays(i)];
    String full(Day d) => DateFormat.EEEE(locale).format(d.toLocalDate());
    final rest = [
      for (final d in week)
        if (!draft.activeDays.contains(d.weekday)) full(d),
    ];
    final restText = context.habitFormat.list(rest);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.activeDaysLabel,
          container: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // No spacing: each cell's target takes half of the 1 px gap on both
            // sides, so seven fit 48 px wide on a 412 dp phone.
            child: Row(
              children: [
                for (final d in week)
                  Expanded(
                    child: _dayCell(
                      context,
                      d,
                      draft.activeDays.contains(d.weekday),
                      full(d),
                      c,
                      text,
                      locale,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          rest.isEmpty
              ? l10n.daysHintAll
              : l10n.daysHint(7 - rest.length, restText),
          style: text.bodySmall!.copyWith(color: c.inkSoft),
        ),
      ],
    );
  }

  Widget _dayCell(
    BuildContext context,
    Day d,
    bool on,
    String name,
    SorbetColors c,
    TextTheme text,
    String locale,
  ) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      toggled: on,
      label: on ? l10n.dayActive(name) : l10n.dayRest(name),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChange((draft) => draft.toggleDay(d.weekday)),
        child: AnimatedContainer(
          duration: context.motion(Motion.fast),
          curve: Motion.curve,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          constraints: const BoxConstraints(minHeight: 58),
          decoration: BoxDecoration(
            color: on ? c.dayOn : c.cellOff,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              Text(
                DateFormat.EEEEE(locale).format(d.toLocalDate()).toUpperCase(),
                style: text.bodySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: on ? c.dayOnInk : c.cellOffInk,
                ),
              ),
              Icon(
                on ? PhosphorIconsBold.check : PhosphorIconsRegular.moon,
                size: 14,
                color: on ? c.dayOnInk : c.flameOff,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimesPerWeek extends StatelessWidget {
  const _TimesPerWeek({required this.draft, required this.onChange});

  final HabitDraft draft;
  final void Function(HabitDraft Function(HabitDraft)) onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            RoundIconButton(
              icon: PhosphorIconsBold.minus,
              size: 48,
              label: l10n.fewer,
              onTap: () =>
                  onChange((d) => d.withTimesPerWeek(d.timesPerWeek - 1)),
            ),
            Expanded(
              child: Column(
                children: [
                  RollingText(
                    context.habitFormat.number(draft.timesPerWeek),
                    value: draft.timesPerWeek,
                    style: text.displaySmall,
                  ),
                  Text(
                    l10n.timesPerWeek,
                    style: text.bodySmall!.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
            RoundIconButton(
              icon: PhosphorIconsBold.plus,
              size: 48,
              label: l10n.more,
              onTap: () =>
                  onChange((d) => d.withTimesPerWeek(d.timesPerWeek + 1)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l10n.weeklyHint,
          style: text.bodySmall!.copyWith(color: c.inkSoft),
        ),
      ],
    );
  }
}

/// 38 px chip in a 48 px target; a tap removes the reminder.
class _ReminderChip extends StatelessWidget {
  const _ReminderChip({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: PressScale(
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: c.strip,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  Icon(PhosphorIconsRegular.bell, size: 16, color: c.ink),
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddReminder extends StatelessWidget {
  const _AddReminder({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: DashedBorder(
              color: c.dashed,
              radius: 19,
              width: 2,
              child: SizedBox.square(
                dimension: 38,
                child: Icon(PhosphorIconsBold.plus, size: 16, color: c.muted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
