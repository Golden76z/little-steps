import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/domain/habit.dart';
import '../../core/feedback/feedback.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/app_header_card.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/sorbet_card.dart';
import 'profile_screen.dart';

/// Active habits as draggable cards; the dropped order is saved at once and
/// Today, Progress and the rest follow it.
class OrganizeScreen extends ConsumerStatefulWidget {
  const OrganizeScreen({super.key});

  @override
  ConsumerState<OrganizeScreen> createState() => _OrganizeScreenState();
}

class _OrganizeScreenState extends ConsumerState<OrganizeScreen> {
  /// The order just dropped, shown until the database stream echoes it.
  List<Habit>? _dropped;

  void _reorder(List<Habit> habits, int from, int to) {
    final next = [...habits];
    next.insert(to, next.removeAt(from));
    setState(() => _dropped = next);
    ref.read(feedbackProvider).haptic(Haptic.tick);
    ref
        .read(habitRepositoryProvider)
        .reorder([for (final h in next) h.id])
        .catchError((Object e) {
          debugPrint('Little Steps: reorder not saved: $e');
          // Back to the stored order.
          if (mounted) setState(() => _dropped = null);
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    ref.listen(habitsProvider, (_, next) {
      final ids = next.value?.map((h) => h.id).toList();
      if (_dropped != null &&
          listEquals(ids, [for (final h in _dropped!) h.id])) {
        setState(() => _dropped = null);
      }
    });
    final habits = _dropped ?? ref.watch(habitsProvider).value ?? const [];
    return Scaffold(
      body: Column(
        children: [
          AppHeaderCard(
            band: Container(
              constraints: const BoxConstraints(
                minHeight: AppHeaderCard.bandHeight,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: c.strip,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                l10n.organizeHint,
                style: text.bodyMedium!.copyWith(color: c.muted),
                textAlign: TextAlign.center,
              ),
            ),
            top: Row(
              children: [
                // 48 px target shifted 4 px outwards: the 40 px disc keeps the
                // 20 px margin, and the 6 px gap makes 10 px visually.
                Transform.translate(
                  offset: const Offset(-4, 0),
                  child: RoundIconButton(
                    icon: PhosphorIconsBold.caretLeft,
                    label: l10n.backLabel,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(l10n.rowOrganize, style: text.headlineLarge),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.paddingOf(context).bottom + 16,
              ),
              buildDefaultDragHandles: false,
              itemCount: habits.length,
              onReorderItem: (from, to) => _reorder(habits, from, to),
              // A slight lift instead of the default rectangular shadow.
              proxyDecorator: (child, _, animation) => Material(
                type: MaterialType.transparency,
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.03).animate(
                    CurvedAnimation(parent: animation, curve: Motion.curve),
                  ),
                  child: child,
                ),
              ),
              itemBuilder: (context, i) {
                final h = habits[i];
                return Padding(
                  key: ValueKey(h.id),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SorbetCard(
                    padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
                    child: Row(
                      spacing: 12,
                      children: [
                        ProfileIconBox(
                          color: c.habit[h.color]!,
                          icon: habitIcon(h.icon),
                          circle: true,
                        ),
                        Expanded(child: Text(h.name, style: text.bodyLarge)),
                        ReorderableDragStartListener(
                          index: i,
                          child: Semantics(
                            container: true,
                            label: l10n.moveHabit(h.name),
                            child: SizedBox.square(
                              dimension: 48,
                              child: Icon(
                                PhosphorIconsBold.dotsSixVertical,
                                size: 20,
                                color: c.muted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
