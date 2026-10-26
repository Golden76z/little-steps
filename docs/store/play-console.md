# Little Steps : tout ce qu'il faut remplir dans la Play Console

Version 1.0.0 (versionCode 1), package `dev.golden.littlesteps`, éditeur **Golden76z**.

> **Attention, les règles changent.** Tout ce qui concerne les règles Google Play
> (test fermé, accès à la production, formulaires « Contenu de l'appli ») décrit
> la situation connue en octobre 2026. Vérifie chaque point dans la Console et
> dans le Centre d'aide Play Console avant de valider.

> **Version gratuite.** L'AAB 1.0.0 est construit avec `premiumOffered = false`
> (`lib/features/create_habit/habit_draft.dart`) : aucune limite d'habitudes,
> aucun écran ni carte Premium, aucun achat intégré. Visuels : régénère-les
> avec `flutter test tool/store/screenshots_test.dart` puis
> `uv run --with pillow python tool/store/frame.py`.

---

## 1. Fiche Play Store (Présence sur le Play Store › Fiche principale)

### Nom de l'appli (30 caractères max)

`Little Steps` (12 caractères)

Variante plus parlante pour la recherche, si tu veux : `Little Steps : habitudes`
(24 caractères) en FR et `Little Steps: Habit Tracker` (27 caractères) en EN.

### Description courte (80 caractères max)

- **FR** (76 caractères) :
  `Petites habitudes, grandes séries. Gratuit, sans pub ni compte, 100 % local.`
- **EN** (75 caractères) :
  `Small steps, lasting habits. Free, no ads, no account, works fully offline.`

### Description complète FR (4 000 caractères max)

```text
Little Steps t'aide à construire de petites habitudes qui tiennent. Pas de pression, pas de culpabilité : un pas après l'autre, chaque jour.

Gratuit, sans publicité et sans compte. Tes données restent sur ton téléphone, et l'appli fonctionne entièrement hors ligne.

TA JOURNÉE EN UN COUP D'ŒIL
Chaque habitude devient une pastille sur l'écran Aujourd'hui. Maintiens-la appuyée pour la valider : une petite vibration, un petit son, et c'est fait.

DES HABITUDES À TA MESURE
• Oui / non : boire de l'eau, faire son lit, méditer
• Quantité : 8 verres d'eau, 20 pages lues
• Durée, avec minuteur intégré : 10 minutes de yoga
• Journal : trois lignes de gratitude et ton humeur du jour
• Fréquence hebdomadaire : 3 séances de sport par semaine, les jours que tu veux
Choisis tes jours actifs, réordonne tes habitudes comme tu veux.

DES SÉRIES QUI PARDONNENT
• Tes séries comptent les jours (ou les semaines) réussis d'affilée
• Un jour raté ? Un joker protège ta série
• Vacances ou maladie : mets une habitude en pause, ta série est gelée et les rappels se taisent

UN PEU DE JEU POUR TENIR
• Gagne de l'XP et monte de niveau
• Débloque des badges
• Relève un défi chaque semaine

TES PROGRÈS, CLAIREMENT
Statistiques par semaine, par mois et par année : taux de réussite, meilleures séries, calendrier de tes validations.

DES RAPPELS DOUX
Programme un ou plusieurs rappels par habitude, et un petit rappel le soir si ta série est en danger. Sons et vibrations se désactivent en un geste.

TES DONNÉES T'APPARTIENNENT
• Aucun compte, aucun serveur, aucune statistique d'usage, aucune pub
• Tout est stocké sur ton appareil
• Exporte une sauvegarde JSON quand tu veux et réimporte-la sur un autre téléphone

En français et en anglais.

Une question, une idée ? Écris-nous à damienprouet76@gmail.com.
```

### Description complète EN (4 000 caractères max)

```text
Little Steps helps you build small habits that stick. No pressure, no guilt: one step at a time, every day.

Free, no ads and no account. Your data stays on your phone, and the app works fully offline.

YOUR DAY AT A GLANCE
Each habit is a pill on the Today screen. Press and hold to check it off: a little buzz, a little sound, done.

HABITS THAT FIT YOU
• Yes / no: drink water, make your bed, meditate
• Quantity: 8 glasses of water, 20 pages read
• Duration, with a built-in timer: 10 minutes of yoga
• Journal: three lines of gratitude and your mood of the day
• Weekly frequency: 3 workouts a week, on any days you like
Pick your active days and reorder your habits however you want.

FORGIVING STREAKS
• Streaks count the days (or weeks) you kept going
• Missed a day? A joker keeps your streak safe
• Holidays or sick days: pause a habit, your streak is frozen and reminders stay quiet

A LITTLE PLAY TO KEEP GOING
• Earn XP and level up
• Unlock badges
• Take on a new challenge every week

YOUR PROGRESS, CLEARLY
Weekly, monthly and yearly stats: success rate, best streaks, a calendar of your check-ins.

GENTLE REMINDERS
Set one or more reminders per habit, plus an evening nudge when a streak is at risk. Sounds and vibrations turn off in one tap.

YOUR DATA IS YOURS
• No account, no server, no usage analytics, no ads
• Everything is stored on your device
• Export a JSON backup whenever you like and import it on another phone

Available in English and French.

Questions or ideas? Write to damienprouet76@gmail.com.
```

Avant de coller, vérifie dans l'appli que chaque fonction citée est bien
visible ; retire ce qui ne l'est pas.

### Catégorie, tags, coordonnées

- **Type** : Application. **Catégorie recommandée : Productivité.** Little Steps
  suit des habitudes de tout type (lecture, rangement, journal), pas des données
  de santé ; « Santé et remise en forme » pousserait à remplir la déclaration
  « Applis de santé » et placerait l'appli à côté des trackers médicaux et
  sportifs. « Santé et remise en forme » reste défendable si tu vises surtout
  le bien-être ; dans ce cas, déclare la fonction bien-être (voir § 3).
- **Tags** (Fiche › Tags, jusqu'à 5) : choisis dans la liste proposée ceux
  qui se rapprochent de *Suivi des habitudes*, *Productivité personnelle*,
  *Agenda / planificateur*, *Bien-être*, *Journal intime*. La liste
  disponible dépend de la catégorie ; ne prends que ce qui décrit l'appli.
- **Adresse e-mail** : `damienprouet76@gmail.com`
- **Site web** (facultatif) : `https://golden76z.github.io/little-steps/`
- **Téléphone** : laisser vide.
- **Règles de confidentialité** (Contenu de l'appli et fiche) :
  `https://golden76z.github.io/little-steps/privacy.html`
  (GitHub Pages doit être actif sur `main` / `/docs` **avant** de soumettre :
  Google vérifie que l'URL répond.)

### Éléments graphiques

| Élément | Règle Play | Fichier |
|---|---|---|
| Icône | 512 × 512 px, PNG 32 bits (alpha autorisé), 1 Mo max | `docs/store/icon-512.png` |
| Image de présentation (feature graphic) | 1 024 × 500 px, JPEG ou PNG 24 bits **sans transparence**, 15 Mo max | `docs/store/feature-graphic-fr.png` / `-en.png` |
| Captures téléphone FR | 2 à 8, JPEG ou PNG 24 bits sans transparence, côté min 320 px, côté max 3 840 px, le grand côté ≤ 2 × le petit. Recommandé : portrait 9:16, 1080 × 1920 ; au moins 4 captures ≥ 1080 px pour être éligible aux mises en avant | `docs/store/screenshots/fr/01.png` … `06.png` |
| Captures téléphone EN | idem | `docs/store/screenshots/en/01.png` … `06.png` |

Les captures FR vont dans la fiche principale (langue par défaut : français),
les EN dans la traduction « Anglais (États-Unis) – en-US » (Fiche › Gérer les
traductions › ajouter). Pas de captures tablette nécessaires si l'appli n'est
pas proposée comme appli tablette.

---

## 2. Sécurité des données (Contenu de l'appli › Sécurité des données)

Définition Google à garder en tête : une donnée est **« collectée »** quand elle
quitte l'appareil vers toi ou un tiers. Une donnée traitée uniquement sur le
téléphone n'est pas collectée. Une donnée est **« partagée »** quand elle est
transmise à un tiers. Une action déclenchée par l'utilisateur (le menu de
partage d'Android pour l'export JSON, par exemple) n'est pas un partage au sens
de Play.

| Question | Réponse |
|---|---|
| Votre appli collecte-t-elle ou partage-t-elle l'un des types de données utilisateur requis ? | **Non** |
| Toutes les données collectées sont-elles chiffrées en transit ? | Sans objet (la question disparaît après « Non ») |
| Proposez-vous un moyen de demander la suppression des données ? | Sans objet. Si la Console le demande quand même : aucune donnée n'est détenue par le développeur ; l'utilisateur efface tout en désinstallant l'appli ou en vidant son stockage |
| Engagement Families / examen de sécurité indépendant | Non |

Résultat attendu sur la fiche : « Aucune donnée collectée » et « Aucune donnée
partagée avec des tiers ».

**Sauvegarde Android.** L'appli active la sauvegarde automatique d'Android
(`android:allowBackup="true"`, règles dans `android/app/src/main/res/xml/`) :
la base SQLite peut partir dans la sauvegarde Google **de l'utilisateur**. Ce
transfert est fait par le système, sous le compte de l'utilisateur, et tu n'y
as pas accès. C'est généralement traité comme hors collection développeur ;
la politique de confidentialité le mentionne déjà. Vérifie la formulation
actuelle du Centre d'aide « Sécurité des données » au moment de remplir.

---

## 3. Contenu de l'appli (Règles et programmes › Contenu de l'appli)

À cocher un par un :

- [ ] **Règles de confidentialité** : `https://golden76z.github.io/little-steps/privacy.html`
- [ ] **Annonces** : « Non, mon appli ne contient pas d'annonces ».
- [ ] **Accès à l'appli** : « Toutes les fonctionnalités sont disponibles sans
      restriction d'accès » (aucune connexion).
- [ ] **Classification du contenu** : questionnaire IARC, voir § 4.
- [ ] **Public cible et contenu** : tranche **18 ans et plus** uniquement.
      L'appli n'attire pas particulièrement les enfants ; pas de Familles.
- [ ] **Sécurité des données** : voir § 2.
- [ ] **Applis gouvernementales** : Non.
- [ ] **Fonctionnalités financières** : « Mon appli ne propose aucune
      fonctionnalité financière ».
- [ ] **Applis de santé** : la Console demande à toutes les applis de
      déclarer leurs fonctions de santé. Un tracker d'habitudes généraliste
      n'est pas une appli médicale. Avec la catégorie Productivité, réponds
      « Mon appli n'a pas de fonctionnalités de santé ». Si tu prends la
      catégorie Santé et remise en forme, ou si tu estimes que le journal
      d'humeur relève du bien-être, coche seulement la case de bien-être la
      plus proche (gestion du stress, relaxation, bien-être mental) et rien de
      médical. Lis bien les intitulés : ils changent.
- [ ] **Applis d'actualités** : Non.
- [ ] **COVID-19 (recherche de contacts, statut)** : Non, si la question
      existe encore.
- [ ] **Identifiant publicitaire** : « Non, mon appli n'utilise pas
      l'identifiant publicitaire ». Le manifeste fusionné ne déclare pas
      `AD_ID`.
- [ ] **Autorisations sensibles** : rien à déclarer. Le manifeste fusionné de
      la release ne demande que `POST_NOTIFICATIONS`,
      `RECEIVE_BOOT_COMPLETED`, `VIBRATE` (et la permission interne
      `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` ajoutée par AndroidX). Pas
      d'alarmes exactes (`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`), pas de
      service de premier plan, pas d'intent plein écran, pas de photos/vidéos,
      pas d'`INTERNET`.

---

## 4. Classification du contenu (questionnaire IARC)

- **Adresse e-mail** : `damienprouet76@gmail.com`
- **Catégorie** : « Utilitaire, productivité, communication ou autre ».
- Réponses :

| Thème | Réponse |
|---|---|
| Violence, sang, peur | Non |
| Sexualité, nudité | Non |
| Langage grossier | Non |
| Substances (alcool, tabac, drogues) | Non |
| Jeux d'argent, simulés ou réels | Non |
| Humour cru ou discriminatoire | Non |
| Les utilisateurs peuvent-ils interagir ou échanger du contenu ? | Non |
| Partage de la position avec d'autres utilisateurs | Non |
| Achats numériques | Non |
| Accès non restreint à internet (navigateur, moteur de recherche) | Non |
| Appli d'actualité ou éducative | Non |

Classification attendue : **PEGI 3**, **ESRB Everyone**, **USK 0**,
**IARC 3+**, **ClassInd L**. (Le public cible 18+ du § 3 est un choix de
ciblage, il ne change pas cette classification.)

---

## 5. Version (Test et publication)

1. **Signature d'application par Google Play** : accepter (« Utiliser une clé
   générée par Google » ou garder la clé d'importation actuelle comme clé
   d'importation). Ta clé locale devient la *clé d'importation* ; garde-la
   précieusement, mais tu peux la réinitialiser via Google si tu la perds.
2. **Fichier à téléverser** : `build/app/outputs/bundle/release/app-release.aab`
   (reconstruis-le avec `flutter build appbundle --release` juste avant ;
   celui présent date du 25/10).
3. **Nom de la version** : `1.0.0 (1)`.
4. **Notes de version** (500 caractères max par langue) :

```text
<fr-FR>
Première version de Little Steps !
• Habitudes oui/non, quantité, durée avec minuteur, journal et fréquence hebdomadaire
• Validation par appui long sur l'écran Aujourd'hui
• Séries avec jokers et mise en pause
• XP, niveaux, badges et défis de la semaine
• Statistiques semaine, mois, année
• Rappels, sons et vibrations réglables
• Sauvegarde et restauration en JSON
Gratuit, sans pub, sans compte, 100 % local.
</fr-FR>
<en-US>
The first version of Little Steps!
• Yes/no, quantity, timed, journal and weekly habits
• Press and hold to check off on the Today screen
• Streaks with jokers and pause
• XP, levels, badges and weekly challenges
• Weekly, monthly and yearly stats
• Reminders, adjustable sounds and vibrations
• JSON backup and restore
Free, no ads, no account, fully local.
</en-US>
```

(FR : 413 caractères, EN : 358 caractères, balises non comprises.)

---

## 6. Test fermé, pas à pas (compte développeur personnel)

Règle connue pour les comptes personnels créés après le 13 novembre 2023 :
avant de pouvoir demander l'accès à la **production**, il faut un test fermé
avec **au moins 12 testeurs inscrits (opt-in) sans interruption pendant au
moins 14 jours**. Le seuil était de 20 avant décembre 2024. Vérifie le chiffre
affiché dans le tableau de bord de la Console : c'est lui qui fait foi.

### Avant de lancer

- [ ] Identité du compte vérifiée et appareil Android validé dans l'appli
      Play Console (si la Console le demande).
- [ ] § 1 à § 4 remplis (le test fermé passe aussi par l'examen Google).
- [ ] GitHub Pages actif et `privacy.html` accessible.

### Mise en place

1. **Test et publication › Tests › Test fermé** : utilise le canal proposé
   (« Closed testing – Alpha ») ou **Créer un canal**.
2. **Pays/régions** du canal : au minimum France, plus ceux de tes testeurs.
3. **Testeurs** › **Créer une liste d'adresses e-mail** (« Testeurs Little
   Steps ») et colle les adresses Gmail, séparées par des virgules ; ou bien
   indique l'adresse d'un **Google Groupe** (pratique : les gens rejoignent
   le groupe eux-mêmes). Renseigne l'**URL ou l'e-mail de commentaires** :
   `damienprouet76@gmail.com`. Enregistre.
4. **Créer une version** dans ce canal, téléverse l'AAB, colle les notes de
   version du § 5, **Vérifier la version** puis **Lancer le déploiement**.
5. Va dans **Vue d'ensemble de la publication** et envoie les modifications à
   l'examen si elles ne partent pas automatiquement. Compte de quelques heures
   à quelques jours.
6. Une fois approuvé, onglet **Testeurs** : copie le **lien pour participer**
   (de la forme `https://play.google.com/apps/testing/dev.golden.littlesteps`).
   Le lien Play Store est
   `https://play.google.com/store/apps/details?id=dev.golden.littlesteps`.
7. Envoie le message du § 7. Chaque testeur doit ouvrir le lien **avec le
   compte Google de la liste**, cliquer sur « Devenir testeur », puis
   installer l'appli depuis le Play Store.

### Pendant les 14 jours

- Vise **15 à 20 testeurs** pour garder de la marge : si un testeur quitte le
  programme, il ne compte plus, et le compteur doit rester ≥ 12 en continu.
- Demande aux testeurs de **garder l'appli installée** et de l'ouvrir de temps
  en temps ; ne les retire pas de la liste.
- Publie **une ou deux mises à jour** dans le canal fermé (corrections,
  petites améliorations, `versionCode` incrémenté) : ça montre un vrai test.
- Note tout : retours reçus, bugs corrigés, changements faits. Tu en auras
  besoin pour la candidature.
- Surveille **Qualité › Android vitals** et les retours privés des testeurs.

### Demande d'accès à la production

Quand le tableau de bord indique que les conditions sont remplies : **Tableau
de bord › Demander l'accès à la production**. Les questions connues (à
vérifier, elles évoluent) :

1. **À propos du test fermé** : comment as-tu recruté tes testeurs ; était-ce
   facile ; comment ont-ils utilisé l'appli (engagement) ; résumé des retours
   reçus et de la façon dont tu les as recueillis.
2. **À propos de l'appli** : public visé ; ce que l'appli apporte aux
   utilisateurs ; nombre d'installations attendu la première année.
3. **Préparation à la production** : changements faits suite au test ;
   comment tu as décidé que l'appli était prête.

Réponds concrètement, avec des exemples tirés de tes notes (« trois testeurs
trouvaient l'appui long trop long, réduit dans la 1.0.0 (2) »). Réponse de
Google en général sous 7 jours. Ensuite, crée une version en **Production**
(ou promeus la version testée) et envoie-la à l'examen.

---

## 7. Message de recrutement des testeurs (à envoyer toi-même)

```text
Salut !

Je lance Little Steps, ma petite appli Android pour prendre de bonnes habitudes, un pas à la fois. Avant de la publier sur le Play Store, Google me demande de la faire tester par au moins 12 personnes pendant 14 jours.

Tu veux bien m'aider ? Ça prend 2 minutes :
1. Envoie-moi l'adresse Gmail de ton téléphone Android, pour que je t'ajoute à la liste.
2. Ouvre ce lien avec ce compte et clique sur « Devenir testeur » : [LIEN_OPT_IN]
3. Installe l'appli depuis le Play Store : [LIEN_PLAY_STORE]
4. Garde-la installée au moins 14 jours et ouvre-la de temps en temps.

C'est gratuit, sans pub et sans compte : tout reste sur ton téléphone.

Un bug, une idée, un truc pas clair ? Réponds-moi ici ou écris à damienprouet76@gmail.com.

Merci beaucoup !
Damien
```
