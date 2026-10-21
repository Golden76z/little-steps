// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Little Steps';

  @override
  String get tabToday => 'Aujourd’hui';

  @override
  String get tabProgress => 'Progrès';

  @override
  String get tabTrophies => 'Trophées';

  @override
  String get tabProfile => 'Profil';

  @override
  String get newHabit => 'Nouvelle habitude';

  @override
  String get mainNavigation => 'Navigation principale';

  @override
  String levelMonth(int level, String month) {
    return 'Niveau $level · $month';
  }

  @override
  String levelProgress(int level, String percent, int next) {
    return 'Niveau $level, $percent vers le niveau $next';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série de $count jours',
      one: 'Série de $count jour',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String get calendar => 'Calendrier';

  @override
  String get weekDays => 'Jours de la semaine';

  @override
  String get restToday => 'Repos aujourd’hui';

  @override
  String get restOnDay => 'Au repos';

  @override
  String get restDay => 'Jour de repos';

  @override
  String pausedUntil(String date) {
    return 'En pause jusqu’au $date';
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
      other: 'verres',
      one: 'verre',
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
    return '$value / $goal fois';
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
      other: 'lignes',
      one: 'ligne',
    );
    return '$value / $goal $_temp0';
  }

  @override
  String valueThisWeek(String value, String goal) {
    return '$value / $goal cette semaine';
  }

  @override
  String get doneLabel => 'C’est fait !';

  @override
  String get momentMorning => 'Ce matin';

  @override
  String get momentNoon => 'Ce midi';

  @override
  String get momentEvening => 'Ce soir';

  @override
  String get momentAnytime => 'Aujourd’hui';

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
      other: '$value verres',
      one: '$value verre',
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
    return '$value fois';
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
  String get pillDone => 'terminé';

  @override
  String hintAdd(String step) {
    return 'ajouter $step';
  }

  @override
  String get hintCheck => 'cocher';

  @override
  String get hintUncheck => 'décocher';

  @override
  String get hintStartTimer => 'lancer le minuteur';

  @override
  String get hintWrite => 'écrire';

  @override
  String get hintOpen => 'ouvrir';

  @override
  String get hintOptions => 'options';

  @override
  String toastAdded(String name, String step) {
    return '$name : +$step';
  }

  @override
  String toastChecked(String name) {
    return '$name : c’est fait';
  }

  @override
  String toastUnchecked(String name) {
    return '$name : décoché';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get toastArchived => 'Habitude archivée';

  @override
  String get emptyTitle => 'Ta journée est toute vide';

  @override
  String get emptyBody =>
      'Commence par une petite habitude facile. On s’occupe de te la rappeler.';

  @override
  String get emptyCta => 'Créer ma première habitude';

  @override
  String get emptyIdeas => 'ou commence avec une idée';

  @override
  String get ideaWater => 'Boire 2 L';

  @override
  String get ideaRead => 'Lire 10 pages';

  @override
  String get ideaMeditate => 'Méditer 5 min';

  @override
  String get close => 'Fermer';

  @override
  String get editHabit => 'Modifier l’habitude';

  @override
  String get pauseHabit => 'Mettre en pause';

  @override
  String get pauseHint => 'vacances, maladie…';

  @override
  String get pauseLength => 'Durée de la pause';

  @override
  String get pause1Week => '1 sem.';

  @override
  String get pause2Weeks => '2 sem.';

  @override
  String get pause1Month => '1 mois';

  @override
  String get pauseDates => 'Dates';

  @override
  String get pauseChosenDay => 'jour de ton choix';

  @override
  String pauseFrozen(String streak, String date) {
    return 'Ta série de **$streak** est gelée. Elle reprend le **$date**, et aucun rappel ne sera envoyé d’ici là.';
  }

  @override
  String get pauseConfirm => 'Mettre en pause';

  @override
  String get pauseActive => 'Pause activée';

  @override
  String get archive => 'Archiver';

  @override
  String get archiveHint => 'disparaît de l’accueil, l’historique est gardé';

  @override
  String get delete => 'Supprimer';

  @override
  String deleteTitle(String name) {
    return 'Supprimer $name et son historique ?';
  }

  @override
  String get deleteBody => 'C’est définitif.';

  @override
  String get cancel => 'Annuler';

  @override
  String weeksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semaines',
      one: '$count semaine',
    );
    return '$_temp0';
  }
}
