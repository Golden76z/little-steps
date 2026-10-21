import 'package:flutter/material.dart';

import '../icons/phosphor_icons.dart';
import '../theme/sorbet_colors.dart';

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
class FloatingNavBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final c = context.sorbet;
    Widget tab(int i) => _TabButton(
      tab: tabs[i],
      selected: i == currentIndex,
      onTap: () => onTabSelected(i),
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sorbet;
    return _RoundButton(
      size: 50,
      color: selected ? c.navActive : null,
      shadow: selected
          ? BoxShadow(color: c.navActiveShadow, offset: const Offset(0, 3))
          : null,
      semanticLabel: tab.label,
      selected: selected,
      onTap: onTap,
      child: Icon(
        selected ? tab.activeIcon : tab.icon,
        size: 24,
        color: selected ? c.onAccent : c.navIcon,
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [?shadow],
        ),
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
    );
  }
}
