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
      one: '$count jour actif',
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

  @override
  String get backLabel => 'Retour';

  @override
  String get everyDay => 'chaque jour';

  @override
  String get everyMorning => 'chaque matin';

  @override
  String get everyNoon => 'chaque midi';

  @override
  String get everyEvening => 'chaque soir';

  @override
  String timesAWeek(int count) {
    return '$count fois par semaine';
  }

  @override
  String fromTime(String time) {
    return 'dès $time';
  }

  @override
  String get journalLabel => 'journal';

  @override
  String get statStreak => 'jours de suite';

  @override
  String get statBest => 'record';

  @override
  String get statMonth => 'ce mois-ci';

  @override
  String goalMetDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'objectif atteint $count jours',
      one: 'objectif atteint $count jour',
    );
    return '$_temp0';
  }

  @override
  String calendarOf(String month) {
    return 'Calendrier de $month';
  }

  @override
  String bigOf(String goal) {
    return '/ $goal';
  }

  @override
  String litersOf(String value, String goal) {
    return '$value L sur $goal L';
  }

  @override
  String glassesOf(String value, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$value verres de 25 cl',
      one: '$value verre de 25 cl',
    );
    return '$_temp0';
  }

  @override
  String percentOfGoal(String percent) {
    return '$percent de l’objectif';
  }

  @override
  String get addByDetailHint => 'réglable dans l’habitude';

  @override
  String get displayedUnit => 'Unité affichée';

  @override
  String get amountAdded => 'Quantité ajoutée';

  @override
  String removeStep(String step) {
    return 'Retirer $step';
  }

  @override
  String get goalReached => 'Objectif atteint !';

  @override
  String get sessionLength => 'Durée de la séance';

  @override
  String get timerRunning => 'En cours…';

  @override
  String timerOf(String time) {
    return 'sur $time';
  }

  @override
  String get sessionDone => 'Séance terminée !';

  @override
  String ringLabel(int minutes, int goal) {
    return '$minutes minutes sur $goal';
  }

  @override
  String get restartTimer => 'Recommencer';

  @override
  String get startTimer => 'Démarrer';

  @override
  String get pauseTimer => 'Mettre en pause';

  @override
  String get finishSession => 'Terminer la séance';

  @override
  String alreadyDone(int minutes) {
    return 'Déjà fait, noter $minutes min';
  }

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String weekTotal(String minutes) {
    return '$minutes min au total';
  }

  @override
  String get weekMinutesA11y => 'Minutes par jour cette semaine';

  @override
  String get currentStreak => 'Série en cours';

  @override
  String unitDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return '$_temp0';
  }

  @override
  String unitMornings(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'matins',
      one: 'matin',
    );
    return '$_temp0';
  }

  @override
  String unitNoons(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'midis',
      one: 'midi',
    );
    return '$_temp0';
  }

  @override
  String unitEvenings(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'soirs',
      one: 'soir',
    );
    return '$_temp0';
  }

  @override
  String inARow(String unit) {
    return '$unit de suite';
  }

  @override
  String bestLine(String best) {
    return 'record : $best';
  }

  @override
  String reminderAt(String time) {
    return 'rappel à $time';
  }

  @override
  String get iDidIt => 'Je l’ai fait';

  @override
  String doneOf(String done, String unit, String total) {
    return '$done $unit sur $total';
  }

  @override
  String get legendDone => 'Fait';

  @override
  String get legendJoker => 'Joker';

  @override
  String get legendMissed => 'Raté';

  @override
  String jokerTip(String unit, String count) {
    return 'Un $unit raté n’efface pas ta série si tu utilises un joker. Il t’en reste **$count**.';
  }

  @override
  String get periodLabel => 'Période';

  @override
  String get periodWeek => 'Semaine';

  @override
  String get periodMonth => 'Mois';

  @override
  String get periodYear => 'Année';

  @override
  String get historyTab => 'Historique';

  @override
  String get viewLabel => 'Vue';

  @override
  String monthDoneA11y(String month) {
    return 'Jours réussis en $month';
  }

  @override
  String get journalPrompt1 => 'Qu’est-ce qui t’a fait sourire aujourd’hui ?';

  @override
  String get journalPrompt2 => 'Une chose que tu as apprise ?';

  @override
  String get journalPrompt3 => 'De quoi es-tu fier·e aujourd’hui ?';

  @override
  String get otherQuestion => 'Autre question';

  @override
  String get journalHint => 'Une ligne par idée…';

  @override
  String get moodTitle => 'Humeur du jour';

  @override
  String get moodLabel => 'Humeur';

  @override
  String get mood0 => 'Pas terrible';

  @override
  String get mood1 => 'Bof';

  @override
  String get mood2 => 'Bien';

  @override
  String get mood3 => 'Super';

  @override
  String get journalSave => 'Enregistrer';

  @override
  String get journalSaved => 'Enregistré !';

  @override
  String linesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count lignes',
      one: 'Encore $count ligne',
    );
    return '$_temp0';
  }

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes',
      one: '$count ligne',
    );
    return '$_temp0';
  }

  @override
  String get noEntries => 'Rien d’écrit pour l’instant.';

  @override
  String sessionsOf(int count, int target) {
    return '$count / $target séances';
  }

  @override
  String get weekGoalMet => 'Objectif de la semaine atteint, bravo !';

  @override
  String sessionsLeft(int count, String lastDay, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count séances',
      one: 'Encore $count séance',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'il te reste $days jours',
      one: 'il te reste $days jour',
    );
    return '$_temp0 d’ici $lastDay, $_temp1.';
  }

  @override
  String lastWeeks(int count) {
    return '$count dernières semaines';
  }

  @override
  String goalKept(int count) {
    return 'objectif tenu $count fois';
  }

  @override
  String weekShort(int week) {
    return 'S$week';
  }

  @override
  String get logSession => 'Noter une séance aujourd’hui';

  @override
  String get sessionLogged => 'Séance notée aujourd’hui';

  @override
  String get weekSessionsA11y => 'Séances de la semaine, jour par jour';

  @override
  String weeksA11y(int count) {
    return 'Séances par semaine sur $count semaines';
  }

  @override
  String get streakAtRisk => 'Ta série est en danger';

  @override
  String missedYesterday(String names, String streak) {
    return 'Hier, tu n’as pas fait **$names**. Un joker garde ta série de **$streak** intacte.';
  }

  @override
  String useJoker(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Utiliser un joker · $count restants',
      one: 'Utiliser un joker · $count restant',
    );
    return '$_temp0';
  }

  @override
  String get letItGo => 'Laisser passer';

  @override
  String get jokerEarnHint => 'Tu gagnes un joker tous les 7 jours parfaits.';

  @override
  String get streakSaved => 'Série sauvée !';

  @override
  String stillInARow(String streak, int jokers) {
    String _temp0 = intl.Intl.pluralLogic(
      jokers,
      locale: localeName,
      other: 'Il te reste $jokers jokers.',
      one: 'Il te reste $jokers joker.',
      zero: 'Il ne te reste plus de joker.',
    );
    return 'Toujours $streak de suite. $_temp0';
  }

  @override
  String get letsGo => 'C’est reparti';

  @override
  String get freshStart => 'On repart de zéro';

  @override
  String recordKept(String streak) {
    return 'Ton record de $streak reste dans tes trophées. Garde tes jokers pour une autre fois.';
  }

  @override
  String get okay => 'D’accord';

  @override
  String get yesterdayShort => 'Hier';

  @override
  String get todayShort => 'Auj.';

  @override
  String get previousPeriod => 'Période précédente';

  @override
  String get nextPeriod => 'Période suivante';

  @override
  String pillsOf(String done, String total) {
    return '$done pilules sur $total';
  }

  @override
  String vsLastWeek(String delta) {
    return '$delta vs sem. dernière';
  }

  @override
  String vsLastMonth(String delta) {
    return '$delta vs mois dernier';
  }

  @override
  String vsLastYear(String delta) {
    return '$delta vs an dernier';
  }

  @override
  String get byHabit => 'Par habitude';

  @override
  String get daysSucceeded => 'jours réussis';

  @override
  String rateA11y(String list) {
    return 'Taux par période : $list';
  }

  @override
  String xpOf(String xp, String next) {
    return '$xp / $next XP';
  }

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get badgesTab => 'Badges';

  @override
  String get challengesTab => 'Défis';

  @override
  String get jokersLabel => 'jokers de série';

  @override
  String get bestStreakLabel => 'meilleure série';

  @override
  String daysShort(String count) {
    return '$count j';
  }

  @override
  String countOf(String count, String total) {
    return '$count sur $total';
  }

  @override
  String get badgeFirstStep => 'Premier pas';

  @override
  String get badgeStreak7 => '7 jours';

  @override
  String get badgeEarlyBird => 'Lève-tôt';

  @override
  String get badgeBookworm => 'Rat de biblio';

  @override
  String get badgeStreak30 => '30 jours';

  @override
  String get badgeZen => 'Zen absolu';

  @override
  String get badgePerfectDay => 'Journée parfaite';

  @override
  String get badgePerfectWeek => 'Semaine parfaite';

  @override
  String get badgeStreak100 => '100 jours';

  @override
  String get badgeNightOwl => 'Oiseau de nuit';

  @override
  String get badgeHydrated => 'Hydraté';

  @override
  String get badgeRescue => 'Sauvetage';

  @override
  String badgeEarned(String name) {
    return '$name, obtenu';
  }

  @override
  String badgeLocked(String name) {
    return '$name, verrouillé';
  }

  @override
  String get weeklyChallenge => 'Défi de la semaine';

  @override
  String xpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String challengeSevenDays(String name) {
    return '$name 7 jours d’affilée';
  }

  @override
  String challengeGoalFive(String goal) {
    return '$goal, 5 jours cette semaine';
  }

  @override
  String challengeTimes(String name, String count) {
    return '$name $count fois cette semaine';
  }

  @override
  String get challengePerfectWeek => 'Une semaine parfaite';

  @override
  String challengeDaysLeft(String done, String target, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'reste $left jours',
      one: 'reste $left jour',
    );
    return '$done jours sur $target · $_temp0';
  }

  @override
  String challengeDays(String done, String target) {
    return '$done jours sur $target';
  }

  @override
  String challengeSessions(String done, String target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$done séances sur $target',
      one: '$done séance sur $target',
    );
    return '$_temp0';
  }

  @override
  String challengePerfectDays(String done, String target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$done journées parfaites sur $target',
      one: '$done journée parfaite sur $target',
    );
    return '$_temp0';
  }

  @override
  String get challengeDone => 'Réussi !';

  @override
  String get yourName => 'Ton prénom';

  @override
  String memberSince(String date) {
    return 'Membre depuis $date';
  }

  @override
  String get settingsLabel => 'Réglages';

  @override
  String get statSeries => 'série';

  @override
  String get pillsFilled => 'pilules remplies';

  @override
  String get premiumCardTitle => 'Passe à Premium';

  @override
  String get premiumCardBody => 'Stats illimitées, thèmes et export';

  @override
  String get tryPremium => 'Essayer';

  @override
  String get noReminders => 'Aucun';

  @override
  String get rowTheme => 'Thème';

  @override
  String get themeSorbet => 'Sorbet';

  @override
  String get rowDarkMode => 'Mode sombre';

  @override
  String get soon => 'Bientôt';

  @override
  String get rowJokers => 'Jokers de série';

  @override
  String jokersLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count restants',
      one: '$count restant',
    );
    return '$_temp0';
  }

  @override
  String get rowExport => 'Exporter mes données';

  @override
  String get csv => 'CSV';

  @override
  String get rowDayStart => 'Début de la journée';

  @override
  String get dayStartHint =>
      'Jusqu’à cette heure, la nuit compte encore pour la veille.';

  @override
  String get noReminder => 'Aucun rappel';

  @override
  String ratio(String a, String b) {
    return '$a / $b';
  }

  @override
  String get notifChannelName => 'Rappels';

  @override
  String get notifChannelDescription =>
      'Rappels d’habitudes et alertes de série';

  @override
  String get reminderBody => 'Un petit pas maintenant ?';

  @override
  String dangerBody(String names) {
    return 'Encore $names aujourd’hui pour garder ta flamme.';
  }

  @override
  String remindersSummary(int habits, int reminders) {
    String _temp0 = intl.Intl.pluralLogic(
      habits,
      locale: localeName,
      other: '$habits habitudes',
      one: '$habits habitude',
    );
    String _temp1 = intl.Intl.pluralLogic(
      reminders,
      locale: localeName,
      other: '$reminders rappels',
      one: '$reminders rappel',
    );
    return '$_temp0 · $_temp1';
  }
}
