import 'package:flutter/widgets.dart';

import 'phosphor_icons.dart';

/// Icons a habit can wear, keyed by the name stored in the database.
const habitIcons = <String, IconData>{
  'drop': PhosphorIconsRegular.drop,
  'book': PhosphorIconsRegular.book,
  'lotus': PhosphorIconsRegular.flowerLotus,
  'barbell': PhosphorIconsRegular.barbell,
  'pencil': PhosphorIconsRegular.pencilSimple,
  'moon': PhosphorIconsRegular.moon,
  'brush': PhosphorIconsRegular.paintBrush,
  'run': PhosphorIconsRegular.personSimpleRun,
  'pill': PhosphorIconsRegular.pill,
  'timer': PhosphorIconsRegular.timer,
};

IconData habitIcon(String key) =>
    habitIcons[key] ?? PhosphorIconsRegular.sparkle;
