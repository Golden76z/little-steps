import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/feedback.dart';
import '../theme/motion.dart';
import '../theme/sorbet_colors.dart';
import 'press_scale.dart';
import 'spring_builder.dart';

/// 50×30 pill switch: accent track when on, white knob.
class SorbetSwitch extends ConsumerWidget {
  const SorbetSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.sorbet;
    void toggle() {
      ref.read(feedbackProvider).haptic(Haptic.tick);
      onChanged(!value);
    }

    return Semantics(
      toggled: value,
      label: label,
      excludeSemantics: true,
      onTap: toggle,
      child: GestureDetector(
        onTap: toggle,
        behavior: HitTestBehavior.opaque,
        // 48 px tall target around the 30 px track.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: PressScale(
            child: AnimatedContainer(
              duration: context.motion(Motion.fast),
              curve: Motion.curve,
              width: 50,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? c.accent : c.handle,
                borderRadius: BorderRadius.circular(15),
              ),
              child: SpringBuilder(
                value: value ? 1 : -1,
                spring: Springs.snappy,
                builder: (context, x, knob) =>
                    Align(alignment: AlignmentDirectional(x, 0), child: knob),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.surface,
                    boxShadow: [
                      BoxShadow(
                        color: c.knobShadow,
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
