import 'package:flutter/material.dart';

import '../icons/phosphor_icons.dart';
import '../theme/sorbet_colors.dart';

/// 64 px habit pill: pastel fill proportional to progress, icon, name,
/// native value, percentage and a round +/✓ button.
class HabitPill extends StatelessWidget {
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
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final fillFactor = progress <= 0 ? 0.0 : progress.clamp(0.24, 1.0);
    final radius = BorderRadius.circular(32);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: c.shadowPill, offset: const Offset(0, 3)),
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
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 300),
                    widthFactor: fillFactor,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: radius,
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: semanticLabel,
                hint: semanticHint,
                excludeSemantics: true,
                onTap: onTap,
                onLongPress: onLongPress,
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 64),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 8,
                        end: 11,
                      ),
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
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.titleMedium!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodySmall!.copyWith(
                                      color: c.subtitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (percent != null) ...[
                            const SizedBox(width: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 42),
                              child: Text(
                                percent!,
                                textAlign: TextAlign.end,
                                style: text.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          if (showButton) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done ? c.ink : c.track,
                              ),
                              child: Icon(
                                done
                                    ? PhosphorIconsBold.check
                                    : PhosphorIconsBold.plus,
                                size: 16,
                                color: done ? c.onAccent : c.ink,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
                    label: iconSemanticLabel,
                    excludeSemantics: true,
                    onTap: onIconTap,
                    child: InkResponse(
                      onTap: onIconTap,
                      onLongPress: onLongPress,
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
                            child: Icon(icon, size: 22, color: c.ink),
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
    );
  }
}
