import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/providers.dart';
import '../../core/domain/habit.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/segmented_strip.dart';
import 'progress_model.dart';

/// F-Progres: completion rate over a week, month or year.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  var _period = Period.week;

  /// Periods back from the current one.
  var _offset = 0;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider).value;
    final history = ref.watch(historyProvider).value;
    if (habits == null || history == null) return const SizedBox.shrink();
    final today = ref.watch(todayProvider);
    final data = buildProgress(
      history: history,
      habits: habits,
      period: _period,
      anchor: shiftPeriod(_period, today, _offset),
      today: today,
      firstWeekday: context.firstWeekday,
    );
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        _Header(
          period: _period,
          data: data,
          canGoNext: _offset < 0,
          onPeriod: (p) => setState(() {
            _period = p;
            _offset = 0;
          }),
          onShift: (by) => setState(() => _offset += by),
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
              _RateCard(period: _period, data: data),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(l10n.byHabit, style: text.titleMedium),
                      ),
                    ),
                    Text(
                      l10n.daysSucceeded,
                      style: text.bodySmall!.copyWith(color: c.muted),
                    ),
                  ],
                ),
              ),
              // 8 in the mockup, minus the 7 px of tap area above the pill.
              const SizedBox(height: 1),
              for (final (h, t) in data.rows)
                _HabitRow(
                  habit: h,
                  done: t.done,
                  planned: t.planned,
                  rate: t.rate,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.period,
    required this.data,
    required this.canGoNext,
    required this.onPeriod,
    required this.onShift,
  });

  final Period period;
  final ProgressData data;
  final bool canGoNext;
  final ValueChanged<Period> onPeriod;
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final overline = switch (period) {
      Period.week => fmt.dayRange(data.from, data.to),
      Period.month => fmt.monthYear(data.from),
      Period.year => '${data.from.year}',
    };
    final labels = [l10n.periodWeek, l10n.periodMonth, l10n.periodYear];
    return AppHeaderCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overline,
                      style: text.bodySmall!.copyWith(color: c.muted),
                    ),
                    Semantics(
                      header: true,
                      child: Text(l10n.tabProgress, style: text.headlineLarge),
                    ),
                  ],
                ),
              ),
              // 48 px targets shifted 4 px outwards: the 40 px discs keep the
              // 20 px margin, and the 2 px gaps make 10 px visually.
              const SizedBox(width: 2),
              Transform.translate(
                offset: const Offset(4, 0),
                child: Row(
                  spacing: 2,
                  children: [
                    _ArrowButton(
                      icon: PhosphorIconsBold.caretLeft,
                      label: l10n.previousPeriod,
                      onTap: () => onShift(-1),
                    ),
                    _ArrowButton(
                      icon: PhosphorIconsBold.caretRight,
                      label: l10n.nextPeriod,
                      onTap: canGoNext ? () => onShift(1) : null,
                    ),
                  ],
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
            container: true,
            label: l10n.periodLabel,
            child: SegmentedStrip(
              count: 3,
              cellHeight: 40,
              selected: period.index,
              onSelected: (i) => onPeriod(Period.values[i]),
              itemBuilder: (context, i, on) =>
                  Text(labels[i], style: text.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}

/// 40 px pale disc in a 48 px target; disabled shows the caret in flameOff.
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        radius: 24,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.bg),
              child: Icon(
                icon,
                size: 17,
                color: onTap == null ? c.flameOff : c.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.period, required this.data});

  final Period period;
  final ProgressData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final delta = data.deltaPoints;
    final up = (delta ?? 0) >= 0;
    final tones = c.tones[up ? HabitColor.mint : HabitColor.coral]!;
    final deltaText = delta == null
        ? null
        : '${up ? '+' : ''}${fmt.percent(delta / 100)}';
    final slices = data.slices;
    String sliceLabel(int i) {
      final s = slices[i];
      return switch (period) {
        Period.week => fmt.weekdayLetters(context.firstWeekday)[i],
        Period.month => fmt.dayOfMonth(s.from),
        Period.year => fmt.month(s.from)[0].toUpperCase(),
      };
    }

    String sliceA11y(int i) {
      final s = slices[i];
      final name = switch (period) {
        Period.week => fmt.weekdayShort(s.from),
        Period.month => fmt.dayRange(s.from, s.to),
        Period.year => fmt.month(s.from),
      };
      return '$name ${fmt.percent(s.tally.rate)}';
    }

    // 12 tubes do not fit with the 12 px gap of the week.
    final gap = slices.length > 7 ? 6.0 : 12.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: c.shadowPill, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fmt.percent(data.total.rate),
                      style: text.displaySmall!.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.pillsOf(
                        fmt.number(data.total.done),
                        fmt.number(data.total.planned),
                      ),
                      style: text.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (deltaText != null) ...[
                const SizedBox(width: 8),
                // Natural width up to 220 px: one line, as in the mockup.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tones.pale,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      switch (period) {
                        Period.week => l10n.vsLastWeek(deltaText),
                        Period.month => l10n.vsLastMonth(deltaText),
                        Period.year => l10n.vsLastYear(deltaText),
                      },
                      style: text.labelLarge!.copyWith(
                        color: tones.ink,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            container: true,
            excludeSemantics: true,
            label: l10n.rateA11y(
              [for (var i = 0; i < slices.length; i++) sliceA11y(i)].join(', '),
            ),
            child: Row(
              spacing: gap,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < slices.length; i++)
                  Expanded(
                    child: _Tube(
                      rate: slices[i].tally.rate,
                      current: i == data.current,
                      label: sliceLabel(i),
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

class _Tube extends StatelessWidget {
  const _Tube({required this.rate, required this.current, required this.label});

  final double rate;
  final bool current;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final radius = BorderRadius.circular(16);
    return Column(
      spacing: 6,
      children: [
        Container(
          height: 76,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: c.track, borderRadius: radius),
          foregroundDecoration: current
              ? BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: c.ink, width: 2.5),
                )
              : null,
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: rate,
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: rate >= 1 ? c.accent : c.habit[HabitColor.pink],
                borderRadius: radius,
              ),
            ),
          ),
        ),
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: current ? FontWeight.w600 : FontWeight.w400,
            color: current ? c.ink : c.muted,
          ),
        ),
      ],
    );
  }
}

/// 34 px pill inside a 48 px tap target; opens the habit's detail.
class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.habit,
    required this.done,
    required this.planned,
    required this.rate,
  });

  final Habit habit;
  final int done;
  final int planned;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(17);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => context.push(Routes.habit(habit.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Container(
            constraints: const BoxConstraints(minHeight: 34),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(color: c.shadowPill, offset: const Offset(0, 2)),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: rate,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.habit[habit.color],
                        borderRadius: radius,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(5, 4, 14, 4),
                  child: Row(
                    spacing: 8,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.iconHalo,
                        ),
                        child: Icon(
                          habitIcon(habit.icon),
                          size: 15,
                          color: c.ink,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium,
                        ),
                      ),
                      Text(
                        context.l10n.ratio(
                          context.habitFormat.number(done),
                          context.habitFormat.number(planned),
                        ),
                        style: text.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
