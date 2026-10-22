import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/rules.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/month_mosaic.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/sorbet_card.dart';
import '../create_habit/habit_draft.dart';
import '../create_habit/labels.dart';
import 'detail_model.dart';
import 'detail_scaffold.dart';
import '../../core/theme/motion.dart';

/// T1: today's amount over a wave, quick step, stats (from F-Fiche) and
/// the month calendar.
class QuantityDetail extends ConsumerWidget {
  const QuantityDetail({super.key, required this.habit});

  final Habit habit;

  QuantityUnit get _unit => habit.unit ?? QuantityUnit.times;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider).value;
    if (history == null) return const Scaffold();
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final today = ref.watch(todayProvider);
    final value = history.valueOf(habit.id, today);
    final step = fmt.step(habit)!;
    final repo = ref.read(habitRepositoryProvider);

    Future<void> save(double v) => v <= 0
        ? repo.clearEntry(habit.id, today)
        : repo.setEntry(HabitEntry(habitId: habit.id, day: today, value: v));
    Future<void> edit(HabitDraft Function(HabitDraft) change) =>
        repo.updateHabit(
          change(HabitDraft.fromHabit(habit)).build(habit.createdOn),
        );

    // Volumes can be read in glasses or litres (ml only when chosen).
    final units = [
      QuantityUnit.glasses,
      QuantityUnit.liters,
      if (_unit == QuantityUnit.milliliters) QuantityUnit.milliliters,
    ];
    return DetailScaffold(
      habit: habit,
      subtitle: '${fmt.goal(habit)} · ${fmt.schedule(habit)}',
      strip: _unit.isVolume
          ? Semantics(
              label: l10n.displayedUnit,
              container: true,
              child: SegmentedStrip(
                count: units.length,
                cellHeight: 58,
                selected: units.indexOf(_unit),
                onSelected: (i) => edit((d) => d.copyWith(unit: units[i])),
                itemBuilder: (context, i, on) => Text(
                  unitLabel(l10n, units[i]),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: on ? context.sorbet.ink : context.sorbet.muted,
                  ),
                ),
              ),
            )
          // No unit to switch: the quick steps take the band instead.
          : Semantics(
              label: l10n.amountAdded,
              container: true,
              child: SegmentedStrip(
                count: _unit.stepPresets.length,
                cellHeight: 58,
                selected: _unit.stepPresets.indexOf(habit.step),
                onSelected: (i) =>
                    edit((d) => d.copyWith(step: _unit.stepPresets[i])),
                itemBuilder: (context, i, on) => Text(
                  '+${fmt.step(HabitDraft.fromHabit(habit).copyWith(step: _unit.stepPresets[i]).build(habit.createdOn))}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: on ? context.sorbet.ink : context.sorbet.muted,
                  ),
                ),
              ),
            ),
      bottom: Row(
        spacing: 10,
        children: [
          _MinusButton(
            label: l10n.removeStep(step),
            onTap: value > 0 ? () => save(value - habit.step) : null,
          ),
          Expanded(
            child: PrimaryButton(
              label: habit.isCompleted(value) ? l10n.goalReached : '+$step',
              icon: PhosphorIconsBold.plus,
              onPressed: () => save(value + habit.step),
            ),
          ),
        ],
      ),
      children: [
        _WaveCard(habit: habit, value: value),
        if (_unit.isVolume) ...[
          const SizedBox(height: 14),
          _StepPicker(
            habit: habit,
            onSelected: (s) => edit((d) => d.copyWith(step: s)),
          ),
        ],
        const SizedBox(height: 12),
        _StatsPanel(
          stats: habitStats(
            habit,
            history,
            today,
            firstWeekday: context.firstWeekday,
          ),
        ),
        const SizedBox(height: 12),
        _MonthCard(habit: habit, history: history, today: today),
      ],
    );
  }
}

/// Text of an amount in the display unit: "1,25" L, "5" glasses, "750" ml.
String _amount(HabitFormat fmt, Habit h, double v) {
  final unit = h.unit ?? QuantityUnit.times;
  return fmt.number(
    unit == QuantityUnit.glasses
        ? (v / 250).roundToDouble()
        : v / unit.baseFactor,
  );
}

class _WaveCard extends StatelessWidget {
  const _WaveCard({required this.habit, required this.value});

  final Habit habit;
  final double value;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final text = Theme.of(context).textTheme;
    final unit = habit.unit ?? QuantityUnit.times;
    final p = habit.progress(value);
    final goalShort = unit == QuantityUnit.glasses
        ? fmt.number(habit.goal / 250)
        : fmt.goal(habit);
    final sub = switch (unit) {
      QuantityUnit.glasses => l10n.litersOf(
        fmt.number(value / 1000),
        fmt.number(habit.goal / 1000),
      ),
      QuantityUnit.liters || QuantityUnit.milliliters => l10n.glassesOf(
        fmt.number((value / 250).roundToDouble()),
        value / 250,
      ),
      _ => l10n.percentOfGoal(fmt.percent(p)),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 168),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: c.shadowPill, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                children: [
                  _wave(
                    box,
                    0.10 + p * 0.50,
                    tones.mid.withValues(alpha: 0.55),
                    wide: true,
                  ),
                  _wave(box, 0.16 + p * 0.52, tones.base),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
            child: Column(
              children: [
                Text(
                  l10n.tabToday,
                  style: text.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.subtitle,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: _amount(fmt, habit, value),
                    children: [
                      TextSpan(
                        text: ' ${l10n.bigOf(goalShort)}',
                        style: text.displaySmall!.copyWith(
                          fontSize: 26,
                          color: c.subtitle,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: text.displayLarge!.copyWith(fontSize: 60),
                ),
                Text(sub, textAlign: TextAlign.center, style: text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Rising water: the back wave is wider and paler, as in the mockup.
  Widget _wave(
    BoxConstraints box,
    double height,
    Color color, {
    bool wide = false,
  }) {
    final w = box.maxWidth * (wide ? 1.2 : 1);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      left: wide ? -box.maxWidth * 0.1 : 0,
      width: w,
      bottom: 0,
      height: box.maxHeight * height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(w * (wide ? 0.4 : 0.6), wide ? 24 : 20),
            topRight: Radius.elliptical(w * (wide ? 0.6 : 0.4), wide ? 16 : 20),
          ),
        ),
      ),
    );
  }
}

/// White band of quick steps; the chosen one takes the habit colour.
class _StepPicker extends StatelessWidget {
  const _StepPicker({required this.habit, required this.onSelected});

  final Habit habit;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final text = Theme.of(context).textTheme;
    final presets = (habit.unit ?? QuantityUnit.times).stepPresets;
    String label(double s) =>
        '+${fmt.step(HabitDraft.fromHabit(habit).copyWith(step: s).build(habit.createdOn))}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(l10n.addBy, style: text.bodyMedium)),
              Flexible(
                child: Text(
                  l10n.addByDetailHint,
                  textAlign: TextAlign.end,
                  style: text.labelMedium!.copyWith(color: c.muted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: l10n.amountAdded,
          container: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: c.shadowPill, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                for (final s in presets)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: s == habit.step,
                      inMutuallyExclusiveGroup: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelected(s),
                        // 40 px pill in a 48 px target (the band's padding).
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: AnimatedContainer(
                            duration: context.motion(Motion.fast),
                            constraints: const BoxConstraints(minHeight: 40),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: s == habit.step ? tones.base : null,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              label(s),
                              style: text.bodyLarge!.copyWith(
                                color: s == habit.step ? tones.ink : c.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// F-Fiche's glued trio: streak, record, share of the month.
class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.stats});

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final divider = BorderSide(color: c.sheetDivider, width: 1.5);
    Widget stat(String value, String label, {bool middle = false}) => Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: middle ? Border(left: divider, right: divider) : null,
        ),
        child: Column(
          children: [
            Text(value, style: text.headlineSmall),
            Text(
              label,
              textAlign: TextAlign.center,
              style: text.labelMedium!.copyWith(color: c.muted),
            ),
          ],
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: c.shadowPill, offset: const Offset(0, 3))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            stat(fmt.number(stats.streak.current), l10n.statStreak),
            stat(fmt.number(stats.streak.best), l10n.statBest, middle: true),
            stat(fmt.percent(stats.monthRate), l10n.statMonth),
          ],
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.habit,
    required this.history,
    required this.today,
  });

  final Habit habit;
  final History history;
  final Day today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final text = Theme.of(context).textTheme;
    final month = fmt.month(today);
    final stats = habitStats(habit, history, today);
    final small = text.labelSmall!.copyWith(height: 1);

    MosaicCell cellFor(Day d) {
      final cell = dayCell(habit, history, d, today);
      Text label(String s, Color color) =>
          Text(s, style: small.copyWith(color: color));
      final number = fmt.dayOfMonth(d);
      return switch (cell.state) {
        DayCellState.future || DayCellState.untracked || DayCellState.rest =>
          MosaicCell(color: c.cellOff, child: label(number, c.cellOffInk)),
        DayCellState.joker => MosaicCell(
          color: c.jokerCell,
          child: Icon(PhosphorIconsFill.shield, size: 14, color: c.joker),
        ),
        DayCellState.done => MosaicCell(
          color: tones.deep,
          ring: d == today,
          child: label(_amount(fmt, habit, cell.value), c.onAccent),
        ),
        _ => MosaicCell(
          color: switch (cell.progress) {
            0 => c.chipOff,
            < 0.5 => tones.light,
            < 0.75 => tones.base,
            _ => tones.mid,
          },
          ring: d == today,
          child: cell.value > 0
              ? label(_amount(fmt, habit, cell.value), c.ink)
              : label(number, c.faint),
        ),
      };
    }

    return SorbetCard(
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailCardTitle(
            fmt.capitalized(month),
            hint: l10n.goalMetDays(stats.monthDone),
          ),
          const SizedBox(height: 10),
          MonthMosaic(
            days: monthGrid(today, context.firstWeekday),
            weekdayLetters: fmt.weekdayLetters(context.firstWeekday),
            semanticLabel: l10n.calendarOf(month),
            cellFor: cellFor,
          ),
        ],
      ),
    );
  }
}

/// 60 px white round "−" with a 48 px+ target.
class _MinusButton extends StatelessWidget {
  const _MinusButton({required this.label, required this.onTap});

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
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.surface,
          boxShadow: [
            BoxShadow(color: c.shadowPill, offset: const Offset(0, 3)),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: 60,
              child: Icon(
                PhosphorIconsBold.minus,
                size: 20,
                color: onTap == null ? c.faint : c.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
