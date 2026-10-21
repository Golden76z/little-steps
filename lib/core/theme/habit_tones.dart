import 'package:flutter/material.dart';

import '../domain/habit.dart';

/// Tonal ramp of one habit colour, palest to darkest. Derived in HSL from
/// the 12 pastels, with the exact values the mockups show for sky, lilac,
/// lemon, pink, peach and mint.
@immutable
class HabitTones {
  const HabitTones({
    required this.pale,
    required this.light,
    required this.base,
    required this.mid,
    required this.strong,
    required this.deep,
    required this.ink,
  });

  /// Card washes (timer face, journal page).
  final Color pale;

  /// Calendar: some progress.
  final Color light;

  /// The habit colour itself.
  final Color base;

  /// Calendar: almost there; done cells of yes/no.
  final Color mid;

  /// Timer arc, filled glasses, goal-met weeks.
  final Color strong;

  /// Calendar: goal met; candy shadows.
  final Color deep;

  /// Icon or text on the palest tones.
  final Color ink;

  static HabitTones lerp(HabitTones a, HabitTones b, double t) => HabitTones(
    pale: Color.lerp(a.pale, b.pale, t)!,
    light: Color.lerp(a.light, b.light, t)!,
    base: Color.lerp(a.base, b.base, t)!,
    mid: Color.lerp(a.mid, b.mid, t)!,
    strong: Color.lerp(a.strong, b.strong, t)!,
    deep: Color.lerp(a.deep, b.deep, t)!,
    ink: Color.lerp(a.ink, b.ink, t)!,
  );
}

const lightHabitTones = <HabitColor, HabitTones>{
  HabitColor.lilac: HabitTones(
    pale: Color(0xFFF4EEFF),
    light: Color(0xFFEEE6FF),
    base: Color(0xFFDCC8FF),
    mid: Color(0xFFC2A8FF),
    strong: Color(0xFFB79BFF),
    deep: Color(0xFFA585F5),
    ink: Color(0xFF3A1C6E),
  ),
  HabitColor.lavender: HabitTones(
    pale: Color(0xFFF2F4FF),
    light: Color(0xFFE5E8FF),
    base: Color(0xFFC9D0FF),
    mid: Color(0xFF9AA7FB),
    strong: Color(0xFF8695F5),
    deep: Color(0xFF6778E9),
    ink: Color(0xFF1C266E),
  ),
  HabitColor.sky: HabitTones(
    pale: Color(0xFFEDF7FF),
    light: Color(0xFFDCEFFF),
    base: Color(0xFFBFE3FF),
    mid: Color(0xFF8FCBF7),
    strong: Color(0xFF6FB8F0),
    deep: Color(0xFF4F9FE0),
    ink: Color(0xFF1E4A6E),
  ),
  HabitColor.lagoon: HabitTones(
    pale: Color(0xFFCEF6F1),
    light: Color(0xFFBFF3ED),
    base: Color(0xFFA8EEE6),
    mid: Color(0xFF82E1D7),
    strong: Color(0xFF71D8CD),
    deep: Color(0xFF57C8BB),
    ink: Color(0xFF1C6E65),
  ),
  HabitColor.mint: HabitTones(
    pale: Color(0xFFDCF8E9),
    light: Color(0xFFCDF5E0),
    base: Color(0xFFB6F0D2),
    mid: Color(0xFF8FE4B8),
    strong: Color(0xFF7FDBAB),
    deep: Color(0xFF64CA95),
    ink: Color(0xFF1F5A3C),
  ),
  HabitColor.pistachio: HabitTones(
    pale: Color(0xFFE9F8D0),
    light: Color(0xFFE2F6C0),
    base: Color(0xFFD6F2A8),
    mid: Color(0xFFC0E780),
    strong: Color(0xFFB4DE6F),
    deep: Color(0xFFA0CE54),
    ink: Color(0xFF4F6E1C),
  ),
  HabitColor.lemon: HabitTones(
    pale: Color(0xFFFFF7C8),
    light: Color(0xFFFFF4B6),
    base: Color(0xFFFFF09A),
    mid: Color(0xFFFFE27A),
    strong: Color(0xFFF2DB5B),
    deep: Color(0xFFE8C930),
    ink: Color(0xFF6E621C),
  ),
  HabitColor.apricot: HabitTones(
    pale: Color(0xFFFFEDD6),
    light: Color(0xFFFFE5C4),
    base: Color(0xFFFFD8A8),
    mid: Color(0xFFF9C17B),
    strong: Color(0xFFF3B468),
    deep: Color(0xFFE5A04A),
    ink: Color(0xFF6E491C),
  ),
  HabitColor.peach: HabitTones(
    pale: Color(0xFFFFF8F3),
    light: Color(0xFFFFDBC0),
    base: Color(0xFFFFCBA4),
    mid: Color(0xFFF2AE7E),
    strong: Color(0xFFF2A06A),
    deep: Color(0xFFE58A47),
    ink: Color(0xFFC26A3A),
  ),
  HabitColor.coral: HabitTones(
    pale: Color(0xFFFFDBD5),
    light: Color(0xFFFFCBC3),
    base: Color(0xFFFFB3A7),
    mid: Color(0xFFF98B7A),
    strong: Color(0xFFF37A67),
    deep: Color(0xFFE55E49),
    ink: Color(0xFF6E271C),
  ),
  HabitColor.pink: HabitTones(
    pale: Color(0xFFFFE6EE),
    light: Color(0xFFFFD4E2),
    base: Color(0xFFFFB8CF),
    mid: Color(0xFFF094B2),
    strong: Color(0xFFF27FA5),
    deep: Color(0xFFE75886),
    ink: Color(0xFF6E1C36),
  ),
  HabitColor.raspberry: HabitTones(
    pale: Color(0xFFFAD9F0),
    light: Color(0xFFF8C9EA),
    base: Color(0xFFF5B0E0),
    mid: Color(0xFFEB87CD),
    strong: Color(0xFFE376C2),
    deep: Color(0xFFD35AAE),
    ink: Color(0xFF6E1C55),
  ),
};
