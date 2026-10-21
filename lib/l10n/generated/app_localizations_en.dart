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

  @override
  String get backLabel => 'Back';

  @override
  String get everyDay => 'every day';

  @override
  String get everyMorning => 'every morning';

  @override
  String get everyNoon => 'every noon';

  @override
  String get everyEvening => 'every evening';

  @override
  String timesAWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times a week',
      one: 'once a week',
    );
    return '$_temp0';
  }

  @override
  String fromTime(String time) {
    return 'from $time';
  }

  @override
  String get journalLabel => 'journal';

  @override
  String get statStreak => 'days in a row';

  @override
  String get statBest => 'best';

  @override
  String get statMonth => 'this month';

  @override
  String goalMetDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'goal met $count days',
      one: 'goal met 1 day',
    );
    return '$_temp0';
  }

  @override
  String calendarOf(String month) {
    return '$month calendar';
  }

  @override
  String bigOf(String goal) {
    return '/ $goal';
  }

  @override
  String litersOf(String value, String goal) {
    return '$value L of $goal L';
  }

  @override
  String glassesOf(String value, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$value glasses of 25 cl',
      one: '$value glass of 25 cl',
    );
    return '$_temp0';
  }

  @override
  String percentOfGoal(String percent) {
    return '$percent of the goal';
  }

  @override
  String get addByDetailHint => 'can be changed in the habit';

  @override
  String get displayedUnit => 'Displayed unit';

  @override
  String get amountAdded => 'Amount added';

  @override
  String removeStep(String step) {
    return 'Remove $step';
  }

  @override
  String get goalReached => 'Goal reached!';

  @override
  String get sessionLength => 'Session length';

  @override
  String get timerRunning => 'In progress…';

  @override
  String timerOf(String time) {
    return 'of $time';
  }

  @override
  String get sessionDone => 'Session complete!';

  @override
  String ringLabel(int minutes, int goal) {
    return '$minutes minutes of $goal';
  }

  @override
  String get restartTimer => 'Start over';

  @override
  String get startTimer => 'Start';

  @override
  String get pauseTimer => 'Pause';

  @override
  String get finishSession => 'End session';

  @override
  String alreadyDone(int minutes) {
    return 'Already done, log $minutes min';
  }

  @override
  String get thisWeek => 'This week';

  @override
  String weekTotal(String minutes) {
    return '$minutes min in total';
  }

  @override
  String get weekMinutesA11y => 'Minutes per day this week';

  @override
  String get currentStreak => 'Current streak';

  @override
  String unitDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String unitMornings(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mornings',
      one: 'morning',
    );
    return '$_temp0';
  }

  @override
  String unitNoons(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'noons',
      one: 'noon',
    );
    return '$_temp0';
  }

  @override
  String unitEvenings(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'evenings',
      one: 'evening',
    );
    return '$_temp0';
  }

  @override
  String inARow(String unit) {
    return '$unit in a row';
  }

  @override
  String bestLine(String best) {
    return 'best: $best';
  }

  @override
  String reminderAt(String time) {
    return 'reminder at $time';
  }

  @override
  String get iDidIt => 'I did it';

  @override
  String doneOf(String done, String unit, String total) {
    return '$done $unit of $total';
  }

  @override
  String get legendDone => 'Done';

  @override
  String get legendJoker => 'Joker';

  @override
  String get legendMissed => 'Missed';

  @override
  String jokerTip(String unit, String count) {
    return 'A missed $unit doesn’t erase your streak if you use a joker. You have **$count** left.';
  }

  @override
  String get periodLabel => 'Period';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get historyTab => 'History';

  @override
  String get viewLabel => 'View';

  @override
  String monthDoneA11y(String month) {
    return 'Days done in $month';
  }

  @override
  String get journalPrompt1 => 'What made you smile today?';

  @override
  String get journalPrompt2 => 'One thing you learned?';

  @override
  String get journalPrompt3 => 'What are you proud of today?';

  @override
  String get otherQuestion => 'Another question';

  @override
  String get journalHint => 'One line per idea…';

  @override
  String get moodTitle => 'Today’s mood';

  @override
  String get moodLabel => 'Mood';

  @override
  String get mood0 => 'Not great';

  @override
  String get mood1 => 'Meh';

  @override
  String get mood2 => 'Good';

  @override
  String get mood3 => 'Great';

  @override
  String get journalSave => 'Save';

  @override
  String get journalSaved => 'Saved!';

  @override
  String linesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more lines',
      one: '1 more line',
    );
    return '$_temp0';
  }

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$_temp0';
  }

  @override
  String get noEntries => 'Nothing written yet.';

  @override
  String sessionsOf(int count, int target) {
    return '$count / $target sessions';
  }

  @override
  String get weekGoalMet => 'Weekly goal reached, well done!';

  @override
  String sessionsLeft(int count, String lastDay, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more sessions',
      one: '1 more session',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 by $lastDay, $_temp1 left.';
  }

  @override
  String lastWeeks(int count) {
    return 'Last $count weeks';
  }

  @override
  String goalKept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'goal met $count times',
      one: 'goal met once',
    );
    return '$_temp0';
  }

  @override
  String weekShort(int week) {
    return 'W$week';
  }

  @override
  String get logSession => 'Log a session today';

  @override
  String get sessionLogged => 'Session logged today';

  @override
  String get weekSessionsA11y => 'This week’s sessions, day by day';

  @override
  String weeksA11y(int count) {
    return 'Sessions per week over $count weeks';
  }

  @override
  String get streakAtRisk => 'Your streak is at risk';

  @override
  String missedYesterday(String names, String streak) {
    return 'Yesterday you didn’t do **$names**. A joker keeps your **$streak** streak intact.';
  }

  @override
  String useJoker(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Use a joker · $count left',
      one: 'Use a joker · 1 left',
    );
    return '$_temp0';
  }

  @override
  String get letItGo => 'Let it go';

  @override
  String get jokerEarnHint => 'You earn a joker every 7 perfect days.';

  @override
  String get streakSaved => 'Streak saved!';

  @override
  String stillInARow(String streak, int jokers) {
    String _temp0 = intl.Intl.pluralLogic(
      jokers,
      locale: localeName,
      other: '$jokers jokers left.',
      one: '1 joker left.',
      zero: 'No joker left.',
    );
    return 'Still $streak in a row. $_temp0';
  }

  @override
  String get letsGo => 'Let’s go';

  @override
  String get freshStart => 'Starting from zero';

  @override
  String recordKept(String streak) {
    return 'Your $streak record stays in your trophies. Keep your jokers for another time.';
  }

  @override
  String get okay => 'OK';

  @override
  String get yesterdayShort => 'Yest.';

  @override
  String get todayShort => 'Today';

  @override
  String get previousPeriod => 'Previous period';

  @override
  String get nextPeriod => 'Next period';

  @override
  String pillsOf(String done, String total) {
    return '$done pills of $total';
  }

  @override
  String vsLastWeek(String delta) {
    return '$delta vs last week';
  }

  @override
  String vsLastMonth(String delta) {
    return '$delta vs last month';
  }

  @override
  String vsLastYear(String delta) {
    return '$delta vs last year';
  }

  @override
  String get byHabit => 'By habit';

  @override
  String get daysSucceeded => 'days done';

  @override
  String rateA11y(String list) {
    return 'Rate per period: $list';
  }

  @override
  String xpOf(String xp, String next) {
    return '$xp / $next XP';
  }

  @override
  String get categoryLabel => 'Category';

  @override
  String get badgesTab => 'Badges';

  @override
  String get challengesTab => 'Challenges';

  @override
  String get jokersLabel => 'streak jokers';

  @override
  String get bestStreakLabel => 'best streak';

  @override
  String daysShort(String count) {
    return '$count d';
  }

  @override
  String countOf(String count, String total) {
    return '$count of $total';
  }

  @override
  String get badgeFirstStep => 'First step';

  @override
  String get badgeStreak7 => '7 days';

  @override
  String get badgeEarlyBird => 'Early bird';

  @override
  String get badgeBookworm => 'Bookworm';

  @override
  String get badgeStreak30 => '30 days';

  @override
  String get badgeZen => 'Total zen';

  @override
  String get badgePerfectDay => 'Perfect day';

  @override
  String get badgePerfectWeek => 'Perfect week';

  @override
  String get badgeStreak100 => '100 days';

  @override
  String get badgeNightOwl => 'Night owl';

  @override
  String get badgeHydrated => 'Hydrated';

  @override
  String get badgeRescue => 'Rescue';

  @override
  String badgeEarned(String name) {
    return '$name, earned';
  }

  @override
  String badgeLocked(String name) {
    return '$name, locked';
  }

  @override
  String get weeklyChallenge => 'Challenge of the week';

  @override
  String xpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String challengeSevenDays(String name) {
    return '$name 7 days in a row';
  }

  @override
  String challengeGoalFive(String goal) {
    return '$goal, 5 days this week';
  }

  @override
  String challengeTimes(String name, String count) {
    return '$name $count times this week';
  }

  @override
  String get challengePerfectWeek => 'A perfect week';

  @override
  String challengeDaysLeft(String done, String target, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left days left',
      one: '1 day left',
    );
    return '$done days of $target · $_temp0';
  }

  @override
  String challengeDays(String done, String target) {
    return '$done days of $target';
  }

  @override
  String challengeSessions(String done, String target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$done sessions of $target',
      one: '$done session of $target',
    );
    return '$_temp0';
  }

  @override
  String challengePerfectDays(String done, String target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$done perfect days of $target',
      one: '$done perfect day of $target',
    );
    return '$_temp0';
  }

  @override
  String get challengeDone => 'Completed!';

  @override
  String get yourName => 'Your first name';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get settingsLabel => 'Settings';

  @override
  String get statSeries => 'streak';

  @override
  String get pillsFilled => 'pills filled';

  @override
  String get premiumCardTitle => 'Go Premium';

  @override
  String get premiumCardBody => 'Unlimited stats, themes and export';

  @override
  String get tryPremium => 'Try';

  @override
  String get noReminders => 'None';

  @override
  String get rowTheme => 'Theme';

  @override
  String get themeSorbet => 'Sorbet';

  @override
  String get rowDarkMode => 'Dark mode';

  @override
  String get soon => 'Soon';

  @override
  String get rowJokers => 'Streak jokers';

  @override
  String jokersLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
    );
    return '$_temp0';
  }

  @override
  String get rowExport => 'Export my data';

  @override
  String get csv => 'CSV';

  @override
  String get rowDayStart => 'Day starts at';

  @override
  String get dayStartHint =>
      'Until this hour, the night still counts for the day before.';

  @override
  String get noReminder => 'No reminder';

  @override
  String ratio(String a, String b) {
    return '$a / $b';
  }
}
