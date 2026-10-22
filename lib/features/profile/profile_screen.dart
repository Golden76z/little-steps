import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/habit.dart';
import '../../core/domain/rewards.dart';
import '../../core/domain/rules.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/sorbet_card.dart';
import '../../core/widgets/sorbet_switch.dart';
import '../../core/widgets/xp_avatar.dart';

const _firstNameKey = 'firstName';

// ponytail: no opacity token in SorbetColors; add one if dark mode needs another value.
const _disabledOpacity = 0.5;

/// Reminder times (minutes after midnight) as "07:30 · 21:00", sorted and
/// deduplicated; past [max] the rest becomes "…".
String formatReminders(
  BuildContext context,
  Iterable<int> minutes, {
  int? max,
}) {
  final loc = MaterialLocalizations.of(context);
  final h24 = MediaQuery.alwaysUse24HourFormatOf(context);
  final sorted = minutes.toSet().toList()..sort();
  final shown = [
    for (final m in sorted.take(max ?? sorted.length))
      loc.formatTimeOfDay(
        TimeOfDay(hour: m ~/ 60, minute: m % 60),
        alwaysUse24HourFormat: h24,
      ),
    if (max != null && sorted.length > max) '…',
  ];
  return shown.join(' · ');
}

/// Couples habit × day, up to [today], where the goal was met.
int _pillsFilled(History history, Day today) {
  var n = 0;
  for (final h in history.habits) {
    for (var d = h.createdOn; d <= today; d = d.addDays(1)) {
      if (h.statusOn(d) != DayStatus.untracked && history.isDone(h, d)) n++;
    }
  }
  return n;
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider).value;
    final history = ref.watch(historyProvider).value;
    if (habits == null || history == null) return const SizedBox.shrink();
    final today = ref.watch(todayProvider);
    final rollover = ref.watch(rolloverHourProvider);
    final l10n = context.l10n;
    final c = context.sorbet;
    final reminders = habits.expand((h) => h.reminders);
    // The header scrolls too, so large text keeps room for the rows.
    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      children: [
        _ProfileHeader(history: history, today: today),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              const _PremiumCard(),
              const SizedBox(height: 12),
              SorbetCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Column(
                  children: [
                    ProfileRow(
                      leading: ProfileIconBox(
                        color: c.flameChip,
                        icon: PhosphorIconsRegular.bell,
                      ),
                      label: l10n.remindersTitle,
                      value: reminders.isEmpty
                          ? l10n.noReminders
                          : formatReminders(context, reminders, max: 3),
                      onTap: () => context.push(Routes.reminders),
                    ),
                    ProfileRow(
                      leading: ProfileIconBox(
                        color: c.tones[HabitColor.pink]!.light,
                        icon: PhosphorIconsRegular.palette,
                      ),
                      label: l10n.rowTheme,
                      value: l10n.themeSorbet,
                      onTap: () => context.push(Routes.premium),
                    ),
                    ProfileRow(
                      leading: ProfileIconBox(
                        color: c.habit[HabitColor.lilac]!,
                        icon: PhosphorIconsRegular.moon,
                      ),
                      label: l10n.rowDarkMode,
                      trailing: Semantics(
                        container: true,
                        label: l10n.rowDarkMode,
                        value: l10n.soon,
                        toggled: false,
                        enabled: false,
                        excludeSemantics: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Text(
                              l10n.soon,
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: c.muted),
                            ),
                            IgnorePointer(
                              child: Opacity(
                                opacity: _disabledOpacity,
                                child: SorbetSwitch(
                                  value: false,
                                  onChanged: (_) {},
                                  label: l10n.rowDarkMode,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ProfileRow(
                      leading: ProfileIconBox(
                        color: c.habit[HabitColor.lemon]!,
                        icon: PhosphorIconsRegular.shieldCheck,
                      ),
                      label: l10n.rowJokers,
                      value: l10n.jokersLeft(jokerBalance(history, today)),
                      onTap: () => context.go(Routes.trophies),
                    ),
                    ProfileRow(
                      leading: ProfileIconBox(
                        color: c.habit[HabitColor.sky]!,
                        icon: PhosphorIconsRegular.export,
                      ),
                      label: l10n.rowExport,
                      value: l10n.csv,
                      onTap: () => context.push(Routes.premium),
                    ),
                    ProfileRow(
                      leading: ProfileIconBox(
                        color: c.habit[HabitColor.mint]!,
                        icon: PhosphorIconsRegular.sunHorizon,
                      ),
                      label: l10n.rowDayStart,
                      value: formatReminders(context, [rollover * 60]),
                      onTap: () => _pickDayStart(context, ref, rollover),
                      last: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDayStart(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final repo = ref.read(habitRepositoryProvider);
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.rowDayStart, style: text.titleMedium),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l10n.dayStartHint,
              style: text.bodySmall!.copyWith(color: c.muted),
            ),
          ),
          for (var h = 0; h <= 6; h++)
            Semantics(
              selected: h == current,
              child: SimpleDialogOption(
                onPressed: () => Navigator.pop(context, h),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatReminders(context, [h * 60]),
                          style: text.bodyLarge,
                        ),
                      ),
                      if (h == current)
                        Icon(
                          PhosphorIconsBold.check,
                          size: 18,
                          color: c.accent,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    if (picked != null) await repo.setSetting(rolloverHourKey, '$picked');
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.history, required this.today});

  final History history;
  final Day today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final name = ref.watch(settingProvider(_firstNameKey)).value ?? '';
    final level = levelFor(levelXp(history, today));
    final streak = globalStreak(history, today);
    return AppHeaderCard(
      top: Row(
        children: [
          XpAvatar(
            size: 56,
            fraction: level.fraction,
            badge: '${level.level}',
            semanticLabel: l10n.levelProgress(
              level.level,
              fmt.percent(level.fraction),
              level.level + 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _editName(context, ref, name),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          name.isEmpty ? l10n.yourName : name,
                          style: name.isEmpty
                              ? text.headlineMedium!.copyWith(color: c.muted)
                              : text.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.memberSince(
                          fmt.monthYear(history.firstDay ?? today),
                        ),
                        style: text.bodySmall!.copyWith(color: c.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 48 px target shifted 4 px outwards: the 40 px disc keeps the 20 px
          // margin, and the 4 px gap makes 12 px visually.
          const SizedBox(width: 4),
          Transform.translate(
            offset: const Offset(4, 0),
            child: RoundIconButton(
              icon: PhosphorIconsRegular.gear,
              iconSize: 20,
              label: l10n.settingsLabel,
              onTap: () => _editName(context, ref, name),
            ),
          ),
        ],
      ),
      band: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: c.strip,
          borderRadius: BorderRadius.circular(22),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Stat(
                value: l10n.daysShort(fmt.number(streak.current)),
                label: l10n.statSeries,
              ),
              Container(width: 1.5, color: c.divider),
              _Stat(
                value: l10n.daysShort(fmt.number(streak.best)),
                label: l10n.statBest,
              ),
              Container(width: 1.5, color: c.divider),
              _Stat(
                value: fmt.number(_pillsFilled(history, today)),
                label: l10n.pillsFilled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final repo = ref.read(habitRepositoryProvider);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: current),
    );
    if (name != null) await repo.setSetting(_firstNameKey, name);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: MergeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: text.titleLarge, textAlign: TextAlign.center),
            Text(
              label,
              style: text.labelMedium!.copyWith(color: context.sorbet.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        l10n.yourName,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: l10n.yourName),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _save, child: Text(l10n.saveHabit)),
      ],
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final pink = c.tones[HabitColor.pink]!;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(26);
    // Large text: the pill drops under the copy, which keeps the full width.
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final icon = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(PhosphorIconsFill.sparkle, size: 26, color: c.accent),
    );
    final info = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(l10n.premiumCardTitle, style: text.titleMedium),
          Text(
            l10n.premiumCardBody,
            style: text.labelMedium!.copyWith(color: pink.ink),
          ),
        ],
      ),
    );
    // The whole card is the button; this pill is its visual cue.
    final pill = Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          l10n.tryPremium,
          style: text.bodyMedium!.copyWith(color: c.onAccent),
        ),
      ),
    );
    return Semantics(
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: pink.light,
          borderRadius: radius,
          boxShadow: [BoxShadow(color: pink.mid, offset: const Offset(0, 4))],
        ),
        child: Material(
          type: MaterialType.transparency,
          clipBehavior: Clip.antiAlias,
          borderRadius: radius,
          child: InkWell(
            onTap: () => context.push(Routes.premium),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.iconHalo,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            Row(spacing: 12, children: [icon, info]),
                            pill,
                          ],
                        )
                      : Row(spacing: 12, children: [icon, info, pill]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 36 px rounded square (or disc) behind a row icon.
class ProfileIconBox extends StatelessWidget {
  const ProfileIconBox({
    super.key,
    required this.color,
    required this.icon,
    this.circle = false,
  });

  final Color color;
  final IconData icon;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(12),
    ),
    child: Icon(icon, size: 19, color: context.sorbet.ink),
  );
}

/// 54 px settings row: icon box, label, then a muted value with a caret
/// (tappable) or a custom [trailing]; 1.5 px divider unless [last].
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.leading,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.last = false,
  });

  final Widget leading;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 54),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          spacing: 12,
          children: [
            leading,
            Expanded(
              child: trailing == null
                  ? Text(label, style: text.bodyLarge)
                  // The trailing widget announces the row itself.
                  : ExcludeSemantics(child: Text(label, style: text.bodyLarge)),
            ),
            ?trailing,
            if (value != null)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Flexible(
                      child: Text(
                        value!,
                        style: text.bodySmall!.copyWith(color: c.muted),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Icon(
                      PhosphorIconsBold.caretRight,
                      size: 14,
                      color: c.cellOffInk,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: c.sheetDivider, width: 1.5)),
      ),
      child: onTap == null
          ? row
          : MergeSemantics(
              child: Semantics(
                button: true,
                child: InkWell(onTap: onTap, child: row),
              ),
            ),
    );
  }
}
