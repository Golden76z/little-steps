// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Little Steps';

  @override
  String get tabToday => 'Today';

  @override
  String get tabProgress => 'Progress';

  @override
  String get tabTrophies => 'Trophies';

  @override
  String get tabProfile => 'Profile';

  @override
  String get newHabit => 'New habit';

  @override
  String get mainNavigation => 'Main navigation';

  @override
  String levelMonth(int level, String month) {
    return 'Level $level · $month';
  }

  @override
  String levelProgress(int level, String percent, int next) {
    return 'Level $level, $percent to level $next';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '$count-day streak',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get calendar => 'Calendar';

  @override
  String get weekDays => 'Days of the week';

  @override
  String get restToday => 'Resting today';

  @override
  String get restOnDay => 'Resting';

  @override
  String get restDay => 'Rest day';

  @override
  String pausedUntil(String date) {
    return 'Paused until $date';
  }

  @override
  String valueLiters(String value, String goal) {
    return '$value / $goal L';
  }

  @override
  String valueGlasses(String value, String goal, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'glasses',
      one: 'glass',
    );
    return '$value / $goal $_temp0';
  }

  @override
  String valueMl(String value, String goal) {
    return '$value / $goal ml';
  }

  @override
  String valuePages(String value, String goal, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pages',
      one: 'page',
    );
    return '$value / $goal $_temp0';
  }

  @override
  String valueTimes(String value, String goal, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'times',
      one: 'time',
    );
    return '$value / $goal $_temp0';
  }

  @override
  String valueMinutes(String value, String goal) {
    return '$value / $goal min';
  }

  @override
  String valueLines(String value, String goal, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lines',
      one: 'line',
    );
    return '$value / $goal $_temp0';
  }

  @override
  String valueThisWeek(String value, String goal) {
    return '$value / $goal this week';
  }

  @override
  String get doneLabel => 'Done!';

  @override
  String get momentMorning => 'This morning';

  @override
  String get momentNoon => 'At noon';

  @override
  String get momentEvening => 'Tonight';

  @override
  String get momentAnytime => 'Today';

  @override
  String stepCl(String value) {
    return '$value cl';
  }

  @override
  String stepMl(String value) {
    return '$value ml';
  }

  @override
  String stepGlasses(String value, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$value glasses',
      one: '$value glass',
    );
    return '$_temp0';
  }

  @override
  String stepPages(String value, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$value pages',
      one: '$value page',
    );
    return '$_temp0';
  }

  @override
  String stepTimes(String value, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$value times',
      one: '$value time',
    );
    return '$_temp0';
  }

  @override
  String stepMinutes(String value) {
    return '$value min';
  }

  @override
  String pillLabel(String name, String percent) {
    return '$name, $percent';
  }

  @override
  String get pillDone => 'done';

  @override
  String hintAdd(String step) {
    return 'add $step';
  }

  @override
  String get hintCheck => 'mark as done';

  @override
  String get hintUncheck => 'unmark';

  @override
  String get hintStartTimer => 'start the timer';

  @override
  String get hintWrite => 'write';

  @override
  String get hintOpen => 'open';

  @override
  String get hintOptions => 'options';

  @override
  String toastAdded(String name, String step) {
    return '$name: +$step';
  }

  @override
  String toastChecked(String name) {
    return '$name: done';
  }

  @override
  String toastUnchecked(String name) {
    return '$name: unmarked';
  }

  @override
  String get undo => 'Undo';

  @override
  String get toastArchived => 'Habit archived';

  @override
  String get emptyTitle => 'Your day is wide open';

  @override
  String get emptyBody =>
      'Start with one small, easy habit. We’ll take care of reminding you.';

  @override
  String get emptyCta => 'Create my first habit';

  @override
  String get emptyIdeas => 'or start with an idea';

  @override
  String get ideaWater => 'Drink 2 L';

  @override
  String get ideaRead => 'Read 10 pages';

  @override
  String get ideaMeditate => 'Meditate 5 min';

  @override
  String get close => 'Close';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get pauseHabit => 'Pause';

  @override
  String get pauseHint => 'holidays, illness…';

  @override
  String get pauseLength => 'Pause length';

  @override
  String get pause1Week => '1 wk';

  @override
  String get pause2Weeks => '2 wk';

  @override
  String get pause1Month => '1 month';

  @override
  String get pauseDates => 'Dates';

  @override
  String get pauseChosenDay => 'the day you choose';

  @override
  String pauseFrozen(String streak, String date) {
    return 'Your **$streak** streak is frozen. It resumes on **$date**, and no reminder will be sent until then.';
  }

  @override
  String get pauseConfirm => 'Pause';

  @override
  String get pauseActive => 'Pause on';

  @override
  String get archive => 'Archive';

  @override
  String get archiveHint => 'leaves Today, history is kept';

  @override
  String get delete => 'Delete';

  @override
  String deleteTitle(String name) {
    return 'Delete $name and its history?';
  }

  @override
  String get deleteBody => 'This can’t be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String weeksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '$count week',
    );
    return '$_temp0';
  }

  @override
  String valueSteps(String value, String goal) {
    return '$value / $goal steps';
  }

  @override
  String valueKm(String value, String goal) {
    return '$value / $goal km';
  }

  @override
  String stepSteps(String value) {
    return '$value steps';
  }

  @override
  String stepKm(String value) {
    return '$value km';
  }

  @override
  String stepOf(int step, int total) {
    return '$step/$total';
  }

  @override
  String stepProgress(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get back => 'Previous step';

  @override
  String get searchHint => 'Search or name a habit';

  @override
  String get popular => 'Popular';

  @override
  String get popularHint => 'type picked for you';

  @override
  String get orPickType => 'Or pick a type';

  @override
  String get habitType => 'Habit type';

  @override
  String get typeQuantity => 'Quantity';

  @override
  String get typeDuration => 'Duration';

  @override
  String get typeYesNo => 'Yes / no';

  @override
  String get typeJournal => 'Journal';

  @override
  String get typeFrequency => 'Frequency';

  @override
  String get typeQuantityEx => 'water, pages, steps, kilometres';

  @override
  String get typeDurationEx => 'meditate, draw, instrument';

  @override
  String get typeYesNoEx => 'vitamins, no screen in bed';

  @override
  String get typeJournalEx => 'write 3 lines, gratitude';

  @override
  String get typeFrequencyEx => 'sport 3 times, call someone close';

  @override
  String get popWater => 'Drink water';

  @override
  String get popRead => 'Read';

  @override
  String get popDraw => 'Draw';

  @override
  String get popRun => 'Run';

  @override
  String get popVitamins => 'Vitamins';

  @override
  String get popGratitude => 'Gratitude';

  @override
  String get popMeditate => 'Meditate';

  @override
  String continueWith(String name) {
    return 'Continue · $name';
  }

  @override
  String get continueLabel => 'Continue';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get previewLabel => 'Preview on Today';

  @override
  String get nameHint => 'Habit name';

  @override
  String get colorLabel => 'Colour';

  @override
  String get colorLilac => 'Lilac';

  @override
  String get colorLavender => 'Lavender';

  @override
  String get colorSky => 'Sky';

  @override
  String get colorLagoon => 'Lagoon';

  @override
  String get colorMint => 'Mint';

  @override
  String get colorPistachio => 'Pistachio';

  @override
  String get colorLemon => 'Lemon';

  @override
  String get colorApricot => 'Apricot';

  @override
  String get colorPeach => 'Peach';

  @override
  String get colorCoral => 'Coral';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorRaspberry => 'Raspberry';

  @override
  String get changeIcon => 'Change icon';

  @override
  String get goalPerDay => 'Daily goal';

  @override
  String get decreaseGoal => 'Decrease the goal';

  @override
  String get increaseGoal => 'Increase the goal';

  @override
  String get unitLabel => 'Unit';

  @override
  String get unitGlasses => 'Glasses';

  @override
  String get unitLiters => 'Litres';

  @override
  String get unitMl => 'ml';

  @override
  String get unitPages => 'Pages';

  @override
  String get unitSteps => 'Steps';

  @override
  String get unitKm => 'Km';

  @override
  String get unitTimes => 'Times';

  @override
  String wordGlasses(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'glasses',
      one: 'glass',
    );
    return '$_temp0';
  }

  @override
  String wordPages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pages',
      one: 'page',
    );
    return '$_temp0';
  }

  @override
  String get wordSteps => 'steps';

  @override
  String wordTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'times',
      one: 'time',
    );
    return '$_temp0';
  }

  @override
  String wordLines(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lines',
      one: 'line',
    );
    return '$_temp0';
  }

  @override
  String goalSubGlasses(String liters) {
    return 'of 25 cl, i.e. $liters L';
  }

  @override
  String goalSubVolume(String glasses, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i.e. $glasses glasses of 25 cl',
      one: 'i.e. $glasses glass of 25 cl',
    );
    return '$_temp0';
  }

  @override
  String get addBy => 'Add by';

  @override
  String get addByHint => 'quick button on Today';

  @override
  String get stepOther => 'Other';

  @override
  String get stepOtherTitle => 'Add how much per tap?';

  @override
  String get ok => 'OK';

  @override
  String get scheduleTitle => 'When?';

  @override
  String get rhythm => 'Rhythm';

  @override
  String get rhythmDays => 'Set days';

  @override
  String get rhythmWeekly => 'X times / week';

  @override
  String get activeDaysLabel => 'Active days';

  @override
  String dayActive(String day) {
    return '$day, active';
  }

  @override
  String dayRest(String day) {
    return '$day, rest';
  }

  @override
  String get daysHintAll => 'Every day, no rest.';

  @override
  String daysHint(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active days',
      one: '1 active day',
    );
    return '$_temp0 · rest on $days. These days don’t count towards the streak.';
  }

  @override
  String listAnd(String head, String last) {
    return '$head and $last';
  }

  @override
  String get fewer => 'Fewer';

  @override
  String get more => 'More';

  @override
  String get timesPerWeek => 'times a week';

  @override
  String get weeklyHint => 'Days without a session don’t break your streak.';

  @override
  String get momentTitle => 'Time of day';

  @override
  String get momentLabel => 'Moment';

  @override
  String get momentMorningShort => 'Morning';

  @override
  String get momentNoonShort => 'Noon';

  @override
  String get momentEveningShort => 'Evening';

  @override
  String get momentAnytimeShort => 'All day';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get addReminder => 'Add a reminder';

  @override
  String removeReminder(String time) {
    return 'Remove the $time reminder';
  }

  @override
  String get streakDanger => 'If the streak is at risk';

  @override
  String streakDangerHint(String time) {
    return 'a small reminder at $time';
  }

  @override
  String get streakDangerLabel => 'Reminder when the streak is at risk';

  @override
  String get createHabit => 'Create habit';

  @override
  String get saveHabit => 'Save';

  @override
  String get toastCreated => 'Habit created';

  @override
  String get toastSaved => 'Changes saved';

  @override
  String get premiumTitle => 'Little Steps Premium';

  @override
  String get premiumBody =>
      'The free plan holds 5 habits. Premium unlocks unlimited habits, full stats, themes and export.';

  @override
  String get premiumSoon => 'Coming soon';
}
