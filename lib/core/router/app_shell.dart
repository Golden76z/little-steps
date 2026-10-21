import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../icons/phosphor_icons.dart';

import '../l10n/l10n.dart';
import '../widgets/floating_nav_bar.dart';
import 'app_router.dart';

/// Tab scaffold: the floating bar sits over the content, 24 from the sides
/// and 28 from the bottom edge (or above the system inset if it is taller).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = math.max(28.0, MediaQuery.viewPaddingOf(context).bottom);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        body: shell,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottom),
          child: FloatingNavBar(
            label: l10n.mainNavigation,
            addLabel: l10n.newHabit,
            currentIndex: shell.currentIndex,
            onTabSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            onAdd: () => context.push(Routes.create),
            tabs: [
              NavTab(
                label: l10n.tabToday,
                icon: PhosphorIconsRegular.house,
                activeIcon: PhosphorIconsFill.house,
              ),
              NavTab(
                label: l10n.tabProgress,
                icon: PhosphorIconsRegular.chartBar,
                activeIcon: PhosphorIconsFill.chartBar,
              ),
              NavTab(
                label: l10n.tabTrophies,
                icon: PhosphorIconsRegular.trophy,
                activeIcon: PhosphorIconsFill.trophy,
              ),
              NavTab(
                label: l10n.tabProfile,
                icon: PhosphorIconsRegular.user,
                activeIcon: PhosphorIconsFill.user,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
