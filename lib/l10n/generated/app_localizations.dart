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

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'every day'**
  String get everyDay;

  /// No description provided for @everyMorning.
  ///
  /// In en, this message translates to:
  /// **'every morning'**
  String get everyMorning;

  /// No description provided for @everyNoon.
  ///
  /// In en, this message translates to:
  /// **'every noon'**
  String get everyNoon;

  /// No description provided for @everyEvening.
  ///
  /// In en, this message translates to:
  /// **'every evening'**
  String get everyEvening;

  /// No description provided for @timesAWeek.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{once a week} other{{count} times a week}}'**
  String timesAWeek(int count);

  /// No description provided for @fromTime.
  ///
  /// In en, this message translates to:
  /// **'from {time}'**
  String fromTime(String time);

  /// No description provided for @journalLabel.
  ///
  /// In en, this message translates to:
  /// **'journal'**
  String get journalLabel;

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'days in a row'**
  String get statStreak;

  /// No description provided for @statBest.
  ///
  /// In en, this message translates to:
  /// **'best'**
  String get statBest;

  /// No description provided for @statMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get statMonth;

  /// No description provided for @goalMetDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{goal met 1 day} other{goal met {count} days}}'**
  String goalMetDays(int count);

  /// No description provided for @calendarOf.
  ///
  /// In en, this message translates to:
  /// **'{month} calendar'**
  String calendarOf(String month);

  /// No description provided for @bigOf.
  ///
  /// In en, this message translates to:
  /// **'/ {goal}'**
  String bigOf(String goal);

  /// No description provided for @litersOf.
  ///
  /// In en, this message translates to:
  /// **'{value} L of {goal} L'**
  String litersOf(String value, String goal);

  /// No description provided for @glassesOf.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{value} glass of 25 cl} other{{value} glasses of 25 cl}}'**
  String glassesOf(String value, num count);

  /// No description provided for @percentOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{percent} of the goal'**
  String percentOfGoal(String percent);

  /// No description provided for @addByDetailHint.
  ///
  /// In en, this message translates to:
  /// **'can be changed in the habit'**
  String get addByDetailHint;

  /// No description provided for @displayedUnit.
  ///
  /// In en, this message translates to:
  /// **'Displayed unit'**
  String get displayedUnit;

  /// No description provided for @amountAdded.
  ///
  /// In en, this message translates to:
  /// **'Amount added'**
  String get amountAdded;

  /// No description provided for @removeStep.
  ///
  /// In en, this message translates to:
  /// **'Remove {step}'**
  String removeStep(String step);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get goalReached;

  /// No description provided for @sessionLength.
  ///
  /// In en, this message translates to:
  /// **'Session length'**
  String get sessionLength;

  /// No description provided for @timerRunning.
  ///
  /// In en, this message translates to:
  /// **'In progress…'**
  String get timerRunning;

  /// No description provided for @timerOf.
  ///
  /// In en, this message translates to:
  /// **'of {time}'**
  String timerOf(String time);

  /// No description provided for @sessionDone.
  ///
  /// In en, this message translates to:
  /// **'Session complete!'**
  String get sessionDone;

  /// No description provided for @ringLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes of {goal}'**
  String ringLabel(int minutes, int goal);

  /// No description provided for @restartTimer.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get restartTimer;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTimer;

  /// No description provided for @pauseTimer.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTimer;

  /// No description provided for @finishSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get finishSession;

  /// No description provided for @alreadyDone.
  ///
  /// In en, this message translates to:
  /// **'Already done, log {minutes} min'**
  String alreadyDone(int minutes);

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @weekTotal.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min in total'**
  String weekTotal(String minutes);

  /// No description provided for @weekMinutesA11y.
  ///
  /// In en, this message translates to:
  /// **'Minutes per day this week'**
  String get weekMinutesA11y;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{day} other{days}}'**
  String unitDays(num count);

  /// No description provided for @unitMornings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{morning} other{mornings}}'**
  String unitMornings(num count);

  /// No description provided for @unitNoons.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{noon} other{noons}}'**
  String unitNoons(num count);

  /// No description provided for @unitEvenings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{evening} other{evenings}}'**
  String unitEvenings(num count);

  /// No description provided for @inARow.
  ///
  /// In en, this message translates to:
  /// **'{unit} in a row'**
  String inARow(String unit);

  /// No description provided for @bestLine.
  ///
  /// In en, this message translates to:
  /// **'best: {best}'**
  String bestLine(String best);

  /// No description provided for @reminderAt.
  ///
  /// In en, this message translates to:
  /// **'reminder at {time}'**
  String reminderAt(String time);

  /// No description provided for @iDidIt.
  ///
  /// In en, this message translates to:
  /// **'I did it'**
  String get iDidIt;

  /// No description provided for @doneOf.
  ///
  /// In en, this message translates to:
  /// **'{done} {unit} of {total}'**
  String doneOf(String done, String unit, String total);

  /// No description provided for @legendDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get legendDone;

  /// No description provided for @legendJoker.
  ///
  /// In en, this message translates to:
  /// **'Joker'**
  String get legendJoker;

  /// No description provided for @legendMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get legendMissed;

  /// No description provided for @jokerTip.
  ///
  /// In en, this message translates to:
  /// **'A missed {unit} doesn’t erase your streak if you use a joker. You have **{count}** left.'**
  String jokerTip(String unit, String count);

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodLabel;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @viewLabel.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewLabel;

  /// No description provided for @monthDoneA11y.
  ///
  /// In en, this message translates to:
  /// **'Days done in {month}'**
  String monthDoneA11y(String month);

  /// No description provided for @journalPrompt1.
  ///
  /// In en, this message translates to:
  /// **'What made you smile today?'**
  String get journalPrompt1;

  /// No description provided for @journalPrompt2.
  ///
  /// In en, this message translates to:
  /// **'One thing you learned?'**
  String get journalPrompt2;

  /// No description provided for @journalPrompt3.
  ///
  /// In en, this message translates to:
  /// **'What are you proud of today?'**
  String get journalPrompt3;

  /// No description provided for @otherQuestion.
  ///
  /// In en, this message translates to:
  /// **'Another question'**
  String get otherQuestion;

  /// No description provided for @journalHint.
  ///
  /// In en, this message translates to:
  /// **'One line per idea…'**
  String get journalHint;

  /// No description provided for @moodTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s mood'**
  String get moodTitle;

  /// No description provided for @moodLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodLabel;

  /// No description provided for @mood0.
  ///
  /// In en, this message translates to:
  /// **'Not great'**
  String get mood0;

  /// No description provided for @mood1.
  ///
  /// In en, this message translates to:
  /// **'Meh'**
  String get mood1;

  /// No description provided for @mood2.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get mood2;

  /// No description provided for @mood3.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get mood3;

  /// No description provided for @journalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get journalSave;

  /// No description provided for @journalSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get journalSaved;

  /// No description provided for @linesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 more line} other{{count} more lines}}'**
  String linesLeft(int count);

  /// No description provided for @linesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 line} other{{count} lines}}'**
  String linesCount(int count);

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'Nothing written yet.'**
  String get noEntries;

  /// No description provided for @sessionsOf.
  ///
  /// In en, this message translates to:
  /// **'{count} / {target} sessions'**
  String sessionsOf(int count, int target);

  /// No description provided for @weekGoalMet.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal reached, well done!'**
  String get weekGoalMet;

  /// No description provided for @sessionsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 more session} other{{count} more sessions}} by {lastDay}, {days, plural, one{1 day} other{{days} days}} left.'**
  String sessionsLeft(int count, String lastDay, int days);

  /// No description provided for @lastWeeks.
  ///
  /// In en, this message translates to:
  /// **'Last {count} weeks'**
  String lastWeeks(int count);

  /// No description provided for @goalKept.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{goal met once} other{goal met {count} times}}'**
  String goalKept(int count);

  /// No description provided for @weekShort.
  ///
  /// In en, this message translates to:
  /// **'W{week}'**
  String weekShort(int week);

  /// No description provided for @logSession.
  ///
  /// In en, this message translates to:
  /// **'Log a session today'**
  String get logSession;

  /// No description provided for @sessionLogged.
  ///
  /// In en, this message translates to:
  /// **'Session logged today'**
  String get sessionLogged;

  /// No description provided for @weekSessionsA11y.
  ///
  /// In en, this message translates to:
  /// **'This week’s sessions, day by day'**
  String get weekSessionsA11y;

  /// No description provided for @weeksA11y.
  ///
  /// In en, this message translates to:
  /// **'Sessions per week over {count} weeks'**
  String weeksA11y(int count);

  /// No description provided for @streakAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Your streak is at risk'**
  String get streakAtRisk;

  /// No description provided for @missedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday you didn’t do **{names}**. A joker keeps your **{streak}** streak intact.'**
  String missedYesterday(String names, String streak);

  /// No description provided for @useJoker.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Use a joker · 1 left} other{Use a joker · {count} left}}'**
  String useJoker(int count);

  /// No description provided for @letItGo.
  ///
  /// In en, this message translates to:
  /// **'Let it go'**
  String get letItGo;

  /// No description provided for @jokerEarnHint.
  ///
  /// In en, this message translates to:
  /// **'You earn a joker every 7 perfect days.'**
  String get jokerEarnHint;

  /// No description provided for @streakSaved.
  ///
  /// In en, this message translates to:
  /// **'Streak saved!'**
  String get streakSaved;

  /// No description provided for @stillInARow.
  ///
  /// In en, this message translates to:
  /// **'Still {streak} in a row. {jokers, plural, =0{No joker left.} one{1 joker left.} other{{jokers} jokers left.}}'**
  String stillInARow(String streak, int jokers);

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let’s go'**
  String get letsGo;

  /// No description provided for @freshStart.
  ///
  /// In en, this message translates to:
  /// **'Starting from zero'**
  String get freshStart;

  /// No description provided for @recordKept.
  ///
  /// In en, this message translates to:
  /// **'Your {streak} record stays in your trophies. Keep your jokers for another time.'**
  String recordKept(String streak);

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okay;

  /// No description provided for @yesterdayShort.
  ///
  /// In en, this message translates to:
  /// **'Yest.'**
  String get yesterdayShort;

  /// No description provided for @todayShort.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayShort;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriod;

  /// No description provided for @pillsOf.
  ///
  /// In en, this message translates to:
  /// **'{done} pills of {total}'**
  String pillsOf(String done, String total);

  /// No description provided for @vsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last week'**
  String vsLastWeek(String delta);

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last month'**
  String vsLastMonth(String delta);

  /// No description provided for @vsLastYear.
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last year'**
  String vsLastYear(String delta);

  /// No description provided for @byHabit.
  ///
  /// In en, this message translates to:
  /// **'By habit'**
  String get byHabit;

  /// No description provided for @daysSucceeded.
  ///
  /// In en, this message translates to:
  /// **'days done'**
  String get daysSucceeded;

  /// No description provided for @rateA11y.
  ///
  /// In en, this message translates to:
  /// **'Rate per period: {list}'**
  String rateA11y(String list);

  /// No description provided for @xpOf.
  ///
  /// In en, this message translates to:
  /// **'{xp} / {next} XP'**
  String xpOf(String xp, String next);

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @badgesTab.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesTab;

  /// No description provided for @challengesTab.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengesTab;

  /// No description provided for @jokersLabel.
  ///
  /// In en, this message translates to:
  /// **'streak jokers'**
  String get jokersLabel;

  /// No description provided for @bestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'best streak'**
  String get bestStreakLabel;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'{count} d'**
  String daysShort(String count);

  /// No description provided for @countOf.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total}'**
  String countOf(String count, String total);

  /// No description provided for @badgeFirstStep.
  ///
  /// In en, this message translates to:
  /// **'First step'**
  String get badgeFirstStep;

  /// No description provided for @badgeStreak7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get badgeStreak7;

  /// No description provided for @badgeEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early bird'**
  String get badgeEarlyBird;

  /// No description provided for @badgeBookworm.
  ///
  /// In en, this message translates to:
  /// **'Bookworm'**
  String get badgeBookworm;

  /// No description provided for @badgeStreak30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get badgeStreak30;

  /// No description provided for @badgeZen.
  ///
  /// In en, this message translates to:
  /// **'Total zen'**
  String get badgeZen;

  /// No description provided for @badgePerfectDay.
  ///
  /// In en, this message translates to:
  /// **'Perfect day'**
  String get badgePerfectDay;

  /// No description provided for @badgePerfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Perfect week'**
  String get badgePerfectWeek;

  /// No description provided for @badgeStreak100.
  ///
  /// In en, this message translates to:
  /// **'100 days'**
  String get badgeStreak100;

  /// No description provided for @badgeNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Night owl'**
  String get badgeNightOwl;

  /// No description provided for @badgeHydrated.
  ///
  /// In en, this message translates to:
  /// **'Hydrated'**
  String get badgeHydrated;

  /// No description provided for @badgeRescue.
  ///
  /// In en, this message translates to:
  /// **'Rescue'**
  String get badgeRescue;

  /// No description provided for @badgeEarned.
  ///
  /// In en, this message translates to:
  /// **'{name}, earned'**
  String badgeEarned(String name);

  /// No description provided for @badgeLocked.
  ///
  /// In en, this message translates to:
  /// **'{name}, locked'**
  String badgeLocked(String name);

  /// No description provided for @weeklyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge of the week'**
  String get weeklyChallenge;

  /// No description provided for @xpReward.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpReward(String xp);

  /// No description provided for @challengeSevenDays.
  ///
  /// In en, this message translates to:
  /// **'{name} 7 days in a row'**
  String challengeSevenDays(String name);

  /// No description provided for @challengeGoalFive.
  ///
  /// In en, this message translates to:
  /// **'{goal}, 5 days this week'**
  String challengeGoalFive(String goal);

  /// No description provided for @challengeTimes.
  ///
  /// In en, this message translates to:
  /// **'{name} {count} times this week'**
  String challengeTimes(String name, String count);

  /// No description provided for @challengePerfectWeek.
  ///
  /// In en, this message translates to:
  /// **'A perfect week'**
  String get challengePerfectWeek;

  /// No description provided for @challengeDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{done} days of {target} · {left, plural, one{1 day left} other{{left} days left}}'**
  String challengeDaysLeft(String done, String target, int left);

  /// No description provided for @challengeDays.
  ///
  /// In en, this message translates to:
  /// **'{done} days of {target}'**
  String challengeDays(String done, String target);

  /// No description provided for @challengeSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{done} session of {target}} other{{done} sessions of {target}}}'**
  String challengeSessions(String done, String target, int count);

  /// No description provided for @challengePerfectDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{done} perfect day of {target}} other{{done} perfect days of {target}}}'**
  String challengePerfectDays(String done, String target, int count);

  /// No description provided for @challengeDone.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get challengeDone;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get yourName;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @statSeries.
  ///
  /// In en, this message translates to:
  /// **'streak'**
  String get statSeries;

  /// No description provided for @pillsFilled.
  ///
  /// In en, this message translates to:
  /// **'pills filled'**
  String get pillsFilled;

  /// No description provided for @premiumCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get premiumCardTitle;

  /// No description provided for @premiumCardBody.
  ///
  /// In en, this message translates to:
  /// **'Unlimited stats, themes and export'**
  String get premiumCardBody;

  /// No description provided for @tryPremium.
  ///
  /// In en, this message translates to:
  /// **'Try'**
  String get tryPremium;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noReminders;

  /// No description provided for @rowTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get rowTheme;

  /// No description provided for @themeSorbet.
  ///
  /// In en, this message translates to:
  /// **'Sorbet'**
  String get themeSorbet;

  /// No description provided for @rowDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get rowDarkMode;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @rowJokers.
  ///
  /// In en, this message translates to:
  /// **'Streak jokers'**
  String get rowJokers;

  /// No description provided for @jokersLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 left} other{{count} left}}'**
  String jokersLeft(int count);

  /// No description provided for @rowExport.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get rowExport;

  /// No description provided for @csv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csv;

  /// No description provided for @rowDayStart.
  ///
  /// In en, this message translates to:
  /// **'Day starts at'**
  String get rowDayStart;

  /// No description provided for @dayStartHint.
  ///
  /// In en, this message translates to:
  /// **'Until this hour, the night still counts for the day before.'**
  String get dayStartHint;

  /// No description provided for @noReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get noReminder;

  /// No description provided for @ratio.
  ///
  /// In en, this message translates to:
  /// **'{a} / {b}'**
  String ratio(String a, String b);

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Habit reminders and streak alerts'**
  String get notifChannelDescription;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'A little step now?'**
  String get reminderBody;

  /// No description provided for @dangerBody.
  ///
  /// In en, this message translates to:
  /// **'Still {names} today to keep your flame going.'**
  String dangerBody(String names);

  /// No description provided for @remindersSummary.
  ///
  /// In en, this message translates to:
  /// **'{habits, plural, one{{habits} habit} other{{habits} habits}} · {reminders, plural, one{{reminders} reminder} other{{reminders} reminders}}'**
  String remindersSummary(int habits, int reminders);
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
