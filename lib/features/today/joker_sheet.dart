import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/rules.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/fade_through_switcher.dart';
import '../../core/widgets/marked_text.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/sorbet_sheet.dart';
import '../habit_detail/detail_model.dart';

/// Setting key: the logical day E2 was last offered, so it opens once a day.
const _promptedKey = 'jokerPromptDay';

/// Offers E2 when Today opens and yesterday broke the streak (once a day).
class JokerPromptGate extends ConsumerStatefulWidget {
  const JokerPromptGate({super.key});

  @override
  ConsumerState<JokerPromptGate> createState() => _JokerPromptGateState();
}

class _JokerPromptGateState extends ConsumerState<JokerPromptGate> {
  Day? _checked;

  Future<void> _check() async {
    // The stored rollover hour decides which day "today" is: wait for it.
    await ref.read(settingProvider(rolloverHourKey).future);
    if (!mounted) return;
    final today = ref.read(todayProvider);
    if (_checked == today) return;
    _checked = today;
    final repo = ref.read(habitRepositoryProvider);
    if (await repo.getSetting(_promptedKey) == '${today.index}') return;
    final history = await ref.read(historyProvider.future);
    final prompt = jokerPrompt(history, today);
    if (prompt == null || !mounted) return;
    await repo.setSetting(_promptedKey, '${today.index}');
    if (!mounted) return;
    await showSorbetSheet<void>(
      context,
      (_) => _JokerSheet(prompt: prompt),
      sidePadding: 22,
      bottomPadding: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(todayProvider); // a new day re-checks
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    return const SizedBox.shrink();
  }
}

enum _Step { ask, saved, skipped }

class _JokerSheet extends ConsumerStatefulWidget {
  const _JokerSheet({required this.prompt});

  final JokerPrompt prompt;

  @override
  ConsumerState<_JokerSheet> createState() => _JokerSheetState();
}

class _JokerSheetState extends ConsumerState<_JokerSheet> {
  _Step _step = _Step.ask;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final p = widget.prompt;
    final streak = l10n.daysCount(p.streak);
    final body = text.bodyLarge!.copyWith(
      fontWeight: FontWeight.w400,
      height: 1.35,
      color: c.inkSoft,
    );
    Widget title(String s) => Semantics(
      header: true,
      child: Text(
        s,
        textAlign: TextAlign.center,
        style: text.headlineMedium!.copyWith(fontSize: 25, height: 1.15),
      ),
    );
    Widget disc(Color bg, IconData icon, Color fg, double size) => Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Icon(icon, size: size, color: fg),
    );
    final close = PrimaryButton(
      label: _step == _Step.saved ? l10n.letsGo : l10n.okay,
      height: 58,
      fontSize: 18,
      onPressed: () => Navigator.pop(context),
    );

    return FadeThroughSwitcher(
      child: KeyedSubtree(
        key: ValueKey(_step),
        child: switch (_step) {
          _Step.ask => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              Center(
                child: disc(c.jokerSoft, PhosphorIconsFill.shield, c.joker, 38),
              ),
              const SizedBox(height: 14),
              title(l10n.streakAtRisk),
              const SizedBox(height: 8),
              MarkedText(
                l10n.missedYesterday(
                  context.habitFormat.list([for (final h in p.missed) h.name]),
                  streak,
                ),
                style: body,
                textAlign: TextAlign.center,
                strong: TextStyle(fontWeight: FontWeight.w600, color: c.ink),
              ),
              const SizedBox(height: 16),
              ExcludeSemantics(child: _WeekStrip(day: p.day)),
              const SizedBox(height: 18),
              _JokerButton(
                label: l10n.useJoker(p.jokers),
                onPressed: () async {
                  await ref.read(habitRepositoryProvider).useJoker(p.day);
                  if (mounted) setState(() => _step = _Step.saved);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => _step = _Step.skipped),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: c.bg,
                  foregroundColor: c.inkSoft,
                  shape: const StadiumBorder(),
                  textStyle: text.bodyLarge,
                ),
                child: Text(l10n.letItGo),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.jokerEarnHint,
                textAlign: TextAlign.center,
                style: text.labelMedium!.copyWith(color: c.muted),
              ),
            ],
          ),
          _Step.saved => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 22),
              Center(
                child: disc(c.flameChip, PhosphorIconsFill.fire, c.flame, 38),
              ),
              const SizedBox(height: 14),
              title(l10n.streakSaved),
              const SizedBox(height: 8),
              Text(
                l10n.stillInARow(streak, p.jokers - 1),
                textAlign: TextAlign.center,
                style: body.copyWith(height: null),
              ),
              const SizedBox(height: 22),
              close,
            ],
          ),
          _Step.skipped => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 22),
              Center(child: disc(c.bg, PhosphorIconsFill.fire, c.flameOff, 36)),
              const SizedBox(height: 14),
              title(l10n.freshStart),
              const SizedBox(height: 8),
              Text(
                l10n.recordKept(streak),
                textAlign: TextAlign.center,
                style: body.copyWith(height: null),
              ),
              const SizedBox(height: 22),
              close,
            ],
          ),
        },
      ),
    );
  }
}

/// The last 7 days: perfect (or saved) ones, yesterday at risk, today.
class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.day});

  /// Yesterday, the day at risk.
  final Day day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history =
        ref.watch(historyProvider).value ??
        History(habits: const [], entries: const []);
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final small = Theme.of(context).textTheme.labelSmall!.copyWith(height: 1);
    final perfect = c.habit[HabitColor.pink]!;
    Widget cell(Day d) {
      final yesterday = d == day, today = d == day.addDays(1);
      final good =
          history.jokerDays.contains(d) || (history.isPerfect(d) ?? false);
      final (
        Color bg,
        Color label,
        IconData? icon,
        Color? ring,
        double ringWidth,
      ) = switch (true) {
        _ when yesterday => (
          c.chipOff,
          c.joker,
          PhosphorIconsRegular.warningCircle,
          c.joker,
          2.5,
        ),
        _ when today => (c.surface, c.faint, null, c.todayOutline, 1.5),
        _ when good => (perfect, c.ink, PhosphorIconsBold.check, null, 0.0),
        _ => (c.chipOff, c.faint, null, null, 0.0),
      };
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(3),
        ),
        foregroundDecoration: ring == null
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: ring, width: ringWidth),
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            Text(
              yesterday
                  ? l10n.yesterdayShort
                  : (today ? l10n.todayShort : fmt.weekdayShort(d)),
              style: small.copyWith(color: label),
            ),
            SizedBox.square(
              dimension: 15,
              child: icon == null ? null : Icon(icon, size: 15, color: label),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Row(
        spacing: 1,
        children: [
          for (var i = -6; i <= 0; i++)
            Expanded(child: cell(day.addDays(i + 1))),
        ],
      ),
    );
  }
}

class _JokerButton extends StatelessWidget {
  const _JokerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(color: c.jokerShadow, offset: const Offset(0, 4)),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          backgroundColor: c.joker,
          foregroundColor: c.onAccent,
          iconSize: 20,
          textStyle: Theme.of(context).textTheme.titleMedium!
              .copyWith(fontWeight: FontWeight.w500),
        ),
        icon: const Icon(PhosphorIconsFill.shield),
        label: Text(label),
      ),
    );
  }
}
