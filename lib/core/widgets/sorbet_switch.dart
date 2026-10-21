import 'package:flutter/material.dart';

import '../theme/sorbet_colors.dart';

/// 50×30 pill switch: accent track when on, white knob.
class SorbetSwitch extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return Semantics(
      toggled: value,
      label: label,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        // 48 px tall target around the 30 px track.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 50,
            height: 30,
            padding: const EdgeInsets.all(3),
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: value ? c.accent : c.handle,
              borderRadius: BorderRadius.circular(15),
            ),
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
    );
  }
}
