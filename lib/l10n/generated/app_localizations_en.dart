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
}
