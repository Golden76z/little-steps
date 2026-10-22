import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/rules.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/dashed_border.dart';
import '../../core/widgets/marked_text.dart';
import '../../core/widgets/press_scale.dart';
import '../../core/widgets/month_mosaic.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/sorbet_card.dart';
import 'detail_model.dart';
import 'detail_scaffold.dart';
import '../../core/theme/motion.dart';

/// T3: streak and the big check, month (or year) of done days, joker tip.
class YesNoDetail extends ConsumerStatefulWidget {
  const YesNoDetail({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<YesNoDetail> createState() => _YesNoDetailState();
}

class _YesNoDetailState extends ConsumerState<YesNoDetail> {
  bool _year = false;

  Habit get _habit => widget.habit;

  /// "jours", "soirs"… after the moment of the habit.
  String _unit(AppLocalizations l10n, num count) => switch (_habit.moment) {
    Moment.morning => l10n.unitMornings(count),
    Moment.noon => l10n.unitNoons(count),
    Moment.evening => l10n.unitEvenings(count),
    Moment.anytime => l10n.unitDays(count),
  };

  String _time(int minutes) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider).value;
    if (history == null) return const Scaffold();
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final today = ref.watch(todayProvider);
    final stats = habitStats(
      _habit,
      history,
      today,
      firstWeekday: context.firstWeekday,
    );
    final reminder = _habit.reminders.firstOrNull;
    return DetailScaffold(
      habit: _habit,
      subtitle: [
        if (reminder != null) l10n.fromTime(_time(reminder)),
        fmt.schedule(_habit),
      ].join(' · '),
      strip: Semantics(
        label: l10n.periodLabel,
        container: true,
        child: SegmentedStrip(
          count: 2,
          cellHeight: 58,
          selected: _year ? 1 : 0,
          onSelected: (i) => setState(() => _year = i == 1),
          itemBuilder: (context, i, on) => Text(
            [l10n.periodMonth, l10n.periodYear][i],
            style: Theme.of(context).textTheme.bodyLarge!
                .copyWith(color: on ? c.ink : c.muted),
          ),
        ),
      ),
      children: [
        _StreakCard(
          habit: _habit,
          stats: stats,
          done: history.isDone(_habit, today),
          unit: _unit(l10n, stats.streak.current),
          reminder: reminder == null ? null : _time(reminder),
          onToggle: () {
            final repo = ref.read(habitRepositoryProvider);
            history.isDone(_habit, today)
                ? repo.clearEntry(_habit.id, today)
                : repo.setEntry(
                    HabitEntry(habitId: _habit.id, day: today, value: 1),
                  );
          },
        ),
        const SizedBox(height: 12),
        if (_year)
          _YearCard(habit: _habit, history: history, today: today)
        else
          _MonthCard(
            habit: _habit,
            history: history,
            today: today,
            stats: stats,
            unit: _unit(l10n, stats.monthDue),
          ),
        const SizedBox(height: 12),
        _JokerTip(
          text: l10n.jokerTip(
            _unit(l10n, 1),
            fmt.number(jokerBalance(history, today)),
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.habit,
    required this.stats,
    required this.done,
    required this.unit,
    required this.reminder,
    required this.onToggle,
  });

  final Habit habit;
  final HabitStats stats;
  final bool done;
  final String unit;
  final String? reminder;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final text = Theme.of(context).textTheme;
    final button = AnimatedContainer(
      // Fill fades in, as in the mockup (background 0.2 s).
      duration: context.motion(const Duration(milliseconds: 200)),
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? tones.mid : c.surface,
        boxShadow: done
            ? [BoxShadow(color: tones.deep, offset: const Offset(0, 5))]
            : null,
      ),
      // Large system text shrinks inside the fixed 118 px disc instead of overflowing.
      padding: const EdgeInsets.all(14),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            Icon(
              PhosphorIconsBold.check,
              size: 36,
              color: done ? c.ink : c.radioOff,
            ),
            Text(
              done ? l10n.doneLabel : l10n.iDidIt,
              textAlign: TextAlign.center,
              style: text.bodyMedium!.copyWith(height: 1.1),
            ),
          ],
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: c.shadowPill, offset: const Offset(0, 4))],
      ),
      child: Row(
        spacing: 14,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Icon(PhosphorIconsFill.fire, size: 16, color: c.flame),
                    Flexible(
                      child: Text(
                        l10n.currentStreak,
                        style: text.labelLarge!.copyWith(color: c.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  fmt.number(stats.streak.current),
                  style: text.displayMedium!.copyWith(fontSize: 56),
                ),
                Text(l10n.inARow(unit), style: text.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  [
                    l10n.bestLine(fmt.number(stats.streak.best)),
                    if (reminder != null) l10n.reminderAt(reminder!),
                  ].join(' · '),
                  style: text.labelMedium!.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            toggled: done,
            label: done ? l10n.doneLabel : l10n.iDidIt,
            excludeSemantics: true,
            child: PressScale(
              child: GestureDetector(
                onTap: onToggle,
                child: done
                    ? button
                    : DashedBorder(
                        color: c.dashed,
                        radius: 59,
                        width: 3,
                        child: button,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.habit,
    required this.history,
    required this.today,
    required this.stats,
    required this.unit,
  });

  final Habit habit;
  final History history;
  final Day today;
  final HabitStats stats;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final text = Theme.of(context).textTheme;
    final small = text.labelSmall!.copyWith(height: 1);
    final month = fmt.month(today);

    MosaicCell cellFor(Day d) {
      Text number(Color color) =>
          Text(fmt.dayOfMonth(d), style: small.copyWith(color: color));
      return switch (dayCell(habit, history, d, today).state) {
        DayCellState.done => MosaicCell(
          color: tones.mid,
          ring: d == today,
          child: Icon(PhosphorIconsBold.check, size: 14, color: c.ink),
        ),
        DayCellState.joker => MosaicCell(
          color: c.jokerCell,
          child: Icon(PhosphorIconsFill.shield, size: 14, color: c.joker),
        ),
        DayCellState.missed || DayCellState.partial => MosaicCell(
          color: c.chipOff,
          child: number(c.faint),
        ),
        DayCellState.today => MosaicCell(
          color: c.surface,
          ring: true,
          child: number(c.ink),
        ),
        DayCellState.future || DayCellState.rest || DayCellState.untracked =>
          MosaicCell(color: c.cellOff, child: number(c.cellOffInk)),
      };
    }

    Widget legend(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(label, style: text.labelMedium!.copyWith(color: c.inkSoft)),
      ],
    );

    return _Card(
      children: [
        DetailCardTitle(
          fmt.capitalized(month),
          hint: l10n.doneOf(
            fmt.number(stats.monthDone),
            unit,
            fmt.number(stats.monthDue),
          ),
        ),
        const SizedBox(height: 10),
        MonthMosaic(
          days: monthGrid(today, context.firstWeekday),
          weekdayLetters: fmt.weekdayLetters(context.firstWeekday),
          semanticLabel: l10n.monthDoneA11y(month),
          cellFor: cellFor,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            legend(tones.mid, l10n.legendDone),
            legend(c.jokerCell, l10n.legendJoker),
            legend(c.chipOff, l10n.legendMissed),
          ],
        ),
      ],
    );
  }
}

/// Year view (not in the mockups): one glued row of days per month.
class _YearCard extends StatelessWidget {
  const _YearCard({
    required this.habit,
    required this.history,
    required this.today,
  });

  final Habit habit;
  final History history;
  final Day today;

  @override
  Widget build(BuildContext context) {
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    Color colorOf(Day d) => switch (dayCell(habit, history, d, today).state) {
      DayCellState.done => tones.mid,
      DayCellState.joker => c.jokerCell,
      DayCellState.missed || DayCellState.partial => c.chipOff,
      DayCellState.today => c.surface,
      _ => c.cellOff,
    };
    return _Card(
      children: [
        DetailCardTitle(fmt.number(today.year).replaceAll(RegExp(r'\D'), '')),
        const SizedBox(height: 10),
        for (var m = 1; m <= 12; m++)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    DateFormat.MMM(locale)
                        .format(DateTime(today.year, m))
                        .replaceAll('.', ''),
                    style: text.labelSmall!.copyWith(
                      fontSize: 11,
                      color: c.faint,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      spacing: 1,
                      children: [
                        for (var d = 1; d <= 31; d++)
                          Expanded(
                            child: Container(
                              height: 12,
                              color:
                                  d <= DateUtils.getDaysInMonth(today.year, m)
                                  ? colorOf(Day(today.year, m, d))
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _JokerTip extends StatelessWidget {
  const _JokerTip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final style = Theme.of(context).textTheme.bodySmall!
        .copyWith(height: 1.25, color: c.ink);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.jokerSoft,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: c.jokerSoftShadow, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.surface),
            child: Icon(PhosphorIconsFill.shield, size: 20, color: c.joker),
          ),
          Expanded(
            child: MarkedText(
              text,
              style: style,
              strong: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SorbetCard(
    radius: 28,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}
