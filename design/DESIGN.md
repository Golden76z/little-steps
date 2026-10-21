# Little Steps — spécification design

Application mobile de suivi d'habitudes, développée en Flutter, Android d'abord.
Elle est bilingue : l'anglais est la langue source, le français est traduit (en tutoyant).
Les maquettes du dossier `maquettes/` sont rédigées en français ; leurs textes servent de base aux fichiers ARB.

## 1. Lire les maquettes

Chaque `*.dc.html` est un écran de **390 × 844**.
Le balisage utilise des **styles inline**, qui font foi pour les tailles, rayons, espacements et couleurs.
La logique se trouve dans la classe JS en bas du fichier (`class Component extends DCLogic`, avec `renderVals()`). Elle contient les données de démo et les comportements : incréments, formats, états.

- La syntaxe `{{x}}` est un trou lié à `renderVals()`. `sc-for` sert aux boucles, `sc-if` aux conditions.
- `data-props` contient des réglages de prévisualisation. Il faut prendre la **valeur `default`** :
  - accent `#F0507F` ;
  - heatmap du mois : `Calendrier` ;
  - section populaires : `Tuiles` ;
  - aperçu du nom : `Aperçu`.
  Les autres options sont des variantes rejetées.
- Les icônes sont des tracés **Phosphor**, inlinés dans `const IC = {...}`. Le suffixe `R` correspond à Regular, `F` à Fill, `B` à Bold.
  En Flutter, utiliser `phosphor_flutter`. Par exemple, `houseR` devient `PhosphorIconsRegular.house` et `houseF` devient `PhosphorIconsFill.house`.
- Ces fichiers ne s'ouvrent pas seuls dans un navigateur, car il leur manque le runtime `support.js`. Il faut les lire comme du code source.

## 2. Écrans

| Fichier | Écran | Notes |
|---|---|---|
| `H2-SemaineBonbon` | **Accueil (Today)** | Contenu détaillé sous le tableau |
| `F-Fiche` | Fiche d'une habitude (eau) | Carte vague (180 px) avec boutons `+1 verre` et `−`. 3 stats collées dans un seul panneau avec séparateurs. Calendrier du mois en mosaïque collée (gap 1 px, rayon des cellules 3 px, conteneur 16 px). |
| `F-Progres` | Progrès | Flèches de période, bande Semaine / Mois / Année, carte du % global avec tubes, une pilule par habitude qui ouvre sa fiche |
| `F-Trophees` | Trophées | Switch Badges / Défis, jokers, badges, défis |
| `F-Profil` | Profil | Bandeau de stats, carte Premium, réglages, switch mode sombre |
| `T1-Quantite` | Type Quantité | Unité Verres / Litres, pas « Ajouter par » |
| `T2-Duree` | Type Durée | Anneau minuteur, préréglages |
| `T3-OuiNon` | Type Oui / Non | Historique avec cases joker |
| `T4-Journal` | Type Journal | Zone de texte, compteur de lignes, humeurs |
| `T5-Frequence` | Type Fréquence (X fois / semaine) | Créneaux, mosaïque de 8 semaines |
| `P1-Type` | Création 1/3 : choix du type | Titre centré, recherche, populaires en tuiles, liste des 5 types, CTA « Continuer · {type} » |
| `P2-Reglages` | Création 2/3 : nom, couleur, objectif | 12 couleurs. Objectif affiché en gros chiffre + unité plus petite. Unités et pas. |
| `P3-Planning` | Création 3/3 : planning | Rythme « jours précis » (jours de repos activables) ou « X fois / semaine ». Moment (matin, midi, soir, journée), rappels, alerte « série en danger ». |
| `E1-Vide` | Accueil vide | Premier lancement |
| `E2-Joker` | Feuille joker | « Utiliser un joker », puis état sauvé ou passé |
| `E3-Options` | Feuille options (appui long) | Modifier, Mettre en pause (choix de durée), Archiver, Supprimer |

### Accueil en détail

- **En-tête** : carte blanche avec coins bas arrondis à 32. On y trouve :
  - l'avatar entouré de l'anneau d'XP, qui mène aux Trophées ;
  - le titre ;
  - la puce flamme de série ;
  - le bouton calendrier ;
  - un séparateur, puis la semaine en bande collée.
- **Liste des habitudes** : une pilule de 64 px par habitude. Le remplissage pastel suit le **pourcentage**. On affiche le nom, la valeur réelle en sous-titre et le **% à droite**.
- **Barre du bas** : pilule blanche flottante avec 4 onglets et un « + » rond.

## 3. Tokens

```
bg        #FFF0F4   fond app
surface   #FFFFFF   cartes, en-tête, barre du bas
ink       #3B1730   texte
muted     #7A5670   texte secondaire
accent    #F0507F   CTA, bouton +, anneau XP
navActive #EF6F9C   onglet actif (icône blanche, Phosphor Fill)
strip     #FFF4F7   bandes segmentées collées (padding 4, rayon 22)
selected  #FFFFFF + inset 0 0 0 2px #FFC9DA   cellule sélectionnée dans une bande
shadowPill 0 3px 0 #F3D6E0                   ombre « bonbon » sous pilules et barre
flameChip #FFE6D6
```

**Couleurs d'habitude.** Le choix est fait à la création parmi 12 teintes.

| Nom | Hex | Nom | Hex | Nom | Hex |
|---|---|---|---|---|---|
| Lilas | `#DCC8FF` | Menthe | `#B6F0D2` | Pêche | `#FFCBA4` |
| Lavande | `#C9D0FF` | Pistache | `#D6F2A8` | Corail | `#FFB3A7` |
| Ciel | `#BFE3FF` | Citron | `#FFF09A` | Rose | `#FFB8CF` |
| Lagon | `#A8EEE6` | Abricot | `#FFD8A8` | Framboise | `#F5B0E0` |

**Typographie.** Police **Sour Gummy** (Google Fonts, via `google_fonts` ou embarquée), en graisses **400 / 500 / 600** seulement : rien au-dessus de 600, sinon le rendu devient pâteux. Les chiffres utilisent `tabular-nums` (`FontFeature.tabularFigures()`).

**Rayons.**
- Pilules : la moitié de la hauteur.
- Cartes : 24 à 32.
- Bandes : 22, cellules : 18.
- Le bouton « + » est un cercle.

Toutes les couleurs passent par un `ThemeExtension`, pour préparer le mode sombre.

## 4. Règles produit validées

**Types d'habitude**

- Il y a 5 types : **Quantité**, **Durée**, **Oui / Non**, **Journal** et **Fréquence** (X fois par semaine).
  - Un type Quantité porte une unité et un pas : verres, litres, ml, pages…
  - « Dessiner » est un exemple de type Durée.
- **Progression** = `valeur / objectif`, plafonnée à 100 %. Ce pourcentage est affiché uniformément sur l'accueil.

**Gestes**

| Geste | Effet |
|---|---|
| Tap sur la pilule | Action rapide du type : ajoute un pas, lance le minuteur, coche ou ouvre le journal |
| Tap sur l'icône | Ouvre la fiche |
| Appui long | Ouvre les options (E3) |

Chaque ajout affiche un toast « Annuler ».

**Jours de repos et pause**

- Les jours de repos se règlent par habitude. Ces habitudes apparaissent dans un groupe « Repos aujourd'hui » en bas de l'accueil.
- La pause a une durée choisie. Les jours de repos et de pause ne cassent pas la série.

**Séries et récompenses**

- **Séries** : une par habitude, plus une flamme globale.
- **Journée parfaite** : toutes les habitudes prévues ce jour-là sont faites, en excluant celles en repos ou en pause.
- **XP** : 10 par habitude complétée, plus un bonus de journée parfaite. Le niveau s'affiche dans l'anneau de l'avatar.
- **Jokers** : on en gagne 1 tous les 7 jours parfaits, avec **2 au maximum** en réserve. Un joker sauve une série en danger (E2).

**Jour et données**

- Le jour bascule à **3 h du matin** (réglable).
- L'app est **local-first** : base locale. Un compte optionnel, réservé au Premium, permet la synchronisation.
- **Offre gratuite** : 5 habitudes. Au-delà, il faut le Premium.

**Langues**

- i18n avec `flutter_localizations`, `app_en.arb` (langue source) et `app_fr.arb`. Aucune chaîne en dur.
- Les nombres, % et dates passent par `intl` : « 1.25 L » en anglais, « 1,25 L » en français, « 50% » contre « 50 % », et le premier jour de la semaine suit la locale.
- Les mises en page doivent tenir avec les textes français, plus longs.
