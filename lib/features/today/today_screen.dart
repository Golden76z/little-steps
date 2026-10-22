import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/quick_action.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/habit_pill.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/streak_chip.dart';
import '../../core/widgets/xp_avatar.dart';
import 'empty_today.dart';
import 'habit_options_sheet.dart';
import 'joker_sheet.dart';
import 'today_model.dart';

/// Day picked in the week strip or the calendar; null follows today.
final selectedDayProvider = NotifierProvider<SelectedDay, Day?>(
  SelectedDay.new,
);

class SelectedDay extends Notifier<Day?> {
  @override
  Day? build() => null;

  void select(Day? day) => state = day;
}

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider).value;
    final history = ref.watch(historyProvider).value;
    if (habits == null || history == null) return const SizedBox.shrink();
    final today = ref.watch(todayProvider);
    final selected = ref.watch(selectedDayProvider) ?? today;
    final data = buildToday(
      history: history,
      habits: habits,
      selected: selected,
      today: today,
      firstWeekday: context.firstWeekday,
    );
    final header = _TodayHeader(
      data: data,
      selected: selected,
      today: today,
      interactive: habits.isNotEmpty,
    );
    if (habits.isEmpty) return EmptyToday(header: header);

    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final editable = selected <= today;
    return Column(
      children: [
        const JokerPromptGate(),
        header,
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.paddingOf(context).bottom + 16,
            ),
            children: [
              for (final p in data.active) ...[
                _pill(context, ref, p, fmt, selected, editable),
                const SizedBox(height: 8),
              ],
              if (data.resting.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Text(
                    selected == today ? l10n.restToday : l10n.restOnDay,
                    style: Theme.of(context).textTheme.labelLarge!
                        .copyWith(color: c.muted),
                  ),
                ),
                for (final p in data.resting) ...[
                  _restingPill(context, ref, p, fmt),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(
    BuildContext context,
    WidgetRef ref,
    PillData p,
    HabitFormat fmt,
    Day day,
    bool editable,
  ) {
    final l10n = context.l10n;
    final h = p.habit;
    final percent = fmt.percent(p.progress);
    final action = quickAction(h, p.value);
    final hint = switch (action) {
      OpenDetail(startTimer: true) => l10n.hintStartTimer,
      OpenDetail() => l10n.hintWrite,
      SetValue() when h.type == HabitType.quantity => l10n.hintAdd(
        fmt.step(h)!,
      ),
      SetValue() => p.value >= 1 ? l10n.hintUncheck : l10n.hintCheck,
    };
    return HabitPill(
      name: h.name,
      subtitle: fmt.value(h, p.value, weekCount: p.weekCount),
      percent: percent,
      icon: habitIcon(h.icon),
      fill: context.sorbet.habit[h.color]!,
      progress: p.progress,
      done: p.done,
      semanticLabel: [
        l10n.pillLabel(h.name, percent),
        if (p.done) l10n.pillDone,
      ].join(', '),
      semanticHint: editable ? hint : null,
      iconSemanticLabel: '${h.name}, ${l10n.hintOpen}',
      onTap: editable
          ? () => _runQuickAction(context, ref, p, action, day)
          : null,
      onIconTap: () => context.push(Routes.habit(h.id)),
      onLongPress: () => showHabitOptions(context, h),
    );
  }

  Widget _restingPill(
    BuildContext context,
    WidgetRef ref,
    PillData p,
    HabitFormat fmt,
  ) {
    final l10n = context.l10n;
    final h = p.habit;
    final pause = h.pauses.where(
      (x) => x.covers(ref.read(selectedDayProvider) ?? ref.read(todayProvider)),
    );
    final subtitle = p.status == DayStatus.paused
        ? l10n.pausedUntil(fmt.longDate(pause.first.to))
        : l10n.restDay;
    return HabitPill(
      name: h.name,
      subtitle: subtitle,
      icon: habitIcon(h.icon),
      fill: context.sorbet.habit[h.color]!,
      progress: 0,
      showButton: false,
      semanticLabel: '${h.name}, $subtitle',
      iconSemanticLabel: '${h.name}, ${l10n.hintOpen}',
      onTap: () => context.push(Routes.habit(h.id)),
      onIconTap: () => context.push(Routes.habit(h.id)),
      onLongPress: () => showHabitOptions(context, h),
    );
  }

  Future<void> _runQuickAction(
    BuildContext context,
    WidgetRef ref,
    PillData p,
    QuickAction action,
    Day day,
  ) async {
    final h = p.habit;
    switch (action) {
      case OpenDetail(:final startTimer):
        context.push(Routes.habit(h.id, startTimer: startTimer));
      case SetValue(:final value):
        final l10n = context.l10n;
        final step = context.habitFormat.step(h);
        final messenger = ScaffoldMessenger.of(context);
        final repo = ref.read(habitRepositoryProvider);
        await repo.setEntry(HabitEntry(habitId: h.id, day: day, value: value));
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              persist: false,
              content: Text(switch (h.type) {
                HabitType.quantity => l10n.toastAdded(h.name, step!),
                _ when value >= 1 => l10n.toastChecked(h.name),
                _ => l10n.toastUnchecked(h.name),
              }),
              action: SnackBarAction(
                label: l10n.undo,
                onPressed: () => p.value == 0
                    ? repo.clearEntry(h.id, day)
                    : repo.setEntry(
                        HabitEntry(habitId: h.id, day: day, value: p.value),
                      ),
              ),
            ),
          );
    }
  }
}

class _TodayHeader extends ConsumerWidget {
  const _TodayHeader({
    required this.data,
    required this.selected,
    required this.today,
    required this.interactive,
  });

  final TodayData data;
  final Day selected;
  final Day today;

  /// False on the empty state, where the strip is decorative.
  final bool interactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final level = data.level;
    final title = selected == today
        ? l10n.tabToday
        : fmt.capitalized(fmt.longDate(selected));
    return AppHeaderCard(
      child: Column(
        children: [
          Row(
            children: [
              XpAvatar(
                fraction: level.fraction,
                semanticLabel: l10n.levelProgress(
                  level.level,
                  fmt.percent(level.fraction),
                  level.level + 1,
                ),
                onTap: interactive ? () => context.go(Routes.trophies) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.levelMonth(level.level, fmt.month(selected)),
                      style: text.bodySmall!.copyWith(color: c.muted),
                    ),
                    Semantics(
                      header: true,
                      child: Text(title, style: text.headlineLarge),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StreakChip(
                days: data.streak.current,
                semanticLabel: l10n.streakDays(data.streak.current),
              ),
              // 48 px target shifted 4 px outwards: the 40 px disc keeps the 20 px
              // margin, and the 2 px gap makes 10 px visually.
              const SizedBox(width: 2),
              Transform.translate(
                offset: const Offset(4, 0),
                child: Semantics(
                  button: true,
                  label: l10n.calendar,
                  excludeSemantics: true,
                  child: InkResponse(
                    radius: 24,
                    onTap: interactive ? () => _pickDate(context, ref) : null,
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
                          child: Icon(
                            PhosphorIconsRegular.calendarBlank,
                            size: 20,
                            color: c.ink,
                          ),
                        ),
                      ),
                    ),
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
          SegmentedStrip(
            count: 7,
            cellHeight: 58,
            selected: data.weekDays.indexOf(selected),
            semanticLabels: interactive
                ? [for (final d in data.weekDays) fmt.longDate(d)]
                : null,
            onSelected: interactive
                ? (i) => ref
                      .read(selectedDayProvider.notifier)
                      .select(
                        data.weekDays[i] == today ? null : data.weekDays[i],
                      )
                : null,
            itemBuilder: (context, i, on) {
              final d = data.weekDays[i];
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Text(
                    fmt.weekdayShort(d),
                    style: text.labelMedium!.copyWith(
                      color: on ? c.ink : c.muted,
                    ),
                  ),
                  Text(
                    fmt.dayOfMonth(d),
                    style: text.titleMedium!.copyWith(height: 1),
                  ),
                  if (interactive)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.loggedDays.contains(d) ? c.accent : null,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final habits = ref.read(habitsProvider).value ?? const <Habit>[];
    final first = habits
        .map((h) => h.createdOn)
        .fold(today, (a, b) => b < a ? b : a);
    final picked = await showDatePicker(
      context: context,
      initialDate: selected.toLocalDate(),
      firstDate: first.toLocalDate(),
      lastDate: today.toLocalDate(),
    );
    if (picked == null) return;
    final day = Day(picked.year, picked.month, picked.day);
    ref.read(selectedDayProvider.notifier).select(day == today ? null : day);
  }
}
