import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/dashed_border.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/sorbet_card.dart';
import 'detail_model.dart';
import 'detail_scaffold.dart';

/// T5: a "X times a week" habit. Week tab (session slots, the 7 days,
/// 8 weeks of bars) and a history tab (the same bars over 26 weeks).
class FrequencyDetail extends ConsumerStatefulWidget {
  const FrequencyDetail({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<FrequencyDetail> createState() => _FrequencyDetailState();
}

class _FrequencyDetailState extends ConsumerState<FrequencyDetail> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final h = widget.habit;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final c = context.sorbet;
    final history = ref.watch(historyProvider).value;
    final today = ref.watch(todayProvider);
    if (history == null) return const Scaffold();
    final firstWeekday = context.firstWeekday;
    final weeks = _tab == 0 ? 8 : 26;
    final counts = weeklyCounts(
      h,
      history,
      today,
      weeks,
      firstWeekday: firstWeekday,
    );
    final doneToday = history.isDone(h, today);
    final grid = SorbetCard(
      radius: 28,
      child: _WeeksGrid(
        habit: h,
        counts: counts,
        currentWeek: today.weekStart(firstWeekday),
      ),
    );
    return DetailScaffold(
      habit: h,
      subtitle: context.habitFormat.schedule(h),
      strip: Semantics(
        label: l10n.periodLabel,
        container: true,
        child: SegmentedStrip(
          count: 2,
          cellHeight: 58,
          selected: _tab,
          onSelected: (i) => setState(() => _tab = i),
          itemBuilder: (context, i, on) => Text(
            [l10n.periodWeek, l10n.historyTab][i],
            style: text.bodyLarge!.copyWith(color: on ? c.ink : c.muted),
          ),
        ),
      ),
      bottom: _SessionButton(
        done: doneToday,
        onPressed: () {
          final repo = ref.read(habitRepositoryProvider);
          doneToday
              ? repo.clearEntry(h.id, today)
              : repo.setEntry(HabitEntry(habitId: h.id, day: today, value: 1));
        },
      ),
      children: [
        if (_tab == 0) ...[
          _ThisWeek(habit: h, count: counts.last, today: today),
          const SizedBox(height: 12),
        ],
        grid,
      ],
    );
  }
}

class _ThisWeek extends ConsumerWidget {
  const _ThisWeek({
    required this.habit,
    required this.count,
    required this.today,
  });

  final Habit habit;
  final int count;
  final Day today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final text = Theme.of(context).textTheme;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final history = ref.watch(historyProvider).value!;
    final target = habit.timesPerWeek;
    final start = today.weekStart(context.firstWeekday);
    final end = start.addDays(6);
    final left = target - count;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: c.shadowPill, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(l10n.thisWeek, style: text.titleMedium)),
              Flexible(
                child: Text(
                  l10n.sessionsOf(count, target),
                  textAlign: TextAlign.end,
                  style: text.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ExcludeSemantics(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (var i = 0; i < target; i++)
                  i < count
                      ? Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tones.base,
                            boxShadow: [
                              BoxShadow(
                                color: tones.mid,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            PhosphorIconsBold.check,
                            size: 28,
                            color: c.ink,
                          ),
                        )
                      : SizedBox.square(
                          dimension: 64,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.surface,
                            ),
                            child: DashedBorder(
                              color: c.dashed,
                              radius: 32,
                              width: 3,
                              child: Center(
                                child: Icon(
                                  habitIcon(habit.icon),
                                  size: 28,
                                  color: c.radioOff,
                                ),
                              ),
                            ),
                          ),
                        ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            left <= 0
                ? l10n.weekGoalMet
                : l10n.sessionsLeft(
                    left,
                    DateFormat.EEEE(fmt.locale).format(end.toLocalDate()),
                    end.difference(today) + 1,
                  ),
            textAlign: TextAlign.center,
            style: text.bodySmall!.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 14),
          Semantics(
            label: l10n.weekSessionsA11y,
            container: true,
            excludeSemantics: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Row(
                spacing: 1,
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: _DayCell(
                        habit: habit,
                        day: start.addDays(i),
                        done: history.isDone(habit, start.addDays(i)),
                        today: start.addDays(i) == today,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.habit,
    required this.day,
    required this.done,
    required this.today,
  });

  final Habit habit;
  final Day day;
  final bool done;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final radius = BorderRadius.circular(3);
    // Mockup: today keeps an ink ring and shows a "+" until a session lands.
    final (bg, ink, icon) = done
        ? (c.tones[habit.color]!.base, c.ink, c.ink)
        : today
        ? (c.surface, c.ink, c.radioOff)
        : (c.cellOff, c.cellOffInk, null);
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      foregroundDecoration: today
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: c.ink, width: 2.5),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          Text(
            context.habitFormat.weekdayShort(day),
            style: Theme.of(context).textTheme.labelSmall!
                .copyWith(color: ink, height: 1),
          ),
          // Kept in the layout (hidden) so every cell has the same height.
          Visibility.maintain(
            visible: icon != null,
            child: Icon(
              today && !done ? PhosphorIconsBold.plus : habitIcon(habit.icon),
              size: 16,
              color: icon,
            ),
          ),
        ],
      ),
    );
  }
}

/// One column per week, oldest first, filled from the bottom by sessions
/// (capped at the target); goal-met weeks use the strong tone.
class _WeeksGrid extends StatelessWidget {
  const _WeeksGrid({
    required this.habit,
    required this.counts,
    required this.currentWeek,
  });

  final Habit habit;
  final List<int> counts;
  final Day currentWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final target = habit.timesPerWeek;
    final n = counts.length;
    final last = n - 1;
    // 26 narrow columns only fit three labels: first, middle, last.
    bool labelled(int w) => n <= 8 || w == 0 || w == 12 || w == last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailCardTitle(
          l10n.lastWeeks(n),
          hint: l10n.goalKept(counts.where((x) => x >= target).length),
          small: true,
        ),
        const SizedBox(height: 12),
        Semantics(
          label: l10n.weeksA11y(n),
          container: true,
          excludeSemantics: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              spacing: 1,
              children: [
                for (var w = 0; w < n; w++)
                  Expanded(
                    child: Column(
                      spacing: 1,
                      children: [
                        for (var r = 0; r < target; r++)
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: target - 1 - r < counts[w]
                                  ? (counts[w] >= target
                                        ? tones.strong
                                        : tones.base)
                                  : c.cellOff,
                            ),
                            foregroundDecoration: w == last
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: c.ink,
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var w = 0; w < n; w++)
                Expanded(
                  child: labelled(w)
                      // Labels may be wider than a 26-week column.
                      ? OverflowBox(
                          maxWidth: double.infinity,
                          fit: OverflowBoxFit.deferToChild,
                          alignment: n <= 8
                              ? Alignment.center
                              : w == 0
                              ? Alignment.centerLeft
                              : w == last
                              ? Alignment.centerRight
                              : Alignment.center,
                          child: Text(
                            l10n.weekShort(
                              isoWeek(currentWeek.addDays(-7 * (last - w))),
                            ),
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(fontSize: 11, color: c.faint),
                          ),
                        )
                      : const SizedBox(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom bar: logs today's session, or shows it logged (tap to undo).
class _SessionButton extends StatelessWidget {
  const _SessionButton({required this.done, required this.onPressed});

  final bool done;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: done ? c.shadowPill : c.ctaShadow,
            offset: Offset(0, done ? 3 : 4),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          backgroundColor: done ? c.surface : c.accent,
          foregroundColor: done ? c.ink : c.onAccent,
          textStyle: Theme.of(context).textTheme.titleMedium!
              .copyWith(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(
              done ? PhosphorIconsBold.check : PhosphorIconsBold.plus,
              size: 18,
            ),
            Flexible(
              child: Text(
                done ? l10n.sessionLogged : l10n.logSession,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
