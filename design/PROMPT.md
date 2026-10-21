Tu vas implémenter en Flutter l'application **Little Steps**, un tracker d'habitudes mobile, à partir de maquettes déjà validées.

## Sources

- `design/DESIGN.md` : la spec complète. Elle couvre la lecture des maquettes, la liste des écrans, les tokens et les règles produit. **Lis-la entièrement avant d'écrire du code.**
- `design/maquettes/*.dc.html` : 16 écrans de 390×844.
  - Les styles inline font foi pour les dimensions, rayons, couleurs et ombres.
  - La classe JS en bas de chaque fichier donne les données de démo et les comportements.
  - Ces fichiers ne s'ouvrent pas dans un navigateur : lis-les comme du code source.
  - Pour chaque `data-props`, prends uniquement la valeur `default`.

## Stack attendue

- Flutter stable, Android en priorité, sans rien qui bloque iOS. Material 3 en base, entièrement re-stylé avec le design Sorbet.
- `phosphor_flutter` pour les icônes, avec le même mapping que dans les maquettes : Regular pour les onglets inactifs, Fill pour l'onglet actif.
- `google_fonts`, ou la police embarquée, pour **Sour Gummy** en graisses 400, 500 et 600 uniquement.
- i18n :
  - `flutter_localizations` + `intl` ;
  - `lib/l10n/app_en.arb` comme fichier source et `app_fr.arb` en tutoiement ;
  - aucune chaîne en dur ;
  - les nombres, pourcentages et dates sont formatés selon la locale.
- Persistance local-first : propose Drift ou Isar avec une phrase de justification, puis choisis.
- State management : Riverpod, sauf meilleure raison que tu m'expliques.
- Toutes les couleurs passent par un `ThemeExtension`. Pas de couleurs en dur dans les widgets : le mode sombre doit pouvoir s'ajouter plus tard.

## Architecture

- Organise le code par feature :
  - `today`
  - `habit_detail`
  - `progress`
  - `trophies`
  - `profile`
  - `create_habit`
  - `core` (thème, l10n, base de données, widgets partagés)
- Modèle `Habit` :
  - type parmi `quantity`, `duration`, `yesNo`, `journal` et `frequency` ;
  - couleur parmi les 12 de la spec ;
  - objectif, unité, pas ;
  - planning : jours actifs ou X fois par semaine, moment de la journée, rappels ;
  - pause et archivage.
- Entrées journalières : une par habitude et par « jour logique ». Le jour bascule à 3 h, valeur réglable.
- Logique métier pure et testée en Dart :
  - progression = valeur / objectif, plafonnée à 1 ;
  - séries par habitude et série globale ;
  - journée parfaite, qui exclut les habitudes en repos ou en pause ;
  - XP : 10 par habitude, plus un bonus pour une journée parfaite ;
  - jokers : 1 gagné tous les 7 jours parfaits, **2 au maximum**.

## Widgets réutilisables

- `HabitPill` : pilule de 64 px, remplissage pastel proportionnel au %, nom, sous-titre avec la valeur native, % à droite et bouton rond.
- `SegmentedStrip` : bande collée sur fond `#FFF4F7`, cellule sélectionnée blanche avec contour rose doux. Elle sert pour les jours de la semaine, Semaine/Mois/Année et Badges/Défis.
- `FloatingNavBar` : pilule blanche flottante, 4 onglets et un « + » rond de couleur accent au centre.
- `AppHeaderCard` : carte blanche dont les coins bas sont arrondis à 32.
- `MonthMosaic` : mosaïque de calendrier avec gap de 1 px.
- `BottomSheet` dans le style des écrans E2 et E3.

## Ordre de travail

1. Initialise le projet, puis mets en place le thème (tokens, typo, ThemeExtension), la l10n EN/FR et la navigation (go_router, shell avec la barre flottante).
2. Implémente les modèles, la base de données et la logique métier, avec des tests unitaires sur séries, journée parfaite, XP, jokers et bascule à 3 h.
3. Crée l'écran Accueil (`H2-SemaineBonbon`) et l'état vide (`E1-Vide`). Gestes :
   - tap sur la pilule : action rapide du type, avec un toast « Annuler » ;
   - tap sur l'icône : ouverture de la fiche ;
   - appui long : options (`E3-Options`).
   Ajoute un groupe « Repos aujourd'hui » en bas.
4. Développe le parcours de création en 3 étapes (`P1-Type`, `P2-Reglages`, `P3-Planning`). La limite gratuite est de 5 habitudes : au-delà, affiche un écran Premium simple en placeholder.
5. Construis les fiches par type (`T1` à `T5`, `F-Fiche`) et la feuille joker (`E2-Joker`).
6. Crée les écrans Progrès, Trophées et Profil.
7. Ajoute les rappels avec des notifications locales.

## Règles de travail

- Après chaque étape : `flutter analyze` doit être propre et les tests doivent passer. Fais un point court sur ce qui est fait et sur les écarts avec la maquette.
- Respecte les maquettes au pixel près pour les rayons, espacements, couleurs et graisses. Si quelque chose est ambigu ou manque dans la spec, demande-moi avant d'inventer.
- Pour l'accessibilité :
  - zones tactiles d'au moins 48 px ;
  - `Semantics` sur les pilules (nom + progression) et sur la barre de navigation ;
  - mise en page qui tient avec une taille de texte système plus grande.
- Commence par l'étape 1, puis montre-moi le résultat avant de continuer.
