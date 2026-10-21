import '../../core/domain/habit.dart';
import '../../core/l10n/l10n.dart';
import 'habit_draft.dart';

String typeName(AppLocalizations l10n, HabitType t) => switch (t) {
  HabitType.quantity => l10n.typeQuantity,
  HabitType.duration => l10n.typeDuration,
  HabitType.yesNo => l10n.typeYesNo,
  HabitType.journal => l10n.typeJournal,
  HabitType.frequency => l10n.typeFrequency,
};

String typeExample(AppLocalizations l10n, HabitType t) => switch (t) {
  HabitType.quantity => l10n.typeQuantityEx,
  HabitType.duration => l10n.typeDurationEx,
  HabitType.yesNo => l10n.typeYesNoEx,
  HabitType.journal => l10n.typeJournalEx,
  HabitType.frequency => l10n.typeFrequencyEx,
};

String presetLabel(AppLocalizations l10n, Preset p) => switch (p) {
  Preset.water => l10n.popWater,
  Preset.read => l10n.popRead,
  Preset.draw => l10n.popDraw,
  Preset.run => l10n.popRun,
  Preset.vitamins => l10n.popVitamins,
  Preset.gratitude => l10n.popGratitude,
  Preset.meditate => l10n.popMeditate,
};

String colorName(AppLocalizations l10n, HabitColor c) => switch (c) {
  HabitColor.lilac => l10n.colorLilac,
  HabitColor.lavender => l10n.colorLavender,
  HabitColor.sky => l10n.colorSky,
  HabitColor.lagoon => l10n.colorLagoon,
  HabitColor.mint => l10n.colorMint,
  HabitColor.pistachio => l10n.colorPistachio,
  HabitColor.lemon => l10n.colorLemon,
  HabitColor.apricot => l10n.colorApricot,
  HabitColor.peach => l10n.colorPeach,
  HabitColor.coral => l10n.colorCoral,
  HabitColor.pink => l10n.colorPink,
  HabitColor.raspberry => l10n.colorRaspberry,
};

String unitLabel(AppLocalizations l10n, QuantityUnit u) => switch (u) {
  QuantityUnit.glasses => l10n.unitGlasses,
  QuantityUnit.liters => l10n.unitLiters,
  QuantityUnit.milliliters => l10n.unitMl,
  QuantityUnit.pages => l10n.unitPages,
  QuantityUnit.steps => l10n.unitSteps,
  QuantityUnit.kilometers => l10n.unitKm,
  QuantityUnit.times => l10n.unitTimes,
};

String momentShort(AppLocalizations l10n, Moment m) => switch (m) {
  Moment.morning => l10n.momentMorningShort,
  Moment.noon => l10n.momentNoonShort,
  Moment.evening => l10n.momentEveningShort,
  Moment.anytime => l10n.momentAnytimeShort,
};
