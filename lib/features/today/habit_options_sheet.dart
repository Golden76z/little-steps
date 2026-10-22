import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/rules.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/marked_text.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/sorbet_sheet.dart';
import '../create_habit/draft_provider.dart';
import '../create_habit/habit_draft.dart';

/// E3, opened by a long press on a habit.
Future<void> showHabitOptions(BuildContext context, Habit habit) =>
    showSorbetSheet<void>(context, (_) => _HabitOptions(habit: habit));

class _HabitOptions extends ConsumerStatefulWidget {
  const _HabitOptions({required this.habit});

  final Habit habit;

  @override
  ConsumerState<_HabitOptions> createState() => _HabitOptionsState();
}

class _HabitOptionsState extends ConsumerState<_HabitOptions> {
  bool _pauseOpen = false;
  int _duration = 0;
  Day? _chosenResume;
  bool _paused = false;

  Habit get _habit => widget.habit;

  /// First day back, for the selected duration.
  Day? _resumeOn(Day today) => switch (_duration) {
    0 => today.addDays(7),
    1 => today.addDays(14),
    2 => today.addMonths(1),
    _ => _chosenResume,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final fmt = context.habitFormat;
    final today = ref.watch(todayProvider);
    final history = ref.watch(historyProvider).value;
    final streak = history == null
        ? 0
        : habitStreak(
            _habit,
            history,
            today,
            firstWeekday: context.firstWeekday,
          ).current;
    final resume = _resumeOn(today);
    final rowDivider = BorderSide(color: c.sheetDivider, width: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(
          icon: habitIcon(_habit.icon),
          color: c.habit[_habit.color]!,
          title: _habit.name,
          closeLabel: l10n.close,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: c.sheetGroup,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OptionRow(
                icon: PhosphorIconsRegular.pencilSimple,
                label: l10n.editHabit,
                border: rowDivider,
                onTap: () {
                  ref
                      .read(draftProvider.notifier)
                      .set(HabitDraft.fromHabit(_habit));
                  Navigator.pop(context);
                  context.push(Routes.createSettings);
                },
              ),
              _OptionRow(
                icon: PhosphorIconsRegular.pauseCircle,
                label: l10n.pauseHabit,
                trailing: Text(
                  l10n.pauseHint,
                  style: text.labelMedium!.copyWith(color: c.muted),
                ),
                expanded: _pauseOpen,
                onTap: () => setState(() => _pauseOpen = !_pauseOpen),
              ),
              if (_pauseOpen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: l10n.pauseLength,
                        container: true,
                        child: SegmentedStrip.outlined(
                          count: 4,
                          selected: _duration,
                          onSelected: (i) => _pickDuration(i, today),
                          itemBuilder: (context, i, on) => Text(
                            [
                              l10n.pause1Week,
                              l10n.pause2Weeks,
                              l10n.pause1Month,
                              l10n.pauseDates,
                            ][i],
                            style: text.labelLarge!.copyWith(
                              color: on ? c.ink : c.muted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MarkedText(
                        l10n.pauseFrozen(
                          _habit.isWeekly
                              ? l10n.weeksCount(streak)
                              : l10n.daysCount(streak),
                          resume == null
                              ? l10n.pauseChosenDay
                              : fmt.longDate(resume),
                        ),
                        style: text.bodySmall!.copyWith(
                          height: 1.35,
                          color: c.inkSoft,
                        ),
                        strong: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: c.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: resume == null || _paused
                            ? null
                            : () => _pause(today, resume),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: c.accent,
                          foregroundColor: c.onAccent,
                          disabledBackgroundColor: _paused
                              ? c.surface
                              : c.chipOff,
                          disabledForegroundColor: _paused ? c.ink : c.faint,
                          textStyle: text.bodyLarge,
                        ),
                        child: Text(
                          _paused ? l10n.pauseActive : l10n.pauseConfirm,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(height: 1.5, color: c.sheetDivider),
              _OptionRow(
                icon: PhosphorIconsRegular.archive,
                label: l10n.archive,
                subtitle: l10n.archiveHint,
                height: 60,
                border: rowDivider,
                onTap: () => _archive(today),
              ),
              _OptionRow(
                icon: PhosphorIconsRegular.trash,
                label: l10n.delete,
                color: c.danger,
                onTap: _delete,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDuration(int i, Day today) async {
    setState(() => _duration = i);
    if (i != 3) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: today.addDays(1).toLocalDate(),
      firstDate: today.addDays(1).toLocalDate(),
      lastDate: today.addDays(365).toLocalDate(),
    );
    if (picked != null && mounted) {
      setState(
        () => _chosenResume = Day(picked.year, picked.month, picked.day),
      );
    }
  }

  Future<void> _pause(Day today, Day resume) async {
    await ref
        .read(habitRepositoryProvider)
        .pauseHabit(_habit.id, Pause(today, resume.addDays(-1)));
    if (mounted) setState(() => _paused = true);
  }

  Future<void> _archive(Day today) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(habitRepositoryProvider);
    Navigator.pop(context);
    await repo.archiveHabit(_habit.id, today);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist: false,
          content: Text(l10n.toastArchived),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => repo.unarchiveHabit(_habit.id),
          ),
        ),
      );
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final c = context.sorbet;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTitle(_habit.name)),
        content: Text(l10n.deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: c.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final repo = ref.read(habitRepositoryProvider);
    Navigator.pop(context);
    await repo.deleteHabit(_habit.id);
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.color,
    this.border,
    this.height = 56,
    this.expanded,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;
  final Color? color;
  final BorderSide? border;
  final double height;
  final bool? expanded;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final fg = color ?? c.ink;
    return Semantics(
      expanded: expanded,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: height),
          decoration: BoxDecoration(
            border: border == null ? null : Border(bottom: border!),
          ),
          child: Row(
            spacing: 12,
            children: [
              Icon(icon, size: 20, color: fg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: text.bodyLarge!.copyWith(color: fg)),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: text.labelMedium!.copyWith(color: c.muted),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
