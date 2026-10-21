import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Little Steps'**
  String get appTitle;

  /// Bottom bar tab and Today screen title
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @tabTrophies.
  ///
  /// In en, this message translates to:
  /// **'Trophies'**
  String get tabTrophies;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// Accessibility label of the round + button, and title of the creation flow
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabit;

  /// Accessibility label of the floating bottom bar
  ///
  /// In en, this message translates to:
  /// **'Main navigation'**
  String get mainNavigation;

  /// No description provided for @levelMonth.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · {month}'**
  String levelMonth(int level, String month);

  /// No description provided for @levelProgress.
  ///
  /// In en, this message translates to:
  /// **'Level {level}, {percent} to level {next}'**
  String levelProgress(int level, String percent, int next);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count}-day streak} other{{count}-day streak}}'**
  String streakDays(int count);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @weekDays.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get weekDays;

  /// No description provided for @restToday.
  ///
  /// In en, this message translates to:
  /// **'Resting today'**
  String get restToday;

  /// No description provided for @restOnDay.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get restOnDay;

  /// No description provided for @restDay.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get restDay;

  /// No description provided for @pausedUntil.
  ///
  /// In en, this message translates to:
  /// **'Paused until {date}'**
  String pausedUntil(String date);

  /// No description provided for @valueLiters.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} L'**
  String valueLiters(String value, String goal);

  /// No description provided for @valueGlasses.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} {count, plural, one{glass} other{glasses}}'**
  String valueGlasses(String value, String goal, num count);

  /// No description provided for @valueMl.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} ml'**
  String valueMl(String value, String goal);

  /// No description provided for @valuePages.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} {count, plural, one{page} other{pages}}'**
  String valuePages(String value, String goal, num count);

  /// No description provided for @valueTimes.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} {count, plural, one{time} other{times}}'**
  String valueTimes(String value, String goal, num count);

  /// No description provided for @valueMinutes.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} min'**
  String valueMinutes(String value, String goal);

  /// No description provided for @valueLines.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} {count, plural, one{line} other{lines}}'**
  String valueLines(String value, String goal, num count);

  /// No description provided for @valueThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} this week'**
  String valueThisWeek(String value, String goal);

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get doneLabel;

  /// No description provided for @momentMorning.
  ///
  /// In en, this message translates to:
  /// **'This morning'**
  String get momentMorning;

  /// No description provided for @momentNoon.
  ///
  /// In en, this message translates to:
  /// **'At noon'**
  String get momentNoon;

  /// No description provided for @momentEvening.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get momentEvening;

  /// No description provided for @momentAnytime.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get momentAnytime;

  /// No description provided for @stepCl.
  ///
  /// In en, this message translates to:
  /// **'{value} cl'**
  String stepCl(String value);

  /// No description provided for @stepMl.
  ///
  /// In en, this message translates to:
  /// **'{value} ml'**
  String stepMl(String value);

  /// No description provided for @stepGlasses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{value} glass} other{{value} glasses}}'**
  String stepGlasses(String value, num count);

  /// No description provided for @stepPages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{value} page} other{{value} pages}}'**
  String stepPages(String value, num count);

  /// No description provided for @stepTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{value} time} other{{value} times}}'**
  String stepTimes(String value, num count);

  /// No description provided for @stepMinutes.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String stepMinutes(String value);

  /// No description provided for @pillLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, {percent}'**
  String pillLabel(String name, String percent);

  /// No description provided for @pillDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get pillDone;

  /// No description provided for @hintAdd.
  ///
  /// In en, this message translates to:
  /// **'add {step}'**
  String hintAdd(String step);

  /// No description provided for @hintCheck.
  ///
  /// In en, this message translates to:
  /// **'mark as done'**
  String get hintCheck;

  /// No description provided for @hintUncheck.
  ///
  /// In en, this message translates to:
  /// **'unmark'**
  String get hintUncheck;

  /// No description provided for @hintStartTimer.
  ///
  /// In en, this message translates to:
  /// **'start the timer'**
  String get hintStartTimer;

  /// No description provided for @hintWrite.
  ///
  /// In en, this message translates to:
  /// **'write'**
  String get hintWrite;

  /// No description provided for @hintOpen.
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get hintOpen;

  /// No description provided for @hintOptions.
  ///
  /// In en, this message translates to:
  /// **'options'**
  String get hintOptions;

  /// No description provided for @toastAdded.
  ///
  /// In en, this message translates to:
  /// **'{name}: +{step}'**
  String toastAdded(String name, String step);

  /// No description provided for @toastChecked.
  ///
  /// In en, this message translates to:
  /// **'{name}: done'**
  String toastChecked(String name);

  /// No description provided for @toastUnchecked.
  ///
  /// In en, this message translates to:
  /// **'{name}: unmarked'**
  String toastUnchecked(String name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @toastArchived.
  ///
  /// In en, this message translates to:
  /// **'Habit archived'**
  String get toastArchived;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day is wide open'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start with one small, easy habit. We’ll take care of reminding you.'**
  String get emptyBody;

  /// No description provided for @emptyCta.
  ///
  /// In en, this message translates to:
  /// **'Create my first habit'**
  String get emptyCta;

  /// No description provided for @emptyIdeas.
  ///
  /// In en, this message translates to:
  /// **'or start with an idea'**
  String get emptyIdeas;

  /// No description provided for @ideaWater.
  ///
  /// In en, this message translates to:
  /// **'Drink 2 L'**
  String get ideaWater;

  /// No description provided for @ideaRead.
  ///
  /// In en, this message translates to:
  /// **'Read 10 pages'**
  String get ideaRead;

  /// No description provided for @ideaMeditate.
  ///
  /// In en, this message translates to:
  /// **'Meditate 5 min'**
  String get ideaMeditate;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabit;

  /// No description provided for @pauseHabit.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseHabit;

  /// No description provided for @pauseHint.
  ///
  /// In en, this message translates to:
  /// **'holidays, illness…'**
  String get pauseHint;

  /// No description provided for @pauseLength.
  ///
  /// In en, this message translates to:
  /// **'Pause length'**
  String get pauseLength;

  /// No description provided for @pause1Week.
  ///
  /// In en, this message translates to:
  /// **'1 wk'**
  String get pause1Week;

  /// No description provided for @pause2Weeks.
  ///
  /// In en, this message translates to:
  /// **'2 wk'**
  String get pause2Weeks;

  /// No description provided for @pause1Month.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get pause1Month;

  /// No description provided for @pauseDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get pauseDates;

  /// No description provided for @pauseChosenDay.
  ///
  /// In en, this message translates to:
  /// **'the day you choose'**
  String get pauseChosenDay;

  /// No description provided for @pauseFrozen.
  ///
  /// In en, this message translates to:
  /// **'Your **{streak}** streak is frozen. It resumes on **{date}**, and no reminder will be sent until then.'**
  String pauseFrozen(String streak, String date);

  /// No description provided for @pauseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseConfirm;

  /// No description provided for @pauseActive.
  ///
  /// In en, this message translates to:
  /// **'Pause on'**
  String get pauseActive;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archiveHint.
  ///
  /// In en, this message translates to:
  /// **'leaves Today, history is kept'**
  String get archiveHint;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} and its history?'**
  String deleteTitle(String name);

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'This can’t be undone.'**
  String get deleteBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @weeksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} week} other{{count} weeks}}'**
  String weeksCount(int count);

  /// No description provided for @valueSteps.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} steps'**
  String valueSteps(String value, String goal);

  /// No description provided for @valueKm.
  ///
  /// In en, this message translates to:
  /// **'{value} / {goal} km'**
  String valueKm(String value, String goal);

  /// No description provided for @stepSteps.
  ///
  /// In en, this message translates to:
  /// **'{value} steps'**
  String stepSteps(String value);

  /// No description provided for @stepKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String stepKm(String value);

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'{step}/{total}'**
  String stepOf(int step, int total);

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepProgress(int step, int total);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get back;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search or name a habit'**
  String get searchHint;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @popularHint.
  ///
  /// In en, this message translates to:
  /// **'type picked for you'**
  String get popularHint;

  /// No description provided for @orPickType.
  ///
  /// In en, this message translates to:
  /// **'Or pick a type'**
  String get orPickType;

  /// No description provided for @habitType.
  ///
  /// In en, this message translates to:
  /// **'Habit type'**
  String get habitType;

  /// No description provided for @typeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get typeQuantity;

  /// No description provided for @typeDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get typeDuration;

  /// No description provided for @typeYesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes / no'**
  String get typeYesNo;

  /// No description provided for @typeJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get typeJournal;

  /// No description provided for @typeFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get typeFrequency;

  /// No description provided for @typeQuantityEx.
  ///
  /// In en, this message translates to:
  /// **'water, pages, steps, kilometres'**
  String get typeQuantityEx;

  /// No description provided for @typeDurationEx.
  ///
  /// In en, this message translates to:
  /// **'meditate, draw, instrument'**
  String get typeDurationEx;

  /// No description provided for @typeYesNoEx.
  ///
  /// In en, this message translates to:
  /// **'vitamins, no screen in bed'**
  String get typeYesNoEx;

  /// No description provided for @typeJournalEx.
  ///
  /// In en, this message translates to:
  /// **'write 3 lines, gratitude'**
  String get typeJournalEx;

  /// No description provided for @typeFrequencyEx.
  ///
  /// In en, this message translates to:
  /// **'sport 3 times, call someone close'**
  String get typeFrequencyEx;

  /// No description provided for @popWater.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get popWater;

  /// No description provided for @popRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get popRead;

  /// No description provided for @popDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get popDraw;

  /// No description provided for @popRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get popRun;

  /// No description provided for @popVitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get popVitamins;

  /// No description provided for @popGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get popGratitude;

  /// No description provided for @popMeditate.
  ///
  /// In en, this message translates to:
  /// **'Meditate'**
  String get popMeditate;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue · {name}'**
  String continueWith(String name);

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview on Today'**
  String get previewLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get nameHint;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colorLabel;

  /// No description provided for @colorLilac.
  ///
  /// In en, this message translates to:
  /// **'Lilac'**
  String get colorLilac;

  /// No description provided for @colorLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorLavender;

  /// No description provided for @colorSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get colorSky;

  /// No description provided for @colorLagoon.
  ///
  /// In en, this message translates to:
  /// **'Lagoon'**
  String get colorLagoon;

  /// No description provided for @colorMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get colorMint;

  /// No description provided for @colorPistachio.
  ///
  /// In en, this message translates to:
  /// **'Pistachio'**
  String get colorPistachio;

  /// No description provided for @colorLemon.
  ///
  /// In en, this message translates to:
  /// **'Lemon'**
  String get colorLemon;

  /// No description provided for @colorApricot.
  ///
  /// In en, this message translates to:
  /// **'Apricot'**
  String get colorApricot;

  /// No description provided for @colorPeach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get colorPeach;

  /// No description provided for @colorCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get colorCoral;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorRaspberry.
  ///
  /// In en, this message translates to:
  /// **'Raspberry'**
  String get colorRaspberry;

  /// No description provided for @changeIcon.
  ///
  /// In en, this message translates to:
  /// **'Change icon'**
  String get changeIcon;

  /// No description provided for @goalPerDay.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get goalPerDay;

  /// No description provided for @decreaseGoal.
  ///
  /// In en, this message translates to:
  /// **'Decrease the goal'**
  String get decreaseGoal;

  /// No description provided for @increaseGoal.
  ///
  /// In en, this message translates to:
  /// **'Increase the goal'**
  String get increaseGoal;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @unitGlasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get unitGlasses;

  /// No description provided for @unitLiters.
  ///
  /// In en, this message translates to:
  /// **'Litres'**
  String get unitLiters;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get unitPages;

  /// No description provided for @unitSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get unitSteps;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'Km'**
  String get unitKm;

  /// No description provided for @unitTimes.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get unitTimes;

  /// No description provided for @wordGlasses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{glass} other{glasses}}'**
  String wordGlasses(num count);

  /// No description provided for @wordPages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{page} other{pages}}'**
  String wordPages(num count);

  /// No description provided for @wordSteps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get wordSteps;

  /// No description provided for @wordTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{time} other{times}}'**
  String wordTimes(num count);

  /// No description provided for @wordLines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{line} other{lines}}'**
  String wordLines(num count);

  /// No description provided for @goalSubGlasses.
  ///
  /// In en, this message translates to:
  /// **'of 25 cl, i.e. {liters} L'**
  String goalSubGlasses(String liters);

  /// No description provided for @goalSubVolume.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{i.e. {glasses} glass of 25 cl} other{i.e. {glasses} glasses of 25 cl}}'**
  String goalSubVolume(String glasses, num count);

  /// No description provided for @addBy.
  ///
  /// In en, this message translates to:
  /// **'Add by'**
  String get addBy;

  /// No description provided for @addByHint.
  ///
  /// In en, this message translates to:
  /// **'quick button on Today'**
  String get addByHint;

  /// No description provided for @stepOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get stepOther;

  /// No description provided for @stepOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Add how much per tap?'**
  String get stepOtherTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get scheduleTitle;

  /// No description provided for @rhythm.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get rhythm;

  /// No description provided for @rhythmDays.
  ///
  /// In en, this message translates to:
  /// **'Set days'**
  String get rhythmDays;

  /// No description provided for @rhythmWeekly.
  ///
  /// In en, this message translates to:
  /// **'X times / week'**
  String get rhythmWeekly;

  /// No description provided for @activeDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDaysLabel;

  /// No description provided for @dayActive.
  ///
  /// In en, this message translates to:
  /// **'{day}, active'**
  String dayActive(String day);

  /// No description provided for @dayRest.
  ///
  /// In en, this message translates to:
  /// **'{day}, rest'**
  String dayRest(String day);

  /// No description provided for @daysHintAll.
  ///
  /// In en, this message translates to:
  /// **'Every day, no rest.'**
  String get daysHintAll;

  /// No description provided for @daysHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 active day} other{{count} active days}} · rest on {days}. These days don’t count towards the streak.'**
  String daysHint(int count, String days);

  /// No description provided for @listAnd.
  ///
  /// In en, this message translates to:
  /// **'{head} and {last}'**
  String listAnd(String head, String last);

  /// No description provided for @fewer.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get fewer;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @timesPerWeek.
  ///
  /// In en, this message translates to:
  /// **'times a week'**
  String get timesPerWeek;

  /// No description provided for @weeklyHint.
  ///
  /// In en, this message translates to:
  /// **'Days without a session don’t break your streak.'**
  String get weeklyHint;

  /// No description provided for @momentTitle.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get momentTitle;

  /// No description provided for @momentLabel.
  ///
  /// In en, this message translates to:
  /// **'Moment'**
  String get momentLabel;

  /// No description provided for @momentMorningShort.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get momentMorningShort;

  /// No description provided for @momentNoonShort.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get momentNoonShort;

  /// No description provided for @momentEveningShort.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get momentEveningShort;

  /// No description provided for @momentAnytimeShort.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get momentAnytimeShort;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add a reminder'**
  String get addReminder;

  /// No description provided for @removeReminder.
  ///
  /// In en, this message translates to:
  /// **'Remove the {time} reminder'**
  String removeReminder(String time);

  /// No description provided for @streakDanger.
  ///
  /// In en, this message translates to:
  /// **'If the streak is at risk'**
  String get streakDanger;

  /// No description provided for @streakDangerHint.
  ///
  /// In en, this message translates to:
  /// **'a small reminder at {time}'**
  String streakDangerHint(String time);

  /// No description provided for @streakDangerLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder when the streak is at risk'**
  String get streakDangerLabel;

  /// No description provided for @createHabit.
  ///
  /// In en, this message translates to:
  /// **'Create habit'**
  String get createHabit;

  /// No description provided for @saveHabit.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveHabit;

  /// No description provided for @toastCreated.
  ///
  /// In en, this message translates to:
  /// **'Habit created'**
  String get toastCreated;

  /// No description provided for @toastSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get toastSaved;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Little Steps Premium'**
  String get premiumTitle;

  /// No description provided for @premiumBody.
  ///
  /// In en, this message translates to:
  /// **'The free plan holds 5 habits. Premium unlocks unlimited habits, full stats, themes and export.'**
  String get premiumBody;

  /// No description provided for @premiumSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get premiumSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
