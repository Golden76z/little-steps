import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/feedback.dart';
import '../icons/phosphor_icons.dart';
import '../l10n/l10n.dart';
import '../theme/motion.dart';
import '../theme/sorbet_colors.dart';
import 'press_scale.dart';
import 'rolling_text.dart';
import 'spring_builder.dart';

/// A finger resting this long on a pill starts charging it, and is no tap.
const holdDelay = Duration(milliseconds: 200);

/// Then the fill runs up to 100 % in this time, and the hold completes.
const holdCharge = Duration(milliseconds: 600);

/// 64 px habit pill: pastel fill proportional to progress, icon, name,
/// native value, percentage and a round +/✓ button. With [onHoldComplete],
/// holding it still fills it up to 100 % and calls it.
class HabitPill extends ConsumerStatefulWidget {
  const HabitPill({
    super.key,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.fill,
    required this.progress,
    required this.semanticLabel,
    this.percent,
    this.done = false,
    this.showButton = true,
    this.semanticHint,
    this.iconSemanticLabel,
    this.onTap,
    this.onIconTap,
    this.onLongPress,
    this.onHoldComplete,
    this.onIconLongPress,
    this.celebrate = 0,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Color fill;

  /// 0–1; the fill never shrinks below 24 % once started so it covers the icon.
  final double progress;
  final String? percent;
  final bool done;
  final bool showButton;
  final String semanticLabel;
  final String? semanticHint;
  final String? iconSemanticLabel;
  final VoidCallback? onTap;
  final VoidCallback? onIconTap;

  /// On the whole pill (resting pills); the icon too when [onIconLongPress]
  /// is null.
  final VoidCallback? onLongPress;
  final VoidCallback? onHoldComplete;
  final VoidCallback? onIconLongPress;

  /// Goes up when the habit is completed: the pill and its ✓ pop.
  final int celebrate;

  @override
  ConsumerState<HabitPill> createState() => _HabitPillState();
}

class _HabitPillState extends ConsumerState<HabitPill>
    with SingleTickerProviderStateMixin {
  late final _fill = AnimationController.unbounded(vsync: this, value: _target);
  Timer? _timer;
  Offset? _down;
  bool _charging = false;

  /// The finger stayed past [holdDelay]: lifting it is no tap.
  bool _longTouch = false;

  double get _target {
    final p = widget.progress;
    return p <= 0 ? 0.0 : p.clamp(0.24, 1.0);
  }

  /// Springs the fill to the real value, from where it is.
  void _settle() {
    if (context.reduceMotion) {
      _fill.value = _target;
    } else if (_fill.value != _target || _fill.isAnimating) {
      _fill.animateWith(
        SpringSimulation(
          Springs.fill,
          _fill.value,
          _target,
          _fill.velocity,
          snapToEnd: true,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(HabitPill old) {
    super.didUpdateWidget(old);
    if (_charging) {
      if (widget.onHoldComplete == null) _release();
    } else if (old.progress != widget.progress ||
        (_fill.value != _target && !_fill.isAnimating)) {
      _settle();
    }
  }

  void _pointerDown(PointerDownEvent e) {
    _release();
    _longTouch = false;
    // Resting pills keep the plain long press.
    if (widget.onLongPress != null) return;
    _down = e.position;
    // A pill that cannot be held only drops taps past the long-press time.
    _timer = Timer(
      widget.onHoldComplete == null ? kLongPressTimeout : holdDelay,
      _charge,
    );
  }

  void _charge() {
    _longTouch = true;
    if (widget.onHoldComplete == null) return;
    _charging = true;
    ref.read(feedbackProvider).haptic(Haptic.tick);
    // Linear on purpose: the finger waits on a steady, readable charge.
    if (!context.reduceMotion) _fill.animateTo(1, duration: holdCharge);
    _timer = Timer(holdCharge, () {
      _timer = null;
      _charging = false;
      widget.onHoldComplete?.call();
    });
  }

  /// Finger up, gone into a scroll or cancelled: a charge falls back.
  void _release() {
    _down = null;
    _timer?.cancel();
    _timer = null;
    if (_charging) {
      _charging = false;
      _settle();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(32);
    final onTap = widget.onTap;
    final actions = {
      CustomSemanticsAction(label: l10n.actionComplete): ?widget.onHoldComplete,
      CustomSemanticsAction(label: l10n.actionOptions): ?widget.onIconLongPress,
    };
    return RepaintBoundary(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Pop(
          trigger: widget.celebrate,
          child: PressSink(
            depth: 3,
            enabled: onTap != null || widget.onIconTap != null,
            builder: (context, pressed) => DecoratedBox(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: c.shadowPill,
                    offset: Offset(0, 3 - 3 * pressed),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                borderRadius: radius,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AnimatedBuilder(
                          animation: _fill,
                          builder: (context, child) => FractionallySizedBox(
                            widthFactor: _fill.value.clamp(0.0, 1.0),
                            heightFactor: 1,
                            child: child,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: widget.fill,
                              borderRadius: radius,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: widget.semanticLabel,
                      hint: widget.semanticHint,
                      excludeSemantics: true,
                      onTap: onTap,
                      onLongPress: widget.onLongPress,
                      customSemanticsActions: actions.isEmpty ? null : actions,
                      child: Listener(
                        onPointerDown: _pointerDown,
                        onPointerMove: (e) {
                          final start = _down;
                          if (start != null &&
                              (e.position - start).distance > kTouchSlop) {
                            _release();
                          }
                        },
                        onPointerUp: (_) => _release(),
                        onPointerCancel: (_) => _release(),
                        child: InkWell(
                          onTap: onTap == null
                              ? null
                              : () {
                                  if (!_longTouch) onTap();
                                  _longTouch = false;
                                },
                          onLongPress: widget.onLongPress,
                          child: _content(context, text, c),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Semantics(
                          button: true,
                          label: widget.iconSemanticLabel,
                          excludeSemantics: true,
                          onTap: widget.onIconTap,
                          child: InkResponse(
                            onTap: widget.onIconTap,
                            onLongPress:
                                widget.onIconLongPress ?? widget.onLongPress,
                            radius: 24,
                            child: SizedBox.square(
                              dimension: 48,
                              child: Center(
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c.iconHalo,
                                  ),
                                  child: Icon(
                                    widget.icon,
                                    size: 22,
                                    color: c.ink,
                                  ),
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
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, TextTheme text, SorbetColors c) =>
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8, end: 11),
          child: Row(
            children: [
              // 48 px target around the 42 px disc.
              const SizedBox(width: 48),
              const SizedBox(width: 9),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      RollingText(
                        widget.subtitle,
                        value: widget.progress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall!.copyWith(color: c.subtitle),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.percent case final percent?) ...[
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 42),
                  child: RollingText(
                    percent,
                    value: widget.progress,
                    alignment: AlignmentDirectional.centerEnd,
                    textAlign: TextAlign.end,
                    style: text.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (widget.showButton) ...[
                const SizedBox(width: 12),
                Pop(
                  trigger: widget.celebrate,
                  peak: 1.15,
                  child: AnimatedContainer(
                    duration: context.motion(Motion.fast),
                    curve: Motion.curve,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.done ? c.ink : c.track,
                    ),
                    // + and ✓ fade into each other; the pop is the button's.
                    child: AnimatedSwitcher(
                      duration: context.motion(Motion.medium),
                      switchInCurve: Motion.curve,
                      switchOutCurve: Motion.curve,
                      child: Icon(
                        widget.done
                            ? PhosphorIconsBold.check
                            : PhosphorIconsBold.plus,
                        key: ValueKey(widget.done),
                        size: 16,
                        color: widget.done ? c.onAccent : c.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}
