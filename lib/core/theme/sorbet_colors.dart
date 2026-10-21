import 'package:flutter/material.dart';

/// The 12 habit tints offered at creation, in the P2-Reglages order.
enum HabitColor {
  lilac,
  lavender,
  sky,
  lagoon,
  mint,
  pistachio,
  lemon,
  apricot,
  peach,
  coral,
  pink,
  raspberry,
}

/// Sorbet design tokens. Widgets read every color from here so a dark
/// variant only needs a second instance.
@immutable
class SorbetColors extends ThemeExtension<SorbetColors> {
  const SorbetColors({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.subtitle,
    required this.navIcon,
    required this.accent,
    required this.onAccent,
    required this.navActive,
    required this.navActiveShadow,
    required this.strip,
    required this.selectedBorder,
    required this.shadowPill,
    required this.divider,
    required this.track,
    required this.flameChip,
    required this.flame,
    required this.cardShadow,
    required this.floatShadow,
    required this.buttonShadow,
    required this.habit,
  });

  final Color bg;
  final Color surface;
  final Color ink;
  final Color muted;

  /// Secondary line inside a habit pill.
  final Color subtitle;

  /// Inactive tab icon.
  final Color navIcon;
  final Color accent;
  final Color onAccent;
  final Color navActive;
  final Color navActiveShadow;
  final Color strip;

  /// Inset outline of the selected cell in a segmented strip.
  final Color selectedBorder;

  /// Solid "candy" drop shadow under pills and the bottom bar.
  final Color shadowPill;
  final Color divider;

  /// Unfilled ring / round button background.
  final Color track;
  final Color flameChip;
  final Color flame;

  /// Soft shadow of the header card.
  final Color cardShadow;

  /// Soft shadow of the floating bar.
  final Color floatShadow;

  /// Drop shadow under the accent "+" button.
  final Color buttonShadow;
  final Map<HabitColor, Color> habit;

  static const light = SorbetColors(
    bg: Color(0xFFFFF0F4),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF3B1730),
    muted: Color(0xFF7A5670),
    subtitle: Color(0xFF6A4A60),
    navIcon: Color(0xFF5E4A58),
    accent: Color(0xFFF0507F),
    onAccent: Color(0xFFFFFFFF),
    navActive: Color(0xFFEF6F9C),
    navActiveShadow: Color(0xFFD9527F),
    strip: Color(0xFFFFF4F7),
    selectedBorder: Color(0xFFFFC9DA),
    shadowPill: Color(0xFFF3D6E0),
    divider: Color(0xFFF6DCE6),
    track: Color(0xFFF9E3EB),
    flameChip: Color(0xFFFFE6D6),
    flame: Color(0xFFFF7A3D),
    cardShadow: Color(0x0F3B1730), // rgba(59,23,48,0.06)
    floatShadow: Color(0x143B1730), // rgba(59,23,48,0.08)
    buttonShadow: Color(0x383B1730), // rgba(59,23,48,0.22)
    habit: {
      HabitColor.lilac: Color(0xFFDCC8FF),
      HabitColor.lavender: Color(0xFFC9D0FF),
      HabitColor.sky: Color(0xFFBFE3FF),
      HabitColor.lagoon: Color(0xFFA8EEE6),
      HabitColor.mint: Color(0xFFB6F0D2),
      HabitColor.pistachio: Color(0xFFD6F2A8),
      HabitColor.lemon: Color(0xFFFFF09A),
      HabitColor.apricot: Color(0xFFFFD8A8),
      HabitColor.peach: Color(0xFFFFCBA4),
      HabitColor.coral: Color(0xFFFFB3A7),
      HabitColor.pink: Color(0xFFFFB8CF),
      HabitColor.raspberry: Color(0xFFF5B0E0),
    },
  );

  @override
  SorbetColors copyWith({
    Color? bg,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? subtitle,
    Color? navIcon,
    Color? accent,
    Color? onAccent,
    Color? navActive,
    Color? navActiveShadow,
    Color? strip,
    Color? selectedBorder,
    Color? shadowPill,
    Color? divider,
    Color? track,
    Color? flameChip,
    Color? flame,
    Color? cardShadow,
    Color? floatShadow,
    Color? buttonShadow,
    Map<HabitColor, Color>? habit,
  }) {
    return SorbetColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      subtitle: subtitle ?? this.subtitle,
      navIcon: navIcon ?? this.navIcon,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      navActive: navActive ?? this.navActive,
      navActiveShadow: navActiveShadow ?? this.navActiveShadow,
      strip: strip ?? this.strip,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      shadowPill: shadowPill ?? this.shadowPill,
      divider: divider ?? this.divider,
      track: track ?? this.track,
      flameChip: flameChip ?? this.flameChip,
      flame: flame ?? this.flame,
      cardShadow: cardShadow ?? this.cardShadow,
      floatShadow: floatShadow ?? this.floatShadow,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      habit: habit ?? this.habit,
    );
  }

  @override
  SorbetColors lerp(SorbetColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SorbetColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      subtitle: l(subtitle, other.subtitle),
      navIcon: l(navIcon, other.navIcon),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      navActive: l(navActive, other.navActive),
      navActiveShadow: l(navActiveShadow, other.navActiveShadow),
      strip: l(strip, other.strip),
      selectedBorder: l(selectedBorder, other.selectedBorder),
      shadowPill: l(shadowPill, other.shadowPill),
      divider: l(divider, other.divider),
      track: l(track, other.track),
      flameChip: l(flameChip, other.flameChip),
      flame: l(flame, other.flame),
      cardShadow: l(cardShadow, other.cardShadow),
      floatShadow: l(floatShadow, other.floatShadow),
      buttonShadow: l(buttonShadow, other.buttonShadow),
      habit: {
        for (final c in HabitColor.values) c: l(habit[c]!, other.habit[c]!),
      },
    );
  }
}

extension SorbetContext on BuildContext {
  SorbetColors get sorbet => Theme.of(this).extension<SorbetColors>()!;
}
