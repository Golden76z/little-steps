import 'package:flutter/material.dart';

import '../domain/habit.dart';

export '../domain/habit.dart' show HabitColor;

/// Sorbet design tokens. Widgets read every color from here so a dark
/// variant only needs a second instance.
@immutable
class SorbetColors extends ThemeExtension<SorbetColors> {
  const SorbetColors({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.faint,
    required this.subtitle,
    required this.accent,
    required this.onAccent,
    required this.navActive,
    required this.navActiveShadow,
    required this.strip,
    required this.selectedBorder,
    required this.shadowPill,
    required this.divider,
    required this.track,
    required this.iconHalo,
    required this.flameChip,
    required this.flame,
    required this.chipOff,
    required this.flameOff,
    required this.dashed,
    required this.sheetGroup,
    required this.sheetDivider,
    required this.handle,
    required this.danger,
    required this.cardShadow,
    required this.floatShadow,
    required this.buttonShadow,
    required this.ctaShadow,
    required this.barrier,
    required this.sheetShadow,
    required this.radioOff,
    required this.badge,
    required this.dayOn,
    required this.dayOnInk,
    required this.cellOff,
    required this.cellOffInk,
    required this.knobShadow,
    required this.habit,
  });

  final Color bg;
  final Color surface;
  final Color ink;

  /// Body copy on the empty state, inactive tab icon.
  final Color inkSoft;
  final Color muted;

  /// Disabled or zero values (empty streak chip).
  final Color faint;

  /// Secondary line inside a habit pill.
  final Color subtitle;
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

  /// Disc behind a habit icon on its pastel fill (white 75 %).
  final Color iconHalo;
  final Color flameChip;
  final Color flame;

  /// Chip or cell with nothing to show yet.
  final Color chipOff;
  final Color flameOff;

  /// Dashed outline of placeholder pills and slots.
  final Color dashed;

  /// Grouped rows inside a bottom sheet.
  final Color sheetGroup;
  final Color sheetDivider;

  /// Bottom sheet grab handle.
  final Color handle;
  final Color danger;

  /// Soft shadow of the header card, ink 6 %.
  final Color cardShadow;

  /// Soft shadow of the floating bar, ink 8 %.
  final Color floatShadow;

  /// Drop shadow under the round accent "+", ink 22 %.
  final Color buttonShadow;

  /// Drop shadow under wide accent buttons, ink 20 %.
  final Color ctaShadow;

  /// Scrim behind a bottom sheet, ink 38 %.
  final Color barrier;

  /// Shadow cast upwards by a bottom sheet, ink 15 %.
  final Color sheetShadow;

  /// Unselected radio ring.
  final Color radioOff;

  /// Type badge on a popular tile (white 70 %).
  final Color badge;

  /// Active weekday cell in the planning.
  final Color dayOn;
  final Color dayOnInk;

  /// Empty or inactive calendar cell.
  final Color cellOff;
  final Color cellOffInk;

  /// Shadow under a switch knob, ink 25 %.
  final Color knobShadow;
  final Map<HabitColor, Color> habit;

  static const light = SorbetColors(
    bg: Color(0xFFFFF0F4),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF3B1730),
    inkSoft: Color(0xFF5E4A58),
    muted: Color(0xFF7A5670),
    faint: Color(0xFF9A7A90),
    subtitle: Color(0xFF6A4A60),
    accent: Color(0xFFF0507F),
    onAccent: Color(0xFFFFFFFF),
    navActive: Color(0xFFEF6F9C),
    navActiveShadow: Color(0xFFD9527F),
    strip: Color(0xFFFFF4F7),
    selectedBorder: Color(0xFFFFC9DA),
    shadowPill: Color(0xFFF3D6E0),
    divider: Color(0xFFF6DCE6),
    track: Color(0xFFF9E3EB),
    iconHalo: Color(0xBFFFFFFF),
    flameChip: Color(0xFFFFE6D6),
    flame: Color(0xFFFF7A3D),
    chipOff: Color(0xFFF6ECF0),
    flameOff: Color(0xFFC9A9BC),
    dashed: Color(0xFFF3C9D7),
    sheetGroup: Color(0xFFFFF8FA),
    sheetDivider: Color(0xFFFBEAF0),
    handle: Color(0xFFEBDDE4),
    danger: Color(0xFFB4234F),
    cardShadow: Color(0x0F3B1730),
    floatShadow: Color(0x143B1730),
    buttonShadow: Color(0x383B1730),
    ctaShadow: Color(0x333B1730),
    barrier: Color(0x613B1730),
    sheetShadow: Color(0x263B1730),
    radioOff: Color(0xFFE2C6D3),
    badge: Color(0xB3FFFFFF),
    dayOn: Color(0xFFBFE3FF),
    dayOnInk: Color(0xFF1E4A6E),
    cellOff: Color(0xFFFBF4F7),
    cellOffInk: Color(0xFFB9A0AF),
    knobShadow: Color(0x403B1730),
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
    Color? inkSoft,
    Color? muted,
    Color? faint,
    Color? subtitle,
    Color? accent,
    Color? onAccent,
    Color? navActive,
    Color? navActiveShadow,
    Color? strip,
    Color? selectedBorder,
    Color? shadowPill,
    Color? divider,
    Color? track,
    Color? iconHalo,
    Color? flameChip,
    Color? flame,
    Color? chipOff,
    Color? flameOff,
    Color? dashed,
    Color? sheetGroup,
    Color? sheetDivider,
    Color? handle,
    Color? danger,
    Color? cardShadow,
    Color? floatShadow,
    Color? buttonShadow,
    Color? ctaShadow,
    Color? barrier,
    Color? sheetShadow,
    Color? radioOff,
    Color? badge,
    Color? dayOn,
    Color? dayOnInk,
    Color? cellOff,
    Color? cellOffInk,
    Color? knobShadow,
    Map<HabitColor, Color>? habit,
  }) {
    return SorbetColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      subtitle: subtitle ?? this.subtitle,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      navActive: navActive ?? this.navActive,
      navActiveShadow: navActiveShadow ?? this.navActiveShadow,
      strip: strip ?? this.strip,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      shadowPill: shadowPill ?? this.shadowPill,
      divider: divider ?? this.divider,
      track: track ?? this.track,
      iconHalo: iconHalo ?? this.iconHalo,
      flameChip: flameChip ?? this.flameChip,
      flame: flame ?? this.flame,
      chipOff: chipOff ?? this.chipOff,
      flameOff: flameOff ?? this.flameOff,
      dashed: dashed ?? this.dashed,
      sheetGroup: sheetGroup ?? this.sheetGroup,
      sheetDivider: sheetDivider ?? this.sheetDivider,
      handle: handle ?? this.handle,
      danger: danger ?? this.danger,
      cardShadow: cardShadow ?? this.cardShadow,
      floatShadow: floatShadow ?? this.floatShadow,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      ctaShadow: ctaShadow ?? this.ctaShadow,
      barrier: barrier ?? this.barrier,
      sheetShadow: sheetShadow ?? this.sheetShadow,
      radioOff: radioOff ?? this.radioOff,
      badge: badge ?? this.badge,
      dayOn: dayOn ?? this.dayOn,
      dayOnInk: dayOnInk ?? this.dayOnInk,
      cellOff: cellOff ?? this.cellOff,
      cellOffInk: cellOffInk ?? this.cellOffInk,
      knobShadow: knobShadow ?? this.knobShadow,
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
      inkSoft: l(inkSoft, other.inkSoft),
      muted: l(muted, other.muted),
      faint: l(faint, other.faint),
      subtitle: l(subtitle, other.subtitle),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      navActive: l(navActive, other.navActive),
      navActiveShadow: l(navActiveShadow, other.navActiveShadow),
      strip: l(strip, other.strip),
      selectedBorder: l(selectedBorder, other.selectedBorder),
      shadowPill: l(shadowPill, other.shadowPill),
      divider: l(divider, other.divider),
      track: l(track, other.track),
      iconHalo: l(iconHalo, other.iconHalo),
      flameChip: l(flameChip, other.flameChip),
      flame: l(flame, other.flame),
      chipOff: l(chipOff, other.chipOff),
      flameOff: l(flameOff, other.flameOff),
      dashed: l(dashed, other.dashed),
      sheetGroup: l(sheetGroup, other.sheetGroup),
      sheetDivider: l(sheetDivider, other.sheetDivider),
      handle: l(handle, other.handle),
      danger: l(danger, other.danger),
      cardShadow: l(cardShadow, other.cardShadow),
      floatShadow: l(floatShadow, other.floatShadow),
      buttonShadow: l(buttonShadow, other.buttonShadow),
      ctaShadow: l(ctaShadow, other.ctaShadow),
      barrier: l(barrier, other.barrier),
      sheetShadow: l(sheetShadow, other.sheetShadow),
      radioOff: l(radioOff, other.radioOff),
      badge: l(badge, other.badge),
      dayOn: l(dayOn, other.dayOn),
      dayOnInk: l(dayOnInk, other.dayOnInk),
      cellOff: l(cellOff, other.cellOff),
      cellOffInk: l(cellOffInk, other.cellOffInk),
      knobShadow: l(knobShadow, other.knobShadow),
      habit: {
        for (final c in HabitColor.values) c: l(habit[c]!, other.habit[c]!),
      },
    );
  }
}

extension SorbetContext on BuildContext {
  SorbetColors get sorbet => Theme.of(this).extension<SorbetColors>()!;
}
