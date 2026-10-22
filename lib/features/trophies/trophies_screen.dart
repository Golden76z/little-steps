import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/domain/day.dart';
import '../../core/domain/rewards.dart';
import '../../core/domain/rules.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/streak_chip.dart';
import '../../core/widgets/xp_avatar.dart';

class TrophiesScreen extends ConsumerStatefulWidget {
  const TrophiesScreen({super.key});

  @override
  ConsumerState<TrophiesScreen> createState() => _TrophiesScreenState();
}

class _TrophiesScreenState extends ConsumerState<TrophiesScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider).value;
    if (history == null) return const SizedBox.shrink();
    final today = ref.watch(todayProvider);
    final challenges = weeklyChallenges(history, today);
    return Column(
      children: [
        _Header(
          level: levelFor(levelXp(history, today)),
          streak: globalStreak(history, today).current,
          tab: _tab,
          onTab: (i) => setState(() => _tab = i),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.paddingOf(context).bottom + 16,
            ),
            children: _tab == 0
                ? [
                    _Stats(
                      jokers: jokerBalance(history, today),
                      best: globalStreak(history, today).best,
                    ),
                    const SizedBox(height: 16),
                    _BadgeGrid(earned: earnedBadges(history, today)),
                    const SizedBox(height: 12),
                    _WeeklyChallenge(challenge: challenges.first),
                  ]
                : [
                    for (final ch in challenges) ...[
                      _ChallengeCard(challenge: ch, today: today),
                      const SizedBox(height: 10),
                    ],
                  ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.level,
    required this.streak,
    required this.tab,
    required this.onTab,
  });

  final Level level;
  final int streak;
  final int tab;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final tabs = [l10n.badgesTab, l10n.challengesTab];
    return AppHeaderCard(
      top: Row(
        children: [
          XpAvatar(
            fraction: level.fraction,
            color: c.habit[HabitColor.lemon],
            semanticLabel: l10n.levelProgress(
              level.level,
              fmt.percent(level.fraction),
              level.level + 1,
            ),
            child: Text(
              fmt.number(level.level),
              // The disc is fixed: cap the scale so the number stays inside.
              textScaler: MediaQuery.textScalerOf(context)
                  .clamp(maxScaleFactor: 1.3),
              style: text.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.xpOf(fmt.number(level.xp), fmt.number(level.toNext)),
                  style: text.bodySmall!.copyWith(color: c.muted),
                ),
                Semantics(
                  header: true,
                  child: Text(l10n.tabTrophies, style: text.headlineLarge),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          StreakChip(days: streak, semanticLabel: l10n.streakDays(streak)),
        ],
      ),
      band: Semantics(
        container: true,
        label: l10n.categoryLabel,
        child: SegmentedStrip(
          count: tabs.length,
          cellHeight: 58,
          selected: tab,
          onSelected: onTab,
          itemBuilder: (context, i, on) => Text(
            tabs[i],
            textAlign: TextAlign.center,
            style: text.bodyLarge!.copyWith(color: on ? c.ink : c.muted),
          ),
        ),
      ),
    );
  }
}

/// White card with the candy drop shadow.
class _Card extends StatelessWidget {
  const _Card({
    required this.radius,
    required this.padding,
    required this.child,
    this.color,
    this.shadow,
  });

  final double radius;
  final EdgeInsets padding;
  final Widget child;
  final Color? color;
  final Color? shadow;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: shadow ?? c.shadowPill, offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({
    required this.size,
    required this.color,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
  });

  final double size;
  final Color color;
  final IconData icon;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: Icon(icon, size: iconSize, color: iconColor),
  );
}

class _Stats extends StatelessWidget {
  const _Stats({required this.jokers, required this.best});

  final int jokers;
  final int best;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    Widget stat(Color disc, IconData icon, String value, String label) =>
        Expanded(
          child: MergeSemantics(
            child: _Card(
              radius: 22,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: Row(
                spacing: 10,
                children: [
                  _Disc(
                    size: 40,
                    color: disc,
                    icon: icon,
                    iconSize: 22,
                    iconColor: c.ink,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: text.titleLarge!.copyWith(height: 1),
                        ),
                        Text(
                          label,
                          style: text.labelMedium!.copyWith(color: c.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          stat(
            c.habit[HabitColor.lemon]!,
            PhosphorIconsRegular.shield,
            fmt.number(jokers),
            l10n.jokersLabel,
          ),
          stat(
            c.flameChip,
            PhosphorIconsRegular.fire,
            l10n.daysShort(fmt.number(best)),
            l10n.bestStreakLabel,
          ),
        ],
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.earned});

  final Set<Badge> earned;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    const columns = 3;
    final badges = Badge.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Semantics(
                  container: true,
                  header: true,
                  child: Text(l10n.badgesTab, style: text.titleMedium),
                ),
              ),
              Text(
                l10n.countOf(
                  fmt.number(earned.length),
                  fmt.number(badges.length),
                ),
                style: text.bodySmall!.copyWith(color: c.muted),
              ),
            ],
          ),
        ),
        for (var row = 0; row < badges.length; row += columns) ...[
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                for (final b in badges.skip(row).take(columns))
                  Expanded(child: _badge(context, b, earned.contains(b))),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _badge(BuildContext context, Badge b, bool on) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final (name, color, icon) = switch (b) {
      Badge.firstStep => (
        l10n.badgeFirstStep,
        c.habit[HabitColor.peach]!,
        PhosphorIconsRegular.medal,
      ),
      Badge.streak7 => (
        l10n.badgeStreak7,
        c.flameChip,
        PhosphorIconsRegular.fire,
      ),
      Badge.earlyBird => (
        l10n.badgeEarlyBird,
        c.habit[HabitColor.lemon]!,
        PhosphorIconsRegular.sun,
      ),
      Badge.bookworm => (
        l10n.badgeBookworm,
        c.habit[HabitColor.mint]!,
        PhosphorIconsRegular.book,
      ),
      Badge.streak30 => (
        l10n.badgeStreak30,
        c.flameChip,
        PhosphorIconsRegular.fire,
      ),
      Badge.zen => (
        l10n.badgeZen,
        c.habit[HabitColor.lilac]!,
        PhosphorIconsRegular.flowerLotus,
      ),
      Badge.perfectDay => (
        l10n.badgePerfectDay,
        c.habit[HabitColor.pink]!,
        PhosphorIconsRegular.star,
      ),
      Badge.perfectWeek => (
        l10n.badgePerfectWeek,
        c.habit[HabitColor.lagoon]!,
        PhosphorIconsRegular.calendarCheck,
      ),
      Badge.streak100 => (
        l10n.badgeStreak100,
        c.habit[HabitColor.apricot]!,
        PhosphorIconsRegular.crown,
      ),
      Badge.nightOwl => (
        l10n.badgeNightOwl,
        c.habit[HabitColor.lavender]!,
        PhosphorIconsRegular.moon,
      ),
      Badge.hydrated => (
        l10n.badgeHydrated,
        c.habit[HabitColor.sky]!,
        PhosphorIconsRegular.drop,
      ),
      Badge.rescue => (
        l10n.badgeRescue,
        c.jokerSoft,
        PhosphorIconsRegular.shield,
      ),
    };
    return Semantics(
      label: on ? l10n.badgeEarned(name) : l10n.badgeLocked(name),
      container: true,
      excludeSemantics: true,
      child: _Card(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
        child: Column(
          spacing: 6,
          children: [
            _Disc(
              size: 52,
              color: on ? color : c.chipOff,
              icon: on ? icon : PhosphorIconsFill.lock,
              iconSize: 26,
              iconColor: !on
                  ? c.cellOffInk
                  : b == Badge.rescue
                  ? c.joker
                  : c.ink,
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                fontWeight: FontWeight.w500,
                color: on ? c.ink : c.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _challengeName(BuildContext context, Challenge ch) {
  final l10n = context.l10n;
  final fmt = context.habitFormat;
  final h = ch.habit;
  return switch (ch.kind) {
    ChallengeKind.sevenDays => l10n.challengeSevenDays(h!.name),
    ChallengeKind.goalFiveDays => l10n.challengeGoalFive(fmt.goal(h!)),
    ChallengeKind.timesThisWeek => l10n.challengeTimes(
      h!.name,
      fmt.number(ch.target),
    ),
    ChallengeKind.perfectWeek => l10n.challengePerfectWeek,
  };
}

/// "2 jours sur 7"; with [daysLeft], the seven-day challenge also says how
/// many days the week has left.
String _challengeProgress(BuildContext context, Challenge ch, {int? daysLeft}) {
  final l10n = context.l10n;
  final fmt = context.habitFormat;
  final done = fmt.number(ch.progress), target = fmt.number(ch.target);
  return switch (ch.kind) {
    ChallengeKind.sevenDays when daysLeft != null => l10n.challengeDaysLeft(
      done,
      target,
      daysLeft,
    ),
    ChallengeKind.sevenDays ||
    ChallengeKind.goalFiveDays => l10n.challengeDays(done, target),
    ChallengeKind.timesThisWeek => l10n.challengeSessions(
      done,
      target,
      ch.progress,
    ),
    ChallengeKind.perfectWeek => l10n.challengePerfectDays(
      done,
      target,
      ch.progress,
    ),
  };
}

class _WeeklyChallenge extends StatelessWidget {
  const _WeeklyChallenge({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final mint = c.tones[HabitColor.mint]!;
    final small = text.labelMedium!.copyWith(color: mint.ink);
    return _Card(
      radius: 24,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      color: mint.base,
      shadow: mint.mid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.target, size: 16, color: mint.ink),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.weeklyChallenge,
                  style: small.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                l10n.xpReward(fmt.number(challenge.xp)),
                style: small.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(_challengeName(context, challenge), style: text.titleMedium),
          const SizedBox(height: 10),
          Semantics(
            label: _challengeProgress(context, challenge),
            container: true,
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: c.trackOnColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                spacing: 3,
                children: [
                  for (var i = 0; i < challenge.target; i++)
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: i < challenge.progress ? c.ink : null,
                          borderRadius: BorderRadius.circular(5),
                        ),
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

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.today});

  final Challenge challenge;
  final Day today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final h = challenge.habit;
    final color = h?.color ?? HabitColor.lemon;
    final tones = c.tones[color]!;
    final daysLeft = today
        .weekStart(DateTime.monday)
        .addDays(6)
        .difference(today);
    return MergeSemantics(
      child: _Card(
        radius: 24,
        padding: const EdgeInsets.all(14),
        child: Row(
          spacing: 12,
          children: [
            _Disc(
              size: 46,
              color: c.habit[color]!,
              icon: h == null ? PhosphorIconsRegular.medal : habitIcon(h.icon),
              iconSize: 22,
              iconColor: c.ink,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          _challengeName(context, challenge),
                          style: text.bodyLarge,
                        ),
                      ),
                      Text(
                        l10n.xpReward(fmt.number(challenge.xp)),
                        style: text.labelMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 10,
                      color: c.track,
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: (challenge.progress / challenge.target)
                            .clamp(0, 1),
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: h == null ? tones.deep : tones.strong,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    challenge.completed
                        ? l10n.challengeDone
                        : _challengeProgress(
                            context,
                            challenge,
                            daysLeft: daysLeft,
                          ),
                    style: text.labelMedium!.copyWith(color: c.muted),
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
