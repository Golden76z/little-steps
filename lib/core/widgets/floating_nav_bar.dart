import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/feedback.dart';
import '../icons/phosphor_icons.dart';
import '../theme/sorbet_colors.dart';
import '../theme/motion.dart';
import 'press_scale.dart';
import 'spring_builder.dart';

class NavTab {
  const NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// White floating pill: 2 tabs, the round accent "+", 2 tabs.
class FloatingNavBar extends ConsumerWidget {
  const FloatingNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAdd,
    required this.label,
    required this.addLabel,
  }) : assert(tabs.length == 4);

  final List<NavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAdd;
  final String label;
  final String addLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.sorbet;
    Widget tab(int i) => _TabButton(
      tab: tabs[i],
      selected: i == currentIndex,
      onTap: () {
        if (i != currentIndex) ref.read(feedbackProvider).haptic(Haptic.tick);
        onTabSelected(i);
      },
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: c.divider),
          boxShadow: [
            BoxShadow(color: c.shadowPill, offset: const Offset(0, 4)),
            BoxShadow(
              color: c.floatShadow,
              offset: const Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            tab(0),
            tab(1),
            _RoundButton(
              size: 54,
              color: c.accent,
              shadow: BoxShadow(
                color: c.buttonShadow,
                offset: const Offset(0, 3),
              ),
              semanticLabel: addLabel,
              onTap: onAdd,
              child: Icon(PhosphorIconsBold.plus, size: 24, color: c.onAccent),
            ),
            tab(2),
            tab(3),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  /// Times this tab became the current one: its icon pops each time.
  var _pops = 0;

  @override
  void didUpdateWidget(_TabButton old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) _pops++;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    final _TabButton(:tab, :selected, :onTap) = widget;
    return _RoundButton(
      size: 50,
      color: selected ? c.navActive : null,
      shadow: selected
          ? BoxShadow(color: c.navActiveShadow, offset: const Offset(0, 3))
          : null,
      semanticLabel: tab.label,
      selected: selected,
      onTap: onTap,
      child: Pop(
        trigger: _pops,
        peak: 1.12,
        anticipate: false,
        child: Icon(
          selected ? tab.activeIcon : tab.icon,
          size: 24,
          color: selected ? c.onAccent : c.inkSoft,
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.size,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    this.color,
    this.shadow,
    this.selected,
  });

  final double size;
  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;
  final Color? color;
  final BoxShadow? shadow;
  final bool? selected;

  /// How far it sinks: the candy shadow's offset.
  static const _depth = 3.0;

  @override
  Widget build(BuildContext context) {
    final motion = context.motion(Motion.medium);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      // The shadow stays put while the face sinks over it; a tab without
      // one still sinks as far.
      child: AnimatedContainer(
        duration: motion,
        curve: Motion.curve,
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [?shadow]),
        child: PressSink(
          depth: _depth,
          builder: (context, _) => AnimatedContainer(
            duration: motion,
            curve: Motion.curve,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox.square(
                  dimension: size,
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
