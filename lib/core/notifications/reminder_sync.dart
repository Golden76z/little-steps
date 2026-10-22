import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers.dart';
import '../l10n/formatters.dart';
import '../l10n/l10n.dart';
import '../router/app_router.dart';
import '../time/today_provider.dart';
import 'reminder_planner.dart';
import 'reminder_scheduler.dart';

/// Keeps the scheduled notifications in step with the data: on launch,
/// on resume, at each change and at the day rollover.
class ReminderSync extends ConsumerStatefulWidget {
  const ReminderSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderSync> createState() => _ReminderSyncState();
}

class _ReminderSyncState extends ConsumerState<ReminderSync> {
  Timer? _debounce;
  late final _lifecycle = AppLifecycleListener(onResume: _queue);

  @override
  void initState() {
    super.initState();
    _lifecycle; // starts listening
    WidgetsBinding.instance.addPostFrameCallback((_) => _queue());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  /// Bursts of changes (a few taps) end in a single reschedule.
  void _queue() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _sync);
  }

  Future<void> _sync() async {
    final history = ref.read(historyProvider).value;
    final habits = ref.read(habitsProvider).value;
    if (!mounted || history == null || habits == null) return;
    final l10n = context.l10n;
    final plans = planReminders(
      history,
      habits,
      ref.read(clockProvider)(),
      rolloverHour: ref.read(rolloverHourProvider),
      firstWeekday: context.firstWeekday,
    );
    String names(List<String> n) => n.length < 2
        ? n.join()
        : l10n.listAnd(n.sublist(0, n.length - 1).join(', '), n.last);
    await ref
        .read(reminderSchedulerProvider)
        .replaceAll(
          [
            for (final p in plans)
              switch (p.kind) {
                ReminderKind.habit => ScheduledNotification(
                  id: p.id,
                  at: p.at,
                  title: p.habits.single.name,
                  body: l10n.reminderBody,
                  payload: Routes.habit(p.habits.single.id),
                ),
                ReminderKind.streakDanger => ScheduledNotification(
                  id: p.id,
                  at: p.at,
                  title: l10n.streakAtRisk,
                  body: l10n.dangerBody(
                    names([for (final h in p.habits) h.name]),
                  ),
                  payload: Routes.today,
                ),
              },
          ],
          channelName: l10n.notifChannelName,
          channelDescription: l10n.notifChannelDescription,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(historyProvider, (_, _) => _queue())
      ..listen(habitsProvider, (_, _) => _queue())
      ..listen(rolloverHourProvider, (_, _) => _queue())
      ..listen(todayProvider, (_, _) => _queue());
    return widget.child;
  }
}
