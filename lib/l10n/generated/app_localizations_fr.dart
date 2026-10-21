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

  @override
  String valueSteps(String value, String goal) {
    return '$value / $goal pas';
  }

  @override
  String valueKm(String value, String goal) {
    return '$value / $goal km';
  }

  @override
  String stepSteps(String value) {
    return '$value pas';
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
    return 'Étape $step sur $total';
  }

  @override
  String get back => 'Étape précédente';

  @override
  String get searchHint => 'Rechercher ou nommer une habitude';

  @override
  String get popular => 'Populaires';

  @override
  String get popularHint => 'type choisi pour toi';

  @override
  String get orPickType => 'Ou choisis un type';

  @override
  String get habitType => 'Type d’habitude';

  @override
  String get typeQuantity => 'Quantité';

  @override
  String get typeDuration => 'Durée';

  @override
  String get typeYesNo => 'Oui / non';

  @override
  String get typeJournal => 'Journal';

  @override
  String get typeFrequency => 'Fréquence';

  @override
  String get typeQuantityEx => 'eau, pages, pas, kilomètres';

  @override
  String get typeDurationEx => 'méditer, dessiner, instrument';

  @override
  String get typeYesNoEx => 'vitamines, pas d’écran au lit';

  @override
  String get typeJournalEx => 'écrire 3 lignes, gratitude';

  @override
  String get typeFrequencyEx => 'sport 3 fois, appeler un proche';

  @override
  String get popWater => 'Boire de l’eau';

  @override
  String get popRead => 'Lire';

  @override
  String get popDraw => 'Dessiner';

  @override
  String get popRun => 'Courir';

  @override
  String get popVitamins => 'Vitamines';

  @override
  String get popGratitude => 'Gratitude';

  @override
  String get popMeditate => 'Méditer';

  @override
  String continueWith(String name) {
    return 'Continuer · $name';
  }

  @override
  String get continueLabel => 'Continuer';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get previewLabel => 'Aperçu sur l’accueil';

  @override
  String get nameHint => 'Nom de l’habitude';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get colorLilac => 'Lilas';

  @override
  String get colorLavender => 'Lavande';

  @override
  String get colorSky => 'Ciel';

  @override
  String get colorLagoon => 'Lagon';

  @override
  String get colorMint => 'Menthe';

  @override
  String get colorPistachio => 'Pistache';

  @override
  String get colorLemon => 'Citron';

  @override
  String get colorApricot => 'Abricot';

  @override
  String get colorPeach => 'Pêche';

  @override
  String get colorCoral => 'Corail';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorRaspberry => 'Framboise';

  @override
  String get changeIcon => 'Changer l’icône';

  @override
  String get goalPerDay => 'Objectif par jour';

  @override
  String get decreaseGoal => 'Diminuer l’objectif';

  @override
  String get increaseGoal => 'Augmenter l’objectif';

  @override
  String get unitLabel => 'Unité';

  @override
  String get unitGlasses => 'Verres';

  @override
  String get unitLiters => 'Litres';

  @override
  String get unitMl => 'ml';

  @override
  String get unitPages => 'Pages';

  @override
  String get unitSteps => 'Pas';

  @override
  String get unitKm => 'Km';

  @override
  String get unitTimes => 'Fois';

  @override
  String wordGlasses(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'verres',
      one: 'verre',
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
  String get wordSteps => 'pas';

  @override
  String wordTimes(num count) {
    return 'fois';
  }

  @override
  String wordLines(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lignes',
      one: 'ligne',
    );
    return '$_temp0';
  }

  @override
  String goalSubGlasses(String liters) {
    return 'de 25 cl, soit $liters L';
  }

  @override
  String goalSubVolume(String glasses, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'soit $glasses verres de 25 cl',
      one: 'soit $glasses verre de 25 cl',
    );
    return '$_temp0';
  }

  @override
  String get addBy => 'Ajouter par';

  @override
  String get addByHint => 'bouton rapide de l’accueil';

  @override
  String get stepOther => 'Autre';

  @override
  String get stepOtherTitle => 'Ajouter combien par tap ?';

  @override
  String get ok => 'OK';

  @override
  String get scheduleTitle => 'Quand ?';

  @override
  String get rhythm => 'Rythme';

  @override
  String get rhythmDays => 'Jours précis';

  @override
  String get rhythmWeekly => 'X fois / semaine';

  @override
  String get activeDaysLabel => 'Jours actifs';

  @override
  String dayActive(String day) {
    return '$day, actif';
  }

  @override
  String dayRest(String day) {
    return '$day, repos';
  }

  @override
  String get daysHintAll => 'Tous les jours, sans repos.';

  @override
  String daysHint(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours actifs',
      one: '1 jour actif',
    );
    return '$_temp0 · repos le $days. Ces jours-là ne comptent pas dans la série.';
  }

  @override
  String listAnd(String head, String last) {
    return '$head et $last';
  }

  @override
  String get fewer => 'Moins';

  @override
  String get more => 'Plus';

  @override
  String get timesPerWeek => 'fois par semaine';

  @override
  String get weeklyHint => 'Les jours sans séance ne cassent pas ta série.';

  @override
  String get momentTitle => 'Moment de la journée';

  @override
  String get momentLabel => 'Moment';

  @override
  String get momentMorningShort => 'Matin';

  @override
  String get momentNoonShort => 'Midi';

  @override
  String get momentEveningShort => 'Soir';

  @override
  String get momentAnytimeShort => 'Journée';

  @override
  String get remindersTitle => 'Rappels';

  @override
  String get addReminder => 'Ajouter un rappel';

  @override
  String removeReminder(String time) {
    return 'Retirer le rappel de $time';
  }

  @override
  String get streakDanger => 'Si la série est en danger';

  @override
  String streakDangerHint(String time) {
    return 'un petit rappel à $time';
  }

  @override
  String get streakDangerLabel => 'Rappel si la série est en danger';

  @override
  String get createHabit => 'Créer l’habitude';

  @override
  String get saveHabit => 'Enregistrer';

  @override
  String get toastCreated => 'Habitude créée';

  @override
  String get toastSaved => 'Modifications enregistrées';

  @override
  String get premiumTitle => 'Little Steps Premium';

  @override
  String get premiumBody =>
      'L’offre gratuite compte 5 habitudes. Premium débloque les habitudes illimitées, les stats complètes, les thèmes et l’export.';

  @override
  String get premiumSoon => 'Bientôt disponible';
}
