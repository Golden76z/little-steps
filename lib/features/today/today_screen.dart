import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/quick_action.dart';
import '../../core/domain/rewards.dart';
import '../../core/domain/rules.dart';
import '../../core/feedback/celebrated.dart';
import '../../core/feedback/feedback.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/habit_pill.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/streak_chip.dart';
import '../../core/widgets/xp_avatar.dart';
import '../habit_detail/session_timer.dart';
import 'empty_today.dart';
import 'habit_options_sheet.dart';
import 'joker_sheet.dart';
import 'pending_entries.dart';
import 'pill_entrance.dart';
import 'today_model.dart';
import 'xp_flight.dart';

/// Day picked in the week strip or the calendar; null follows today.
final selectedDayProvider = NotifierProvider<SelectedDay, Day?>(
  SelectedDay.new,
);

class SelectedDay extends Notifier<Day?> {
  @override
  Day? build() => null;

  void select(Day? day) => state = day;
}

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

/// Taps in a row on one habit: one message, and Annuler goes back to
/// [before], the value ahead of the first tap.
class _Burst {
  _Burst(this.habitId, this.day, this.before, String text)
    : text = ValueNotifier(text);

  final int habitId;
  final Day day;
  final double before;
  final ValueNotifier<String> text;
  bool closed = false;
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final _avatarKey = GlobalKey();
  final _pillKeys = <int, GlobalKey>{};
  final _celebrations = <int, int>{};
  _Burst? _burst;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider).value;
    final stored = ref.watch(historyProvider).value;
    final pending = ref.watch(pendingEntriesProvider);
    return AnimatedSwitcher(
      duration: context.motion(Motion.medium),
      switchInCurve: Motion.curve,
      switchOutCurve: Motion.curve,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      // Fades in once loaded rather than popping in.
      child: habits == null || stored == null
          ? const SizedBox.shrink()
          : KeyedSubtree(
              key: const ValueKey(true),
              child: _content(context, habits, stored.withValues(pending)),
            ),
    );
  }

  Widget _content(BuildContext context, List<Habit> habits, History history) {
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
      avatarKey: _avatarKey,
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
              for (final p in data.active)
                Padding(
                  key: _pillKeys.putIfAbsent(p.habit.id, GlobalKey.new),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PillEntrance(
                    habitId: p.habit.id,
                    child: _pill(context, p, fmt, selected, editable, history),
                  ),
                ),
              if (data.resting.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Text(
                    selected == today ? l10n.restToday : l10n.restOnDay,
                    style: Theme.of(context).textTheme.labelLarge!
                        .copyWith(color: c.muted),
                  ),
                ),
                for (final p in data.resting)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PillEntrance(
                      habitId: p.habit.id,
                      child: _restingPill(context, p, fmt, selected),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(
    BuildContext context,
    PillData p,
    HabitFormat fmt,
    Day day,
    bool editable,
    History history,
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
    // A hold logs the goal: minutes for a duration, today for a frequency.
    final goal = switch (h.type) {
      HabitType.yesNo || HabitType.frequency => 1.0,
      _ => h.goal,
    };
    final holdable =
        editable && !p.done && h.type != HabitType.journal && p.value < goal;
    return HabitPill(
      key: ValueKey(h.id),
      name: h.name,
      subtitle: fmt.value(h, p.value, weekCount: p.weekCount),
      percent: percent,
      icon: habitIcon(h.icon),
      fill: context.sorbet.habit[h.color]!,
      progress: p.progress,
      done: p.done,
      celebrate: _celebrations[h.id] ?? 0,
      semanticLabel: [
        l10n.pillLabel(h.name, percent),
        if (p.done) l10n.pillDone,
      ].join(', '),
      semanticHint: editable ? hint : null,
      iconSemanticLabel: '${h.name}, ${l10n.hintOpen}',
      onTap: editable
          ? () => switch (action) {
              OpenDetail(:final startTimer) => context.push(
                Routes.habit(h.id, startTimer: startTimer),
              ),
              SetValue(:final value) => _setValue(p, value, day, history),
            }
          : null,
      onHoldComplete: holdable
          ? () {
              _setValue(p, goal, day, history);
              // Ends an open session, or its pause would log over the goal.
              if (h.type == HabitType.duration) {
                ref.read(sessionTimersProvider.notifier).markDone(h);
              }
            }
          : null,
      onIconTap: () => context.push(Routes.habit(h.id)),
      onIconLongPress: () => _options(h),
    );
  }

  Widget _restingPill(
    BuildContext context,
    PillData p,
    HabitFormat fmt,
    Day day,
  ) {
    final l10n = context.l10n;
    final h = p.habit;
    final pause = h.pauses.where((x) => x.covers(day));
    final subtitle = p.status == DayStatus.paused
        ? l10n.pausedUntil(fmt.longDate(pause.first.to))
        : l10n.restDay;
    return HabitPill(
      key: ValueKey(h.id),
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
      onLongPress: () => _options(h),
    );
  }

  void _options(Habit h) {
    ref.read(feedbackProvider).haptic(Haptic.light);
    showHabitOptions(context, h);
  }

  /// Logs [value] at once (the pill fills on this frame), plays what it
  /// earns, and shows or updates the message to undo the burst.
  void _setValue(PillData p, double value, Day day, History history) {
    final h = p.habit;
    final l10n = context.l10n;
    final today = ref.read(todayProvider);
    final after = history.withValues({(h.id, day): value});
    final done = buildToday(
      history: after,
      habits: [h],
      selected: day,
      today: today,
      firstWeekday: context.firstWeekday,
    ).active.single.done;
    final feedback = ref.read(feedbackProvider);
    if (value > p.value) {
      if (done && !p.done) {
        if (ref.read(celebratedProvider.notifier).claim('habit:${h.id}:$day')) {
          setState(() => _celebrations[h.id] = (_celebrations[h.id] ?? 0) + 1);
          feedback
            ..haptic(Haptic.success)
            ..sound(Sound.done);
        } else {
          feedback.haptic(Haptic.light);
        }
      } else {
        feedback
          ..haptic(Haptic.light)
          ..sound(Sound.pop);
      }
      showXpFlight(
        context,
        from: _pillKeys[h.id]!,
        to: _avatarKey,
        xp: levelXp(after, today) - levelXp(history, today),
      );
    } else {
      feedback.haptic(Haptic.light);
    }

    final pending = ref.read(pendingEntriesProvider.notifier);
    pending.set(h.id, day, value);
    final current = _burst;
    final ongoing =
        current != null &&
        !current.closed &&
        current.habitId == h.id &&
        current.day == day;
    final before = ongoing ? current.before : p.value;
    final text = switch (h.type) {
      // The whole burst, which is what Annuler takes back.
      HabitType.quantity => l10n.toastAdded(
        h.name,
        context.habitFormat.step(h, value - before)!,
      ),
      _ when value >= 1 => l10n.toastChecked(h.name),
      _ => l10n.toastUnchecked(h.name),
    };
    if (ongoing) {
      current.text.value = text;
      return;
    }
    final burst = _burst = _Burst(h.id, day, before, text);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            persist: false,
            content: ValueListenableBuilder(
              valueListenable: burst.text,
              builder: (context, text, _) => Text(text),
            ),
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () => pending.set(h.id, day, burst.before),
            ),
          ),
        )
        .closed
        .then((_) => burst.closed = true);
  }
}

class _TodayHeader extends ConsumerWidget {
  const _TodayHeader({
    required this.data,
    required this.selected,
    required this.today,
    required this.interactive,
    required this.avatarKey,
  });

  final TodayData data;
  final Day selected;
  final Day today;

  /// False on the empty state, where the strip is decorative.
  final bool interactive;
  final GlobalKey avatarKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final level = data.level;
    final title = selected == today
        ? l10n.tabToday
        : fmt.capitalized(fmt.weekdayDay(selected));
    return AppHeaderCard(
      top: Row(
        children: [
          XpAvatar(
            key: avatarKey,
            fraction: level.fraction,
            level: level.level,
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
                  child: FittedBox(
                    // Always one line: shrinks rather than wraps.
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(title, maxLines: 1, style: text.headlineLarge),
                  ),
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
      band: SegmentedStrip(
        count: 7,
        cellHeight: 58,
        selected: data.weekDays.indexOf(selected),
        semanticLabels: interactive
            ? [for (final d in data.weekDays) fmt.longDate(d)]
            : null,
        onSelected: interactive
            ? (i) => ref
                  .read(selectedDayProvider.notifier)
                  .select(data.weekDays[i] == today ? null : data.weekDays[i])
            : null,
        itemBuilder: (context, i, on) {
          final d = data.weekDays[i];
          return Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Text(
                fmt.weekdayShort(d),
                style: text.labelMedium!.copyWith(color: on ? c.ink : c.muted),
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
