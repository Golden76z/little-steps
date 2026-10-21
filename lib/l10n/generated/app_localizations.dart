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
