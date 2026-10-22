import 'dart:async';
import 'dart:math' as math;

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
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/sorbet_card.dart';
import '../create_habit/habit_draft.dart';
import 'detail_scaffold.dart';
import 'session_timer.dart';
import '../../core/theme/motion.dart';

/// T2: duration habit, with its session timer and the week in minutes.
class DurationDetail extends ConsumerStatefulWidget {
  const DurationDetail({
    super.key,
    required this.habit,
    this.startTimer = false,
  });

  final Habit habit;

  /// Opened from the Today pill: start the timer right away.
  final bool startTimer;

  @override
  ConsumerState<DurationDetail> createState() => _DurationDetailState();
}

class _DurationDetailState extends ConsumerState<DurationDetail> {
  static const _presets = [5, 10, 15, 20];

  /// Repaints the clock while a run goes; the time itself is read from
  /// the session, so pausing this loses nothing.
  Timer? _ticker;
  bool _autoStarted = false;

  SessionTimers get _timers => ref.read(sessionTimersProvider.notifier);

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncTicker(bool running) {
    if (running == (_ticker != null)) return;
    _ticker?.cancel();
    _ticker = running
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            _timers.tick(widget.habit);
            if (mounted) setState(() {});
          })
        : null;
  }

  Future<void> _setGoal(int seconds) async {
    final h = widget.habit;
    if (h.goal == seconds) return;
    final updated = HabitDraft.fromHabit(h)
        .copyWith(goal: seconds * 1.0)
        .build(h.createdOn);
    await ref.read(habitRepositoryProvider).updateHabit(updated);
    await _timers.goalChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider).value;
    ref.watch(sessionTimersProvider);
    final today = ref.watch(todayProvider);
    final h = widget.habit;
    if (history == null) return const Scaffold();

    final session = _timers.current(h);
    if (widget.startTimer && !_autoStarted) {
      _autoStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _timers.start(h));
    }
    _syncTicker(session.running);

    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final text = Theme.of(context).textTheme;
    final c = context.sorbet;
    final goal = h.goal.toInt();
    final elapsed = math.min(session.elapsed(ref.read(clockProvider)()), goal);
    final preset = _presets.indexWhere((m) => m * 60 == goal);

    return DetailScaffold(
      habit: h,
      subtitle: '${fmt.goal(h)} · ${fmt.schedule(h)}',
      strip: Semantics(
        container: true,
        label: l10n.sessionLength,
        child: SegmentedStrip(
          count: _presets.length,
          cellHeight: 40,
          selected: preset < 0 ? null : preset,
          onSelected: (i) => _setGoal(_presets[i] * 60),
          itemBuilder: (context, i, on) => Text(
            l10n.stepMinutes(fmt.number(_presets[i])),
            style: text.bodyLarge!.copyWith(color: on ? c.ink : c.muted),
          ),
        ),
      ),
      children: [
        _TimerCard(
          habit: h,
          session: session,
          elapsed: elapsed,
          onReset: () => _timers.reset(h),
          onToggle: session.running
              ? () => _timers.pause(h)
              : () => _timers.start(h),
          onFinish: () => _timers.finish(h),
        ),
        const SizedBox(height: 12),
        _AlreadyDoneButton(
          label: l10n.alreadyDone(goal ~/ 60),
          onTap: () => _timers.markDone(h),
        ),
        const SizedBox(height: 12),
        _WeekCard(
          habit: h,
          history: history,
          today: today,
          todaySeconds: elapsed,
        ),
      ],
    );
  }
}

String _mmss(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
    '${(seconds % 60).toString().padLeft(2, '0')}';

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.habit,
    required this.session,
    required this.elapsed,
    required this.onReset,
    required this.onToggle,
    required this.onFinish,
  });

  final Habit habit;
  final Session session;
  final int elapsed;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final goal = habit.goal.toInt();
    final running = session.running;
    final status = session.finished
        ? l10n.sessionDone
        : running
        ? l10n.timerRunning
        : l10n.timerOf(_mmss(goal));
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: c.shadowPill, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Semantics(
            container: true,
            label: l10n.ringLabel(elapsed ~/ 60, goal ~/ 60),
            excludeSemantics: true,
            // The arc glides between the 1 s ticks, as in the mockup (0.9 s linear).
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: goal == 0 ? 0 : elapsed / goal),
              duration: context.motion(const Duration(milliseconds: 900)),
              builder: (context, progress, child) => CustomPaint(
                size: const Size.square(210),
                painter: _RingPainter(
                  progress: progress,
                  face: tones.pale,
                  track: tones.light,
                  arc: tones.strong,
                ),
                child: child,
              ),
              child: SizedBox.square(
                dimension: 210,
                // The 2x text scale must still fit inside the ring.
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_mmss(goal - elapsed), style: text.displayMedium),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: text.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 22,
            children: [
              RoundIconButton(
                icon: PhosphorIconsBold.arrowCounterClockwise,
                iconSize: 22,
                size: 52,
                label: l10n.restartTimer,
                onTap: onReset,
              ),
              _PlayButton(
                running: running,
                onTap: session.finished ? null : onToggle,
              ),
              RoundIconButton(
                icon: PhosphorIconsBold.check,
                iconSize: 22,
                size: 52,
                label: l10n.finishSession,
                onTap: onFinish,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.face,
    required this.track,
    required this.arc,
  });

  final double progress;
  final Color face;
  final Color track;
  final Color arc;

  static const _radius = 92.0, _stroke = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    canvas
      ..drawCircle(center, _radius, Paint()..color = face)
      ..drawCircle(center, _radius, line..color = track);
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: _radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      line
        ..color = arc
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.face != face ||
      old.track != track ||
      old.arc != arc;
}

/// 76 px accent disc: play, or pause while running.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.running, required this.onTap});

  final bool running;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: running ? l10n.pauseTimer : l10n.startTimer,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null ? c.chipOff : c.accent,
            boxShadow: [
              BoxShadow(color: c.ctaShadow, offset: const Offset(0, 5)),
            ],
          ),
          // The play triangle sits optically centred 4 px to the right.
          padding: EdgeInsets.only(left: running ? 0 : 4),
          child: Icon(
            running ? PhosphorIconsFill.pause : PhosphorIconsFill.play,
            size: 30,
            color: onTap == null ? c.faint : c.onAccent,
          ),
        ),
      ),
    );
  }
}

class _AlreadyDoneButton extends StatelessWidget {
  const _AlreadyDoneButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: c.shadowPill, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Icon(PhosphorIconsRegular.clock, size: 18, color: c.ink),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// This week's minutes, one glued cell per day, shaded against the goal.
class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.habit,
    required this.history,
    required this.today,
    required this.todaySeconds,
  });

  final Habit habit;
  final History history;
  final Day today;

  /// Live while a run goes.
  final int todaySeconds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.habitFormat;
    final text = Theme.of(context).textTheme;
    final c = context.sorbet;
    final tones = c.tones[habit.color]!;
    final start = today.weekStart(context.firstWeekday);
    final days = [for (var i = 0; i < 7; i++) start.addDays(i)];
    int minutes(Day d) =>
        (d == today ? todaySeconds : history.valueOf(habit.id, d).toInt()) ~/
        60;
    final total = days
        .where((d) => d <= today)
        .fold(0, (sum, d) => sum + minutes(d));

    Color shade(int m) {
      final ratio = m * 60 / habit.goal;
      if (m == 0) return c.chipOff;
      if (ratio < 0.5) return tones.light;
      if (ratio < 1) return tones.base;
      if (ratio < 1.5) return tones.mid;
      return tones.deep;
    }

    return SorbetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailCardTitle(
            l10n.thisWeek,
            hint: l10n.weekTotal(fmt.number(total)),
            small: true,
          ),
          const SizedBox(height: 10),
          Semantics(
            container: true,
            label: l10n.weekMinutesA11y,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 1,
                  children: [
                    for (final d in days)
                      Expanded(
                        child: _dayCell(
                          context,
                          fmt.weekdayShort(d),
                          d > today ? null : minutes(d),
                          isToday: d == today,
                          bg: d > today ? c.cellOff : shade(minutes(d)),
                          labelColor: d > today
                              ? c.cellOffInk
                              : d == today
                              ? c.ink
                              : c.inkSoft,
                          text: text,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(
    BuildContext context,
    String label,
    int? minutes, {
    required bool isToday,
    required Color bg,
    required Color labelColor,
    required TextTheme text,
  }) {
    final c = context.sorbet;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      foregroundDecoration: isToday
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: c.ink, width: 2.5),
            )
          : null,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 1,
          children: [
            Text(
              label,
              style: text.labelSmall!.copyWith(
                fontSize: 11,
                height: 1,
                color: labelColor,
              ),
            ),
            if (minutes != null)
              Text(
                context.habitFormat.number(minutes),
                style: text.labelLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
