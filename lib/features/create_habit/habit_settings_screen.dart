import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/sorbet_card.dart';
import 'create_flow.dart';
import 'draft_provider.dart';
import 'habit_draft.dart';
import 'labels.dart';
import '../../core/theme/motion.dart';

/// P2: name, colour, icon, daily goal, unit and quick step.
class HabitSettingsScreen extends ConsumerStatefulWidget {
  const HabitSettingsScreen({super.key});

  @override
  ConsumerState<HabitSettingsScreen> createState() =>
      _HabitSettingsScreenState();
}

class _HabitSettingsScreenState extends ConsumerState<HabitSettingsScreen> {
  late final _name = TextEditingController(text: ref.read(draftProvider).name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _update(HabitDraft Function(HabitDraft) change) =>
      ref.read(draftProvider.notifier).update(change);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final draft = ref.watch(draftProvider);
    final hasGoal = switch (draft.type) {
      HabitType.quantity || HabitType.duration || HabitType.journal => true,
      HabitType.yesNo || HabitType.frequency => false,
    };
    return CreateFlowScaffold(
      step: 2,
      title: l10n.settingsTitle,
      cta: PrimaryButton(
        label: l10n.continueLabel,
        onPressed: draft.isValid
            ? () => context.push(Routes.createSchedule)
            : null,
      ),
      children: [
        SorbetCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.previewLabel,
                style: text.labelMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
              const SizedBox(height: 8),
              _Preview(
                draft: draft,
                onIconTap: () =>
                    _update((d) => d.copyWith(icon: _nextIcon(d.icon))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                onChanged: (v) => _update((d) => d.copyWith(name: v)),
                style: text.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.nameHint,
                  hintStyle: text.bodyLarge!.copyWith(color: c.muted),
                  filled: true,
                  fillColor: c.strip,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ColorGrid(
                selected: draft.color,
                onSelected: (color) => _update((d) => d.copyWith(color: color)),
              ),
            ],
          ),
        ),
        if (hasGoal) ...[
          const SizedBox(height: 12),
          _GoalCard(draft: draft, onChange: _update),
        ],
        if (draft.type == HabitType.quantity) ...[
          const SizedBox(height: 12),
          _StepCard(draft: draft, onChange: _update),
        ],
      ],
    );
  }

  static String _nextIcon(String current) {
    final keys = habitIcons.keys.toList();
    return keys[(keys.indexOf(current) + 1) % keys.length];
  }
}

/// The pill as it will look on Today, filled at 45 %.
class _Preview extends StatelessWidget {
  const _Preview({required this.draft, required this.onIconTap});

  final HabitDraft draft;
  final VoidCallback onIconTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final habit = draft.build(Day.fromIndex(0));
    final exact =
        draft.type == HabitType.duration ||
        {
          QuantityUnit.liters,
          QuantityUnit.milliliters,
          QuantityUnit.kilometers,
        }.contains(draft.unit);
    final factor = draft.unit?.baseFactor ?? 1;
    final sample = switch (draft.type) {
      HabitType.yesNo || HabitType.frequency => 0.0,
      _ when exact => habit.goal * 0.45,
      _ => (habit.goal * 0.45 / factor).roundToDouble() * factor,
    };
    final radius = BorderRadius.circular(29);
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      decoration: BoxDecoration(
        color: c.sheetGroup,
        borderRadius: radius,
        border: Border.all(color: c.sheetDivider, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 0.45,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.habit[draft.color],
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                spacing: 6,
                children: [
                  Semantics(
                    button: true,
                    label: l10n.changeIcon,
                    excludeSemantics: true,
                    child: InkResponse(
                      onTap: onIconTap,
                      radius: 24,
                      child: SizedBox.square(
                        dimension: 48,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.iconHalo,
                            ),
                            child: Icon(
                              habitIcon(draft.icon),
                              size: 20,
                              color: c.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              draft.name.trim().isEmpty
                                  ? l10n.nameHint
                                  : draft.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleSmall!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              context.habitFormat.value(
                                habit,
                                sample,
                                weekCount: habit.isWeekly ? 1 : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelMedium!.copyWith(
                                color: c.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsetsDirectional.only(end: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.track,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 6×2 glued colour swatches. One adjustable control for assistive tech:
/// the 28 px rows are too short to be separate targets.
class _ColorGrid extends StatelessWidget {
  const _ColorGrid({required this.selected, required this.onSelected});

  final HabitColor selected;
  final ValueChanged<HabitColor> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    const all = HabitColor.values;
    final i = selected.index;
    return Semantics(
      label: l10n.colorLabel,
      value: colorName(l10n, selected),
      increasedValue: colorName(l10n, all[(i + 1) % all.length]),
      decreasedValue: colorName(l10n, all[(i - 1) % all.length]),
      onIncrease: () => onSelected(all[(i + 1) % all.length]),
      onDecrease: () => onSelected(all[(i - 1) % all.length]),
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            spacing: 1,
            children: [
              for (var row = 0; row < 2; row++)
                Row(
                  spacing: 1,
                  children: [
                    for (final color in all.skip(row * 6).take(6))
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onSelected(color),
                          child: AnimatedContainer(
                            duration: context.motion(Motion.fast),
                            height: 28,
                            decoration: BoxDecoration(
                              color: c.habit[color],
                              borderRadius: BorderRadius.circular(3),
                              border: color == selected
                                  ? Border.all(color: c.ink, width: 3)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.draft, required this.onChange});

  final HabitDraft draft;
  final void Function(HabitDraft Function(HabitDraft)) onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final fmt = context.habitFormat;
    final unit = draft.unit;
    final shown = switch (draft.type) {
      HabitType.duration => draft.goal / 60,
      HabitType.quantity => draft.goal / unit!.baseFactor,
      _ => draft.goal,
    };
    final word = switch (draft.type) {
      HabitType.duration => 'min',
      HabitType.journal => l10n.wordLines(shown),
      _ => switch (unit!) {
        QuantityUnit.glasses => l10n.wordGlasses(shown),
        QuantityUnit.liters => 'L',
        QuantityUnit.milliliters => 'ml',
        QuantityUnit.pages => l10n.wordPages(shown),
        QuantityUnit.steps => l10n.wordSteps,
        QuantityUnit.kilometers => 'km',
        QuantityUnit.times => l10n.wordTimes(shown),
      },
    };
    final glasses = draft.goal / 250;
    final sub = switch (unit) {
      _ when draft.type != HabitType.quantity => null,
      QuantityUnit.glasses => l10n.goalSubGlasses(
        fmt.number(draft.goal / 1000),
      ),
      QuantityUnit.liters || QuantityUnit.milliliters => l10n.goalSubVolume(
        fmt.number(glasses),
        glasses,
      ),
      _ => null,
    };
    return SorbetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(l10n.goalPerDay),
          const SizedBox(height: 8),
          Row(
            children: [
              RoundIconButton(
                icon: PhosphorIconsBold.minus,
                size: 50,
                iconSize: 20,
                label: l10n.decreaseGoal,
                onTap: () => onChange((d) => d.decGoal()),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      spacing: 5,
                      children: [
                        Text(fmt.number(shown), style: text.displaySmall),
                        Flexible(
                          child: Text(
                            word,
                            style: text.titleMedium!.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.muted,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        textAlign: TextAlign.center,
                        style: text.bodySmall!.copyWith(color: c.muted),
                      ),
                    ],
                  ],
                ),
              ),
              RoundIconButton(
                icon: PhosphorIconsBold.plus,
                size: 50,
                iconSize: 20,
                label: l10n.increaseGoal,
                onTap: () => onChange((d) => d.incGoal()),
              ),
            ],
          ),
          if (unit != null) ...[
            const SizedBox(height: 10),
            Semantics(
              label: l10n.unitLabel,
              container: true,
              child: SegmentedStrip(
                count: QuantityUnit.values.length,
                columns: 4,
                cellHeight: 38,
                selected: unit.index,
                onSelected: (i) =>
                    onChange((d) => d.withUnit(QuantityUnit.values[i])),
                itemBuilder: (context, i, on) => Text(
                  unitLabel(l10n, QuantityUnit.values[i]),
                  style: text.bodyMedium!.copyWith(color: on ? c.ink : c.muted),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.draft, required this.onChange});

  final HabitDraft draft;
  final void Function(HabitDraft Function(HabitDraft)) onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final fmt = context.habitFormat;
    final unit = draft.unit!;
    final presets = unit.stepPresets;
    final custom = !presets.contains(draft.step);
    String label(double step) =>
        fmt.step(draft.copyWith(step: step).build(Day.fromIndex(0)))!;
    return SorbetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(l10n.addBy, hint: l10n.addByHint),
          const SizedBox(height: 8),
          SegmentedStrip(
            count: 4,
            cellHeight: 38,
            selected: custom ? 3 : presets.indexOf(draft.step),
            onSelected: (i) async {
              if (i < 3) return onChange((d) => d.copyWith(step: presets[i]));
              final step = await _askStep(context, unit);
              if (step != null) onChange((d) => d.copyWith(step: step));
            },
            itemBuilder: (context, i, on) => Text(
              i < 3
                  ? label(presets[i])
                  : (custom ? label(draft.step) : l10n.stepOther),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium!.copyWith(color: on ? c.ink : c.muted),
            ),
          ),
        ],
      ),
    );
  }

  /// "Autre": a free step, typed in the unit its label uses (cl for litres).
  Future<double?> _askStep(BuildContext context, QuantityUnit unit) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final (factor, suffix) = switch (unit) {
      QuantityUnit.liters => (10.0, 'cl'),
      QuantityUnit.milliliters => (1.0, 'ml'),
      QuantityUnit.glasses => (250.0, l10n.wordGlasses(2)),
      QuantityUnit.pages => (1.0, l10n.wordPages(2)),
      QuantityUnit.steps => (1.0, l10n.wordSteps),
      QuantityUnit.kilometers => (1000.0, 'km'),
      QuantityUnit.times => (1.0, l10n.wordTimes(2)),
    };
    final controller = TextEditingController();
    double? parse() {
      try {
        final v = NumberFormat.decimalPattern(locale)
            .parse(controller.text.trim());
        return v > 0 ? v * factor : null;
      } on FormatException {
        return null;
      }
    }

    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.stepOtherTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(suffixText: suffix),
          onSubmitted: (_) => Navigator.pop(context, parse()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, parse()),
            child: Text(l10n.ok),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}
