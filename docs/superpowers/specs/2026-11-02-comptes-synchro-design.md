# Comptes, écran d'accueil et synchronisation : conception

Date : 2026-11-02. Version visée : **1.1.0** (versionCode 2), après le test fermé de la 1.0.

## Pourquoi

Little Steps est aujourd'hui 100 % local : sans compte et sans serveur, tout tient dans une base SQLite (Drift) sur le téléphone. Si on change de téléphone, on perd ses séries, sauf à passer par l'export JSON manuel. On ne peut pas non plus utiliser l'app sur deux appareils.

L'auteur veut un **écran d'accueil** avec quatre façons d'entrer : e-mail et mot de passe, Google, Apple, ou **hors ligne**. Un compte doit servir à **sauvegarder et synchroniser** les habitudes : on retrouve tout sur un nouveau téléphone, et plusieurs appareils restent à jour.

## Objectifs

- Un écran d'accueil au premier lancement (direction A3, voir plus bas) : Google, Apple, e-mail et « Continuer sans compte ».
- Les comptes passent par Firebase Auth : e-mail et mot de passe, Google, Apple.
- Synchronisation bidirectionnelle de toutes les données entre les appareils d'un même compte. L'app continue de fonctionner hors ligne et se resynchronise dès qu'elle retrouve le réseau.
- Le mode sans compte reste complet. On peut créer un compte plus tard depuis le Profil, et les données locales y sont alors envoyées sans perte.
- Dans le Profil : l'état du compte, se déconnecter, supprimer son compte.

## Non-objectifs

- Pas de Premium ni d'achat intégré : c'est le bloc 4, et `premiumOffered` reste à `false`.
- Pas de partage entre utilisateurs, pas de social, pas de web.
- Pas de version iOS livrée dans ce chantier. Le code reste compatible iOS, mais le build iOS n'est pas fait ici.
- Pas de fusion des doublons « intelligente ». Deux habitudes « Lire » créées séparément sur deux téléphones restent deux habitudes.

## Anti-objectifs

Ce chantier est un échec, même si tout marche techniquement, si l'un de ces points arrive :

- **une perte de données.** Une série, une entrée ou une habitude disparaît à la connexion, à la fusion, à une synchro ou à une mise à jour. C'est la règle numéro un.
- **le compte devient obligatoire, en pratique.** Ça arrive si le mode hors ligne est dégradé, caché ou harcelé de rappels.
- **l'app attend le réseau.** Le chargement, un tap ou une validation ne doivent jamais bloquer sur Internet. Tout reste instantané et local.
- **la politique de confidentialité ou la fiche Play mentent.** Elles doivent décrire exactement ce que fait la 1.1.

## Décisions de l'auteur

| Sujet | Décision |
|---|---|
| Rôle du compte | Sauvegarde et synchronisation entre appareils |
| Backend | Firebase : Auth et Firestore |
| Hors ligne | Sans compte, on peut le lier plus tard en gardant les données locales |
| Calendrier | Mise à jour 1.1, après le test fermé de la 1.0 |
| Écran d'accueil | **Direction A3** (voir maquette) |
| Boutons | Icône à gauche dans une case fixe, puis un **séparateur vertical**, puis le texte centré |
| Écran e-mail et Profil | Le **langage des pilules** (maquette `email-and-profile-v3`) |
| Données à la connexion, des deux côtés | **Tout fusionner** : pour une même entrée, la plus récente gagne |
| Déconnexion | Les données sont **effacées du téléphone**, qui revient à l'écran d'accueil. Elles restent dans le compte |
| Apple | **Dès la 1.1**. L'auteur crée un compte Apple Developer |
| Vérification de l'e-mail | Un e-mail de confirmation est **envoyé, sans bloquer**. Un rappel discret reste dans le Profil tant que l'adresse n'est pas confirmée |
| Import JSON quand on est connecté | **Il fusionne dans le compte**, comme une première connexion : union, et pour un même document le plus récent gagne. Un vieux fichier ne peut rien effacer. Sans compte, l'import garde son comportement actuel (tout remplacer après confirmation) |
| Suppression contre validations faites hors ligne | **La suppression gagne.** Une habitude supprimée l'est partout, y compris les jours validés entre-temps sur un appareil hors ligne. Les entrées et pauses reçues pour une habitude supprimée ou inconnue sont ignorées et marquées supprimées |

## Écrans

Les maquettes validées sont dans `.superpowers/brainstorm/1447873-1793635203/content/` : `welcome-a-v4.html` (variante A3) et `email-and-profile-v3.html`. Tous les écrans suivent le thème Sorbet existant : Sour Gummy, fond `#FFF0F4`, encre `#3A1B2E`, accent `#E0597E`, pastels des habitudes.

### Accueil (A3)

- **En haut**, l'illustration des trois pilules en escalier (menthe, ciel, lilas) avec l'étincelle, comme sur l'icône. Dessous, « Little Steps » et « Petites habitudes, grandes séries. »
- **En bas, empilés :**
  - « Continuer avec Google » et « Continuer avec Apple » : deux boutons **blancs identiques**, avec leur ombre-pilule ;
  - « Continuer avec un e-mail » : le bouton **accent** ;
  - « Continuer sans compte » : un lien souligné ;
  - une note : « Sans compte, tout reste sur ce téléphone. Tu pourras en créer un plus tard. »
- **Anatomie des trois boutons :**
  - l'icône à gauche, dans une case fixe d'environ 52 dp ;
  - un **séparateur vertical**, couleur bordure sur les boutons blancs, blanc translucide sur l'accent ;
  - le texte centré dans le reste du bouton.
- **Logos :** les officiels. Le « G » Google en quatre couleurs. La pomme Apple **noire sur le bouton blanc**, ce qui correspond au style « blanc » autorisé par Apple. L'enveloppe en blanc sur l'accent.
- L'accueil s'affiche **uniquement** si le téléphone n'a ni compte connecté ni données locales. Un utilisateur de la 1.0 qui fait la mise à jour arrive directement sur « Aujourd'hui ».
- **Appui :** l'enfoncement `PressSink` déjà utilisé dans l'app. Pendant une connexion, le bouton touché affiche un indicateur de chargement, et les autres sont désactivés.

### E-mail

- **En haut :**
  - un bouton retour rond ;
  - les trois pilules de l'accueil en petit, en écho ;
  - le titre « Crée ton compte » (ou « Content de te revoir » en connexion) et une phrase de contexte.
- **Les champs sont des pilules**, avec la même anatomie qu'une habitude : pastille d'icône, libellé discret, valeur.
  - Pilule e-mail : elle se remplit en **ciel** et affiche un ✓ (la pastille sombre d'une habitude faite) dès que l'adresse est valable.
  - Pilule mot de passe : elle se remplit en **menthe** selon sa solidité, affiche un badge « Faible / Moyen / Solide » et un œil pour afficher le texte.
  - Le remplissage utilise le ressort `fill` existant.
- Le bouton « Créer mon compte » ou « Me connecter » se trouve **juste sous les champs**, pour rester visible au-dessus du clavier.
- **En bas :**
  - « Déjà un compte ? Me connecter » / « Pas encore de compte ? Créer un compte » ;
  - en mode connexion, « Mot de passe oublié ? » ;
  - une mention sur les données.
- **Erreurs** (adresse déjà utilisée, mot de passe faux, pas de réseau) : une phrase claire sous la pilule concernée ou dans un message, avec la façon de corriger. Pas d'excuse ni de message vague.

### Profil

- **La pilule du compte**, en tête, sous l'en-tête avatar :
  - **sans compte** : vide, pastille nuage, « Sauvegarde tes séries / Crée un compte, rien n'est perdu », et un « + » à droite comme une habitude à faire. La toucher ouvre une feuille avec les trois boutons de l'accueil ;
  - **connecté et synchronisé** : pleine en lilas, ✓ sombre, « Synchronisé / il y a 2 min » ;
  - **synchronisation en cours** : elle se remplit au fil de l'envoi ;
  - **hors ligne ou erreur** : un état neutre, « En attente de réseau », sans alarme.
- **Connecté**, l'en-tête montre le prénom et l'e-mail. Tant que l'adresse n'est pas confirmée, une ligne discrète propose « Confirme ton adresse e-mail (renvoyer) ».
- **Tout en bas, discrets :** « Se déconnecter » en lien, puis « Supprimer mon compte » en rouge et petit, avec une confirmation explicite.

## Architecture

### Principe : Drift reste la source de vérité

L'app continue de lire et d'écrire uniquement dans Drift : les écrans, les flux et les tests ne changent pas de modèle. Firestore sert de **réplique distante**. Un `SyncService` envoie les changements locaux et applique les changements distants. Sans compte, ce service est inactif et l'app se comporte exactement comme la 1.0.

### Identifiants globaux (migration Drift v4)

Les identifiants entiers auto-incrémentés entrent en collision d'un appareil à l'autre. La migration v4 ajoute donc :

- `habits.uid` et `pauses.uid` : un texte UUID v4, unique, rempli pour les lignes existantes.
- Les entrées restent identifiées par `(habit uid, jour)`, les jokers par le jour, les réglages par leur clé.
- `updatedAt` (millisecondes) sur chaque table synchronisée, mis à jour à chaque écriture.
- Une table **`outbox`** : `(collection, clé du document, opération upsert|delete, updatedAt)`. Le repository y écrit **dans la même transaction** que chaque modification, suppressions comprises (la suppression en cascade d'une habitude ajoute aussi ses entrées et ses pauses).

Les identifiants entiers restent les clés locales, ce qui évite de réécrire le code existant. Le `uid` sert de clé distante.

### Firestore

```
users/{userId}
  habits/{habitUid}        champs de l'habitude + updatedAt + deleted
  entries/{habitUid_day}   value, note, mood, day, habitUid + updatedAt + deleted
  pauses/{pauseUid}        habitUid, fromDay, toDay + updatedAt + deleted
  jokers/{day}             updatedAt + deleted
  settings/{key}           value + updatedAt + deleted
```

- **Suppressions :** une suppression devient une **pierre tombale** (`deleted: true`), pour qu'elle se propage aux autres appareils.
- **Conflits :** **la dernière écriture gagne, document par document**, en comparant `updatedAt`. Une entrée (habitude, jour) est un document, donc deux appareils qui valident des jours différents ne se gênent jamais.
- **Réglages synchronisés :** prénom, vibrations, sons, début de journée.
- **Réglages qui restent sur l'appareil :** l'état des permissions de notification, les identifiants de notifications planifiées et la marque « accueil vu ». La liste exacte est arrêtée par le constructeur.
- **Règles de sécurité :** un utilisateur ne lit et n'écrit que sous `users/{son uid}/**`.
- **Région :** Europe (`eur3`), parce que les utilisateurs et le RGPD sont européens.

### SyncService

- **Démarrage :** à la connexion, au lancement si une session existe, et quand le réseau revient.
- **Envoi :** il vide l'outbox par lots (batch Firestore, au plus 500 opérations), en ne retirant une ligne qu'une fois l'écriture confirmée.
- **Réception :** il écoute les collections de l'utilisateur. Pour chaque document reçu plus récent que la ligne locale, il l'applique dans Drift **sans le remettre dans l'outbox**. Il retrouve la ligne locale par son `uid` et la crée si besoin.
- **Première connexion avec des données des deux côtés :**
  1. tout le local entre dans l'outbox ;
  2. on télécharge tout le distant et on l'applique selon « le plus récent gagne » ;
  3. on envoie l'outbox.

  Résultat : l'union des deux, et aucune perte.
- **Effets de bord :** les rappels se resynchronisent seuls (`ReminderSync` écoute les flux). Les célébrations ne doivent **pas** se déclencher sur des données reçues : on réutilise le mécanisme `dataReplacedProvider` de l'import, ou un équivalent.
- **Indicateur du Profil :** un état exposé `idle | syncing(fraction) | upToDate(at) | offline | error`.

### Authentification

`firebase_auth` gère les trois méthodes :

- **E-mail et mot de passe :** création, connexion, e-mail de vérification envoyé sans bloquer, réinitialisation du mot de passe.
- **Google :** le flux natif Android. Il exige d'enregistrer dans Firebase les empreintes SHA-1 et SHA-256 de la clé d'upload **et** de la clé Play App Signing.
- **Apple :** sur Android, le flux OAuth web de Firebase (`AppleAuthProvider`). Il faut un Services ID, une clé et le domaine de retour configurés côté Apple Developer et Firebase.

Autres règles :

- **Session :** elle est conservée par Firebase. Au lancement, l'app décide entre l'accueil, « Aujourd'hui » sans compte et « Aujourd'hui » connecté sans attendre le réseau, à partir de l'état local.
- **Déconnexion :** on vide l'outbox, en prévenant si elle n'est pas vide et qu'on est hors ligne. Puis on se déconnecte, on **efface la base locale** et on revient à l'accueil.
- **Suppression du compte :** il faut une connexion récente (Firebase redemande l'identification si besoin). Ensuite on supprime tous les documents `users/{uid}`, puis l'utilisateur Auth, puis la base locale, et on revient à l'accueil. En plus, une page web publique explique comment demander la suppression sans l'app : c'est une exigence de Google Play.

## Mises à jour hors du code (dans ce chantier)

- **Politique de confidentialité** (`docs/privacy.html`, FR et EN). Elle doit décrire :
  - le compte facultatif ;
  - les données stockées chez Firebase (Google) et leur région ;
  - le chiffrement en transit ;
  - la suppression du compte (dans l'app et via la page web) ;
  - les fournisseurs d'identité Google et Apple.
- **Nouvelle page** `docs/delete-account.html` : comment supprimer son compte, depuis l'app ou par e-mail.
- **`docs/store/play-console.md`** :
  - la fiche (« sans compte » devient « compte facultatif ») ;
  - le formulaire **Sécurité des données** : e-mail, identifiants et données d'activité de l'app collectés pour faire fonctionner l'app, non partagés, chiffrés en transit, suppression possible, lien vers la page de suppression ;
  - les notes de version 1.1.
- `version: 1.1.0+2`.

## Ce que l'auteur doit faire (hors de portée de Claude)

1. Créer un **projet Firebase**, y ajouter l'app Android `dev.golden.littlesteps` et activer Auth (e-mail, Google, Apple) ainsi que Firestore en région Europe.
2. Récupérer `google-services.json`. Il est versionné dans le repo : ce n'est pas un secret, la sécurité repose sur les règles Firestore.
3. Ajouter dans Firebase les empreintes SHA-1 et SHA-256 de la clé d'upload et de la clé **Play App Signing**, visibles dans la Play Console.
4. Créer le **compte Apple Developer** (99 $/an), puis l'App ID, le Services ID, la clé Sign in with Apple et l'URL de retour Firebase.
5. Déployer les règles Firestore (le fichier est fourni dans le repo).

Le constructeur fournit pour chaque étape un pas-à-pas précis. Le code doit compiler et ses tests passer **sans** projet Firebase réel : les services sont injectés par des providers et remplacés par des faux dans les tests.

## Tests attendus

- **Migration v4** : les `uid` et `updatedAt` sont remplis, aucune donnée perdue. Le test de migration Drift existant est étendu.
- **Outbox** : chaque écriture du repository produit l'opération attendue (upsert ou suppression, cascade comprise) dans la même transaction.
- **Fusion à la première connexion**, avec un faux Firestore en mémoire : local seul, distant seul, les deux, et un conflit sur la même entrée (le plus récent gagne). Aucune perte dans aucun cas.
- **Réception** : un changement distant mis à jour, puis supprimé, se reflète localement sans repasser dans l'outbox et sans célébration.
- **Écrans** :
  - accueil : les quatre boutons, l'accessibilité et les cibles de 48 px, le passage par « sans compte » ;
  - e-mail : la validation des pilules, les erreurs, le mode connexion ;
  - Profil : les états de la pilule compte ;
  - déconnexion : les données locales sont effacées.
- **Démarrage** : un utilisateur de la 1.0 avec des données ne voit pas l'accueil.
- **Import connecté** : il fusionne, et un vieux fichier n'efface rien.
- **Conflit suppression contre validation hors ligne** : la suppression gagne, et rien d'orphelin ne reste en base.
- **Déconnexion** : bloquée tant que l'outbox n'est pas vide.
- La suite existante (374 tests) reste verte, et la CI aussi. Elle continue de construire l'APK **sans** `google-services.json`, avec une configuration Firebase factice ou un plugin Gradle rendu optionnel.

## Choix de conception (faits par Claude, à vérifier)

- **Déconnexion avec des changements non envoyés :** elle est **bloquée** tant que l'outbox n'est pas vide. Message : « Reconnecte-toi à Internet pour envoyer tes derniers changements, puis déconnecte-toi. » Il n'y a pas de « déconnecter quand même », parce que ça effacerait des données (anti-objectif n° 1).
- **Un compte par adresse e-mail** (réglage par défaut de Firebase). Prenons quelqu'un qui a créé son compte par e-mail et mot de passe, puis touche « Continuer avec Google » avec la même adresse. Erreur `account-exists-with-different-credential` : l'app lui demande de se connecter avec la méthode d'origine, puis lie automatiquement Google à son compte. Apple peut masquer l'adresse (relais privé) : ce compte-là reste distinct, c'est une limite connue.
- **Format d'export v2 :** il ajoute `uid` et `updatedAt`, pour qu'un fichier réimporté ne crée pas de doublons. Les fichiers v1 restent acceptés : leurs lignes reçoivent alors des `uid` neufs.
- **Ordre des habitudes :** `position` est un champ de l'habitude comme les autres, donc le plus récent gagne. Deux réordonnancements simultanés peuvent laisser un ordre mélangé, sans perte.
- **Jokers :** l'union des jours des deux côtés.

## Laissé au constructeur

- La bibliothèque UUID, ou un UUID maison tiré d'un générateur sécurisé.
- Les détails de batching et de reprise de l'outbox, et la reconnexion au réseau (`connectivity_plus` ou les flux Firestore).
- La liste exacte des réglages synchronisés ou locaux.
- Les textes FR et EN des écrans, en tutoiement et dans la voix de l'app.
- Le découpage du code (`lib/core/sync/`, `lib/features/welcome/`, `lib/features/auth/`…).
