# Little Steps — mouvement, retours et micro-interactions

Date : 2026-10-25. Statut : à valider.

## 1. Pourquoi

Sur téléphone, les animations de l'app « ne font pas naturel, pas fluide ».
L'audit du code et une recherche sur le motion design de référence en donnent les causes :

- **Interpolations à durée fixe.** Toutes les animations utilisent des interpolations de 150 à 300 ms en easeOutCubic, et plusieurs sont linéaires ou codées en dur. Un tap au milieu d'une animation la fait repartir de zéro ou changer de vitesse d'un coup.
- **Deux retours d'appui superposés.** Une réduction d'échelle de 150 ms se cumule avec une onde Material de 617 ms.
- **Contenus qui sautent.** Ils changent de taille ou de contenu sans animation. Les `AnimatedSwitcher` font des fondus enchaînés qui montrent une double image.
- **Animations qui ne jouent jamais :**
  - remontage du bouton de `yes_no_detail.dart` ;
  - couleur du texte des bandes écrasée par les `itemBuilder` ;
  - montée du chiffre de l'objectif.
- **Aucun retour haptique ni sonore.** Le tap attend aussi l'écriture en base avant de remplir la pilule.

Sources principales :
- Apple, WWDC18 « Designing Fluid Interfaces » et WWDC23 « Animate with springs » ;
- Material 3 Expressive, ressorts spatiaux et ressorts d'effets (`ExpressiveMotionTokens.kt` d'androidx) ;
- Emil Kowalski, conseils pratiques ;
- Android, « Haptics design principles » ;
- les apps Duolingo, Streaks et (Not Boring) Habits.

## 2. Objectifs

1. **Tout ce qui bouge dans l'espace suit un ressort.** C'est le cas des positions, tailles, échelles et remplissages. Le ressort repart de la position et de la vitesse courantes quand la cible change en cours de route, sans jamais redémarrer de zéro.
2. **Personnalité « vive et ludique ».** Les ressorts sont nets, avec un léger rebond (≈ 0,15–0,3) sur ce qui s'y prête. Aucun rebond sur les couleurs, les opacités, ni les remplissages qui dépasseraient 100 %.
3. **Appui « bouton 3D ».** Ce qui a une ombre bonbon s'enfonce dans son ombre, puis remonte avec un ressort. On ne voit plus aucune onde Material.
4. **Retour immédiat.** L'appui se voit dès que le doigt touche. Le remplissage d'une pilule part dans la même image que le tap, sans attendre la base.
5. **Retours haptiques en 3 niveaux** et **sons synthétisés doux**, chacun avec un interrupteur dans Profil.
6. **Chorégraphie de validation et hiérarchie des célébrations.**
7. **Maintenir pour compléter** une habitude depuis l'accueil.
8. **Plus aucun saut de mise en page.** Les changements de contenu ou de hauteur sont animés.
9. **« Réduire les animations » respecté partout.** Avec ce réglage système, pas de ressort ni de confettis : les changements sont instantanés ou de simples fondus courts.

## 3. Non-objectifs et anti-objectifs

- **Non-objectifs :**
  - pas de refonte visuelle : maquettes, couleurs, tailles et textes restent identiques ;
  - pas de nouvelle mascotte ni d'animation Rive ou Lottie ;
  - pas de réordonnancement de la liste de l'accueil, car les pilules faites restent à leur place ;
  - pas de tutoriel ni d'astuce de découverte pour le maintien ;
  - pas de transitions de page personnalisées : on garde celles de la plateforme.
- **Anti-objectifs, qui feraient échouer le travail même si tout « marche » :**
  - une app qui fatigue, avec des rebonds partout, des vibrations à chaque scroll ou des sons criards ;
  - une animation qui retarde une action, alors que l'utilisateur ne doit jamais attendre une animation pour enchaîner ;
  - une régression d'accessibilité : cibles de 48 px, Semantics, grand texte ;
  - une saccade : l'app doit rester à 60 ou 120 images/s sur le téléphone de test en release.

## 4. Décisions

### 4.1 Système de mouvement (`lib/core/theme/motion.dart`)

Ressorts nommés, exprimés en durée perçue et rebond :

| Jeton | Durée / rebond | Usage |
|---|---|---|
| `press` | 0,30 s / 0,30 | Remontée après un appui |
| `snappy` | 0,25 s / 0,15 | Indicateurs, curseurs, interrupteur, coches, sélections |
| `smooth` | 0,35 s / 0 | Tailles, contenus qui apparaissent, fondus d'espace |
| `fill` | 0,50 s / 0 | Remplissages : pilules, vague, anneaux, barres, XP |
| `pop` | 0,35 s / 0,45 | Célébrations ponctuelles (pilule à 100 %, avatar, flamme) |

- Les durées et rebonds se convertissent avec `SpringDescription.withDurationAndBounce`.
- **Les effets** (couleurs, opacités) restent des interpolations courtes, sans rebond, sur courbe ease-out (`fast` = 150 ms, `medium` = 220 ms). Plus aucune courbe linéaire ni durée codée en dur dans l'app : tout passe par les jetons.
- **Pas de nouvelle dépendance pour les ressorts.** Le paquet `motor` a été envisagé et écarté (choix du designer). L'app gagne une petite primitive maison réutilisable, un « animateur implicite à ressort » : il reçoit une valeur cible et anime vers elle en conservant sa vitesse quand la cible change. Il fonctionne au moins pour un `double`, avec un contrôleur non borné pour que le rebond ne soit pas rogné.
- **Réduction des animations :** la primitive saute directement à la cible.

### 4.2 Appui

- **Éléments à ombre bonbon** (pilules, bouton principal, boutons ronds pleins, barre de nav, tuiles, puces) :
  - à l'appui, ils descendent de la hauteur de leur ombre et l'ombre se réduit d'autant ;
  - la descente est quasi instantanée, ≈ 60–80 ms ;
  - au relâcher, ils remontent avec le ressort `press`, depuis la position courante ;
  - un tap très bref montre quand même un petit enfoncement visible ;
  - glisser au-delà du seuil de scroll annule l'appui, comme aujourd'hui.
- **Éléments sans ombre** (boutons icônes, lignes de liste, pastilles) :
  - les boutons et pastilles réduisent leur échelle à 0,96, remontée avec `press` ;
  - les lignes de liste prennent une teinte d'appui qui apparaît vite et s'efface en fondu.
- **Aucune onde (splash) dans toute l'app.** Le focus clavier et le survol gardent un état visible.
- `PressScale` est remplacé ou repensé. Son nom et sa forme sont laissés au designer. Les `InkWell` restent pour les gestes et la sémantique, sans splash.

### 4.3 Retours haptiques

Le réglage « Vibrations » de Profil est **activé par défaut**. Les niveaux :

| Niveau | Appel Flutter | Moments |
|---|---|---|
| Tic | `selectionClick` | Onglet de nav, segment de bande, jour de la semaine, couleur, icône, unité, jours du rythme, interrupteurs, pas de l'objectif, humeur, début d'un maintien |
| Léger | `lightImpact` | +1 pas, cocher, décocher, ouvrir les options |
| Succès | `successNotification` | Pilule qui atteint 100 %, fin du minuteur, journée parfaite, montée de niveau, badge ou défi débloqué |

- Les vibrations sont synchronisées avec le pic visuel, c'est-à-dire au début du `pop`.
- Avant Android 11 (API 30), `successNotification` ne fait rien. Le designer prévoit un repli léger : `mediumImpact`, ou une détection de version sans nouvelle dépendance si possible.
- Jamais de vibration pendant un scroll.

### 4.4 Sons

- **Trois sons courts synthétisés par script**, générés en WAV et accordés entre eux :
  - `pop` : +1 pas ;
  - `done` : habitude complétée, deux notes montantes ;
  - `celebrate` : journée parfaite, montée de niveau, badge, petit arpège.
- Ils sont libres de droits par construction. Le script de génération est versionné dans le repo (par exemple `tool/`) pour pouvoir les retoucher.
- **Volume et caractère** : doux, sans attaque sèche, moins de 400 ms, sauf `celebrate` (moins d'1 s).
- **Pas de son** sur les tics de sélection, ni pour décocher.
- **Réglage** : « Sons » dans Profil, **activé par défaut**.
  - Les sons doivent respecter le mode silencieux du téléphone : flux « sonification » sur Android, catégorie *ambient* sur iOS.
  - Il faut le vérifier sur l'appareil.
- **Paquet audio** : choix du designer. Critères : latence perçue inférieure à 50 ms, maintenu, poids raisonnable, respect du mode silencieux. Exemples : `audioplayers` avec un pool basse latence, ou `flutter_soloud`.
- Le lecteur passe par une interface faussable, comme `ReminderScheduler`, pour que les tests n'appellent pas le plugin.

### 4.5 Maintenir pour compléter (accueil)

- **Le tap ne change pas** : +1 pas pour une quantité, cocher ou décocher pour oui/non et fréquence, ouverture de la fiche pour la durée et le journal.
- **Déroulé du maintien sur une pilule active, non faite et modifiable :**
  1. Le doigt reste plus de ≈ 200 ms sans bouger : début de la charge, avec un tic.
  2. Le remplissage progresse de la valeur actuelle jusqu'à 100 % en ≈ 600 ms.
  3. Au bout : valeur = objectif. Cela vaut aussi pour la durée (minutes de l'objectif) et la fréquence (cochée aujourd'hui). Puis chorégraphie de validation (§4.6).
- **Relâcher avant la fin annule.** Le remplissage revient à la valeur réelle avec le ressort `fill`. Un relâcher avant ≈ 200 ms compte comme un tap.
- **Pas de maintien** sur une pilule déjà faite, sur le journal, sur une pilule au repos ou en pause, ni sur un jour futur.
- **Le menu d'options** (pause, archiver, supprimer) passe sur l'**appui long de la pastille icône** de la pilule. Pour les pilules au repos, l'appui long de la pilule entière garde le menu.
- **Accessibilité** : actions Semantics personnalisées « Compléter » et « Options » sur la pilule. Le maintien n'est jamais le seul moyen d'agir.

### 4.6 Chorégraphie de validation et hiérarchie des célébrations

Dans l'ordre de la plus discrète à la plus forte :

1. **+1 pas** (sans atteindre 100 %) : enfoncement, remplissage `fill`, le pourcentage roule vers le haut, tic léger, son `pop`.
2. **Habitude complétée**, par tap ou par maintien :
   - anticipation brève : la pilule se tasse à ≈ 0,97 pendant ≈ 80 ms ;
   - puis `pop` de la pilule (≈ 1,04 puis retour) et du bouton ✓ ;
   - haptique succès et son `done` au pic ;
   - un « +10 XP » s'envole de la pilule vers l'avatar de l'en-tête en ≈ 700 ms, puis s'efface ;
   - l'anneau de l'avatar se remplit (`fill`) et l'avatar fait un petit `pop`.
3. **Journée parfaite** :
   - après le 2, la flamme de série fait un `pop` et son chiffre roule ;
   - puis viennent les confettis existants, haptique succès et son `celebrate` ;
   - les confettis passent sous une `RepaintBoundary` et restent sous 2,2 s.
4. **Montée de niveau** :
   - l'anneau se remplit jusqu'au bout, puis `pop` de l'avatar ;
   - l'anneau repart de 0 vers la nouvelle valeur, au lieu de reculer comme aujourd'hui ;
   - haptique succès et son `celebrate`.

Une célébration ne bloque jamais l'interaction suivante. Un nouveau tap pendant une chorégraphie est pris en compte immédiatement.

Précisions (choix du designer, issus de la relecture) :

- **« Complétée » = `done` de la pilule.** Pour une fréquence hebdomadaire, cocher aujourd'hui sans boucler la semaine joue le niveau 1 : enfoncement, remplissage, tic léger, son `pop` et « +XP » qui s'envole. Le niveau 2 n'arrive que si la semaine est bouclée. Le maintien est possible tant qu'aujourd'hui n'est pas coché.
- **« +XP » montre l'XP réellement gagnée** par l'action : +10, ou +30 quand elle rend la journée parfaite, plus l'XP d'un défi bouclé. Il ne s'envole que depuis l'accueil, où se trouve l'avatar.
- **Deux sources de célébration.**
  - Les **célébrations d'habitude** (`pop`, haptique succès, son `done`) sont jouées par l'écran où l'action a lieu : la pilule sur l'accueil, la vague, l'anneau ou le bouton dans les fiches.
  - Les **célébrations globales** sont détectées par un seul écouteur pour toute l'app, qui compare l'historique d'avant et d'après, comme les confettis aujourd'hui :
    - journée parfaite : seulement pour aujourd'hui, comme maintenant ;
    - montée de niveau ;
    - badge ou défi débloqué.
  - Elles se déclenchent donc aussi depuis une fiche ou un jour passé modifié.
- **Une seule célébration par habitude et par jour** pendant la vie de l'app. Si on coche, décoche puis recoche, la deuxième fois ne joue qu'un retour léger. Même règle pour la journée parfaite, comme les confettis actuels.
- **Retour en arrière** (décocher, Annuler) : les remplissages, l'anneau d'XP et les compteurs reviennent avec `fill` et le défilement des chiffres vers le bas, sans célébration ni son. Une perte de niveau fait reculer l'anneau proprement : il se vide jusqu'à 0, puis repart de plein vers la valeur de l'ancien niveau.

### 4.7 Retour immédiat et message d'annulation

- **Remplissage sans attente.** Le remplissage et le pourcentage d'une pilule reflètent la nouvelle valeur dès le tap, sans attendre l'aller-retour Drift → flux → `historyProvider`. Cela passe par une valeur optimiste locale, remplacée par la vraie quand le flux arrive. En cas d'échec d'écriture, retour à la vraie valeur. Le mécanisme est au choix du designer.
- **Une rafale, un seul message.** Des taps rapides sur la même habitude ne font plus sortir puis rentrer le message d'annulation. Pendant la rafale, le message reste à l'écran, son texte peut se mettre à jour, et « Annuler » revient à la valeur d'**avant la rafale**.
- **Clés stables.** Les pilules de l'accueil sont clés par identifiant d'habitude, pour que l'état animé ne passe plus d'une habitude à l'autre.

### 4.8 Transitions, contenus et tailles

- **Pages :** on garde les transitions de la plateforme. Il faut activer le retour prédictif d'Android (`android:enableOnBackInvokedCallback="true"`) et vérifier qu'il marche avec go_router.
- **Feuilles :** entrée ≈ 350 ms en décélération accentuée, sortie ≈ 250 ms. Le glissement pour fermer garde la vitesse du doigt (comportement Flutter).
- **Onglets de la barre de nav :**
  - fondu enchaîné court sans double image : l'ancien s'efface vite, le nouveau apparaît avec une légère montée ;
  - un changement d'onglet en cours d'animation repart de l'état courant au lieu de redémarrer ;
  - tic haptique ;
  - l'icône passe de Regular à Fill avec un petit `pop`.
- **Changements de contenu** :
  - écrans concernés : bandes Mois/Année, Semaine/Historique, Aujourd'hui/Historique, onglets Trophées, étapes de la feuille joker, panneau de pause, rythme, puces de rappel, bouton du journal, « Cette semaine » de la fréquence ;
  - transition : fondu enchaîné où l'ancien disparaît avant que le nouveau n'apparaisse (*fade-through*), avec un mouvement directionnel quand il y a un sens, comme précédent ou suivant ;
  - hauteur animée avec `smooth`, plus jamais de saut.
- **Nombres** : `RollingText` est utilisé pour tous les nombres qui changent : pas de l'objectif, montant de 60 px, chiffres du minuteur, XP, séries, pourcentages.
  - Le sens dépend du changement : une hausse entre par le bas, une baisse par le haut.
  - Le minuteur roule chiffre par chiffre.
- **Remplissages** : pilules, vague, anneau du minuteur, barres de Progrès et de défis, anneau d'XP.
  - Tous passent par le ressort `fill`.
  - Au changement de période dans Progrès, les barres s'animent en décalé (≈ 30 ms entre deux, ≈ 300 ms au total).
- **Bugs listés par l'audit à corriger :**
  - remontage du bouton oui/non ;
  - couleur du texte des bandes écrasée ;
  - icône + → ✓ qui grossit aussi en sortant ;
  - anneau de niveau qui recule ;
  - durées linéaires ou codées en dur ;
  - « − » de la quantité sans retour d'appui ;
  - boutons lecture/pause et « déjà fait » du minuteur sans retour ;
  - fond du bouton fréquence qui saute.
- **Fin du minuteur** : haptique succès, son `done` et `pop` de l'anneau.

### 4.9 Performance

- **Minuteur** : il ne reconstruit plus tout l'écran chaque seconde. Seuls les chiffres et l'anneau se reconstruisent.
- **Animations** : les éléments qui bougent sont isolés avec `RepaintBoundary` quand c'est utile (confettis, pilules qui animent, anneaux). Pas de `Opacity` ni de flou pendant une animation : utiliser `FadeTransition`.
- **Contrôle** : en mode profile sur le téléphone de test, aucune image ne doit dépasser le budget pendant les chorégraphies de l'accueil ni pendant un changement d'onglet.

### 4.10 Réglages

Deux interrupteurs dans Profil, dans la section des préférences existante :
- « Vibrations » / « Haptics » ;
- « Sons » / « Sounds ».

Ils sont stockés dans la table `settings` existante, comme `rolloverHour`. Les textes vont dans les ARB EN et FR.

## 5. Tests attendus

- **Primitive à ressort :**
  - elle se stabilise sur la cible ;
  - un changement de cible en vol conserve la vitesse, sans saut de valeur ;
  - avec la réduction des animations, elle va directement à la cible.
- **Accueil :**
  - un maintien de plus de 800 ms complète l'habitude ;
  - un relâcher à 400 ms n'écrit rien ;
  - le tap fait toujours +1 ;
  - l'appui long sur la pastille ouvre les options ;
  - les actions Semantics « Compléter » et « Options » marchent ;
  - une rafale de taps produit un seul message, et « Annuler » revient à la valeur d'avant la rafale.
- **Retours :**
  - les appels haptiques sont interceptés (canal plateforme simulé) ;
  - le faux lecteur audio reçoit le bon son au bon moment ;
  - aucun appel quand le réglage est coupé.
- **Profil :** les deux interrupteurs persistent.
- **Bugs de l'audit :** au moins un test de régression pour le remontage oui/non et pour la couleur du texte des bandes.
- **Suite existante :** les 270 tests continuent de passer. Le harnais `pumpApp` fournit le faux lecteur audio.

## 6. Laissé au designer

- Le nom et l'API exacte de la primitive à ressort et du widget d'appui.
- Le mécanisme de valeur optimiste.
- Le paquet audio, selon les critères du §4.4, et la synthèse précise des sons, dans le caractère décrit.
- Le découpage des fichiers. Il faut réutiliser les widgets partagés existants plutôt que dupliquer.
- Les petites valeurs non fixées ici, à régler à l'œil sur l'appareil en restant dans le caractère « vive et ludique, jamais fatigante ».

## 6 bis. Plateformes

Android est la cible vérifiée. Les choix restent compatibles iOS : paquet audio multiplateforme, catégorie *ambient*, appels haptiques Flutter standards. Mais iOS n'est ni construit ni réglé dans ce travail (choix du designer, l'app n'a encore jamais été construite sur iOS).

## 7. Validation sur l'appareil

Une build release est installée sur le téléphone de test (Android 16). L'auteur vérifie alors :
- l'appui, le maintien et la chorégraphie de validation ;
- les onglets, les feuilles, les vibrations et les sons, avec le mode silencieux activé puis désactivé ;
- le minuteur.
