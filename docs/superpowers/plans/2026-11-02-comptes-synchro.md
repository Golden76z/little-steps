# Comptes, accueil et synchronisation : plan d'implémentation

> **Pour les agents :** exécuter avec `superpowers:executing-plans`, selon les règles du CLAUDE.md global.
> - T1 d'abord.
> - Puis T2, T3 et T4 **en parallèle**, un sous-agent par tâche, chacun dans son worktree, fusionnés par l'orchestrateur.
> - T4 n'a aucune dépendance et peut partir en même temps que T1.
> - Pas de revue par tâche, pas de commit par tâche : un seul commit à la fin. Rapport de 10 lignes au plus par sous-agent.

**But :** la version 1.1.0, avec un écran d'accueil (Google, Apple, e-mail ou sans compte), des comptes Firebase et une synchronisation bidirectionnelle entre appareils, sans jamais perdre de données ni dépendre du réseau.

**Architecture :** Drift reste la source de vérité.
- Chaque écriture du repository horodate la ligne et ajoute une opération dans une table `outbox`, dans la même transaction.
- Un `SyncService` vide l'outbox vers Firestore et applique les documents reçus selon « le plus récent gagne ».
- Les suppressions d'habitude gagnent toujours.
- L'authentification passe par une interface `AuthService`. L'implémentation Firebase n'est active que si la configuration Firebase existe. Sinon, et dans les tests, l'app reste en mode local et des faux prennent le relais.

**Stack :**
- l'existant : Flutter 3.47, Riverpod 3, go_router 18, Drift 2.35 ;
- nouvelles dépendances : `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in` (sélecteur de compte natif), `uuid`.

**Spec :** `docs/superpowers/specs/2026-11-02-comptes-synchro-design.md`. Chaque tâche la lit en entier, ainsi que ses tableaux « Décisions » et « Choix de conception ».

## Contraintes globales

- **Rien n'attend le réseau.** Le démarrage, les taps et les validations restent locaux. Le réseau ne sert qu'en tâche de fond, et pour l'écran de connexion lui-même.
- **Aucune perte de données.** Les migrations, la fusion, l'import et la synchro sont tous testés avec des données des deux côtés.
- **La déconnexion est refusée** tant que l'outbox n'est pas vide.
- **Les suppressions d'habitude gagnent** sur les entrées et les pauses reçues après coup.
- **Sans configuration Firebase**, l'app compile, les tests passent, la CI construit l'APK, et l'app tourne en mode local, accueil compris.
- **Aucun secret** dans le repo. Les clés sont fournies par l'auteur, et la sécurité repose sur `firestore.rules`.
- **Région Firestore** `eur3`.
- **Règles qui ne changent pas :**
  - textes uniquement via les ARB FR/EN, en tutoiement ;
  - durées via les jetons de `motion.dart` ;
  - nouvelles routes avec `pageBuilder: (_, state) => _page(state, …)` ;
  - cibles de 48 dp et Semantics sur tout ce qui se touche ;
  - `premiumOffered` reste à `false`.
- `version: 1.1.0+2`.

## Points de revue

Cinq cas que la spec implique sans les nommer. Chacun a un test dans la tâche qui en est propriétaire :

1. **Mise à jour depuis la 1.0 avec des données** :
   - la migration v4 garde tout (T1) ;
   - l'accueil ne s'affiche pas et l'utilisateur arrive sur « Aujourd'hui » (T3).
2. **Lancement hors ligne avec une session** : « Aujourd'hui » s'affiche tout de suite, et la synchro reste en attente sans erreur bloquante (T2, T3).
3. **Fusion interrompue** (app tuée ou réseau coupé au milieu de la première connexion) : l'outbox est persistante, la reprise termine la fusion et ne crée aucun doublon (T2).
4. **Deux appareils modifient la même entrée hors ligne** : le plus récent gagne de façon déterministe, et un document appliqué depuis le distant ne repart jamais dans l'outbox, donc pas de ping-pong (T1, T2).
5. **Suppression du compte quand Firebase exige une connexion récente** : on redemande l'identification. Rien n'est effacé localement tant que la suppression distante n'a pas réussi (T2, T3).

---

### Tâche 1 : données synchronisables et contrats

Aucune dépendance. Elle bloque T2 et T3.

**Fichiers :**
- **Modifier :**
  - `lib/core/database/app_database.dart` : schemaVersion 4, `from3To4`, table `Outbox` ;
  - `lib/core/database/habit_repository.dart` ;
  - `lib/core/database/backup.dart` : format v2 ;
  - `lib/core/database/providers.dart` ;
  - `lib/core/widgets/celebrations.dart` : prise en compte des changements distants.
- **Générer :**
  - `app_database.g.dart` et `.steps.dart` (via `dart run build_runner build -d`) ;
  - `drift_schemas/app_database/drift_schema_v4.json` et `test/database/app_database/generated/*` (via `dart run drift_dev make-migrations`).
- **Créer :**
  - `lib/core/sync/sync_doc.dart` ;
  - `lib/core/sync/remote_store.dart` ;
  - `lib/core/sync/sync_status.dart` ;
  - `lib/core/auth/auth.dart` ;
  - `test/fakes/fake_auth.dart` ;
  - `test/fakes/memory_remote_store.dart`.
- **Tests :**
  - `test/database/app_database/migration_test.dart` : v1→…→v4, avec données ;
  - `test/database/outbox_test.dart` ;
  - `test/database/apply_remote_test.dart` ;
  - `test/database/backup_test.dart` : v2, lecture de v1, fusion.

**Interfaces produites (utilisées par T2 et T3) :**

```dart
// sync_doc.dart
enum SyncCollection { habits, entries, pauses, jokers, settings }
final class SyncDoc {
  const SyncDoc({required this.collection, required this.id, required this.data,
    required this.updatedAt, this.deleted = false});
  final SyncCollection collection;
  final String id;              // habits/pauses: uid ; entries: '${habitUid}_${day}' ; jokers: day ; settings: clé
  final Map<String, Object?> data; // champs sérialisables JSON (jours en 'AAAA-MM-JJ', comme backup.dart)
  final int updatedAt;          // ms depuis l'époque, horloge de l'appareil
  final bool deleted;
}

// habit_repository.dart — ajouts
Future<List<SyncDoc>> pendingChanges({int limit = 400}); // outbox → documents à pousser (état actuel de la ligne, ou tombe)
Future<void> markPushed(List<SyncDoc> docs);              // retire de l'outbox les opérations <= updatedAt poussé
Stream<int> watchPendingCount();
Future<void> applyRemote(List<SyncDoc> docs); // le plus récent gagne ; n'écrit JAMAIS dans l'outbox ;
                                              // habitude supprimée => cascade locale ; entrées/pauses orphelines ignorées
Future<void> enqueueAll();                    // tout le local dans l'outbox (1re connexion, import fusionné)
Future<void> mergeBackup(Backup b);           // import connecté : applyRemote(b) puis enqueue de ce qui a gagné
Future<void> wipeLocal();                     // vide toutes les tables, outbox comprise
Future<bool> hasLocalData();                  // au moins une habitude (archivées comprises)

// remote_store.dart
abstract interface class RemoteStore {
  Future<void> push(String userId, List<SyncDoc> docs);  // un batch, <= 500 ops
  Future<List<SyncDoc>> fetchAll(String userId);
  Stream<List<SyncDoc>> watch(String userId);            // changements distants
  Future<void> deleteAll(String userId);
}

// sync_status.dart
sealed class SyncStatus {}
final class SyncOff extends SyncStatus {}                       // pas de compte
final class SyncWaiting extends SyncStatus { SyncWaiting(this.pending); final int pending; } // hors ligne
final class SyncRunning extends SyncStatus { SyncRunning(this.fraction); final double fraction; }
final class SyncUpToDate extends SyncStatus { SyncUpToDate(this.at); final DateTime at; }
final class SyncFailed extends SyncStatus { SyncFailed(this.message); final String message; }

// auth.dart
final class AppUser { const AppUser({required this.uid, this.email, this.displayName,
  this.emailVerified = false, this.providers = const {}}); final String uid; final String? email;
  final String? displayName; final bool emailVerified; final Set<String> providers; }
enum AuthFailureKind { emailInUse, wrongPassword, userNotFound, weakPassword, invalidEmail,
  network, cancelled, needsRecentLogin, existsWithOtherMethod, unavailable, unknown }
final class AuthFailure implements Exception { const AuthFailure(this.kind, {this.otherMethod});
  final AuthFailureKind kind; final String? otherMethod; } // otherMethod: 'google.com' | 'password' | 'apple.com'
abstract interface class AuthService {
  bool get available;                       // false sans configuration Firebase
  Stream<AppUser?> watchUser();
  AppUser? get currentUser;
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithApple();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> createAccount(String email, String password); // envoie la vérification, sans bloquer
  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<void> deleteUser();                // lève AuthFailure(needsRecentLogin) au besoin
}
// providers.dart — ajouts
final authServiceProvider = Provider<AuthService>((ref) => UnavailableAuthService()); // T2 le remplace
final currentUserProvider = StreamProvider<AppUser?>((ref) => ref.watch(authServiceProvider).watchUser());
final remoteStoreProvider = Provider<RemoteStore?>((ref) => null);                    // T2 le remplace
final remoteAppliedProvider = NotifierProvider<RemoteApplied, int>(RemoteApplied.new); // incrémenté après chaque applyRemote
final syncStatusProvider = Provider<SyncStatus>((ref) => SyncOff());                  // T2 le remplace
```

- `UnavailableAuthService` vit dans `auth.dart` : `available` vaut `false`, `watchUser` émet `null`, et toutes les actions lèvent `AuthFailure(unavailable)`.
- Les faux de test produits sont `FakeAuthService`, avec des comptes en mémoire et des échecs programmables, et `MemoryRemoteStore`.

**Étapes :**

- [ ] **1. Écrire les tests en échec.**
  - **Migration :** une base v3 avec 2 habitudes, des entrées, une pause, un joker et des réglages devient v4 sans rien perdre. `uid` est rempli et unique, `updatedAt` est différent de 0.
  - **Outbox :** chaque méthode d'écriture produit exactement l'opération attendue, dans la même transaction : createHabit, updateHabit, setEntry, clearEntry, useJoker, setSetting, pauseHabit, resumeHabit, reorder, archive. `deleteHabit` produit la tombe de l'habitude et de toutes ses entrées et pauses. Un réglage de la liste locale (`localOnlySettings`) ne produit rien.
  - **applyRemote :**
    - un document plus récent remplace la valeur locale, un plus ancien est ignoré ;
    - rien n'arrive dans l'outbox (**point de revue 4**) ;
    - une tombe d'habitude supprime l'habitude, ses entrées et ses pauses ;
    - une entrée reçue pour une habitude supprimée ou inconnue est ignorée ;
    - `remoteAppliedProvider` est incrémenté.
  - **Fusion :** `enqueueAll` puis un aller-retour par `MemoryRemoteStore` donne l'union, sans doublon.
  - **Backup :** l'export v2 contient `uid` et `updatedAt`. Un fichier v1 est encore lu (avec des `uid` neufs). `mergeBackup` d'un vieux fichier n'écrase pas une valeur plus récente.
  - **Célébrations :** après un `applyRemote` qui apporte un niveau, un badge ou une journée parfaite, rien n'est joué.
- [ ] **2. Vérifier que ces tests échouent.**
  - Lancer `flutter test test/database test/features/celebrations_test.dart`.
  - Attendu : échecs.
- [ ] **3. Implémenter les interfaces ci-dessus.**
  - **Horodatage :** `updatedAt` est rempli par le repository (horloge `clockProvider` injectable). Les identifiants entiers restent les clés locales.
  - **Liste `localOnlySettings`**, à placer dans `sync_doc.dart` : la marque « accueil vu » (`welcomeDone`), et tout ce qui décrit l'appareil (permissions, planification). Le prénom, les vibrations, les sons et le début de journée sont synchronisés.
  - **Célébrations :** `Celebrations` écoute `remoteAppliedProvider` comme un import, pour reprendre sa base de référence. Pour un changement distant, ni les sessions de minuteur ni `pendingEntries` ne sont remis à zéro.
- [ ] **4. Vérifier la suite.**
  - Lancer `dart run build_runner build -d && flutter analyze && flutter test`.
  - Attendu : aucun problème, `All tests passed!`.

---

### Tâche 2 : Firebase, authentification et SyncService

Dépend de T1. Peut tourner en parallèle de T3 et T4.

**Fichiers :**
- **Modifier :**
  - `pubspec.yaml` : dépendances et `version: 1.1.0+2` ;
  - `lib/main.dart` : `Firebase.initializeApp` seulement si la configuration existe, sinon local ;
  - `lib/core/database/providers.dart` : brancher les implémentations ;
  - `android/app/build.gradle.kts` et `android/settings.gradle.kts`, seulement si `google_sign_in` l'exige, et sans casser la build sans `google-services.json` ;
  - `.github/workflows/ci.yml`, seulement si nécessaire.
- **Créer :**
  - `lib/core/firebase/firebase_config.dart` : `FirebaseOptions? get firebaseOptions`, qui renvoie `null` tant que l'auteur n'a pas lancé `flutterfire configure`. Prévoir le branchement vers `lib/firebase_options.dart` généré ;
  - `lib/core/auth/firebase_auth_service.dart` ;
  - `lib/core/sync/firestore_remote_store.dart` ;
  - `lib/core/sync/sync_service.dart` ;
  - `firestore.rules` ;
  - `firebase.json`.
- **Tests :**
  - `test/core/sync_service_test.dart`, avec `FakeAuthService` et `MemoryRemoteStore` ;
  - `test/core/firebase_auth_mapping_test.dart` : codes d'erreur Firebase vers `AuthFailureKind`.

**Interfaces :**
- **Utilise :** tout le bloc « Interfaces produites » de T1.
- **Produit (pour T3) :**

```dart
// sync_service.dart
final syncServiceProvider = Provider<SyncService>(...); // démarre/arrête tout seul selon currentUserProvider
class SyncService {
  Future<void> signOut();        // lève SignOutBlocked si pendingCount > 0 et pas de push possible ; sinon wipeLocal + signOut
  Future<void> deleteAccount();  // remote.deleteAll -> auth.deleteUser -> wipeLocal ; needsRecentLogin remonte AVANT tout effacement
  Future<void> syncNow();
}
final class SignOutBlocked implements Exception { const SignOutBlocked(this.pending); final int pending; }
// providers.dart : authServiceProvider, remoteStoreProvider, syncStatusProvider réels quand firebaseOptions != null
```

**Étapes :**

- [ ] **1. Écrire les tests en échec** (`sync_service_test.dart`).
  - **Première connexion, tous les cas** : local seul, distant seul, les deux, et le même document des deux côtés (le plus récent gagne). Dans tous les cas, l'union des données et rien de perdu.
  - **Point de revue 3** : un push qui échoue au milieu de la fusion, puis la reprise, donne l'état final complet, sans doublon.
  - **Réception** : un document distant est appliqué. Le statut passe par `SyncRunning` puis `SyncUpToDate`.
  - **Point de revue 2** : hors ligne, avec le store qui lève une erreur réseau, le statut est `SyncWaiting(n)`, rien ne lève jusqu'à l'UI, et l'écriture locale reste immédiate.
  - **Point de revue 4** : deux faux appareils partagent un même `MemoryRemoteStore`, modifient la même entrée hors ligne, puis se reconnectent. Les deux convergent vers la plus récente, et l'outbox finit vide des deux côtés.
  - **Conflit suppression** : A supprime l'habitude, B valide un jour hors ligne puis se resynchronise. L'habitude et ses entrées disparaissent sur A comme sur B.
  - **`signOut`** :
    - avec l'outbox non vide et hors ligne, il lève `SignOutBlocked` et ne change rien ;
    - avec l'outbox vide, la base locale est vidée et l'utilisateur vaut `null`.
  - **Point de revue 5** : si `deleteAccount` reçoit `needsRecentLogin`, aucune donnée locale ni distante n'est effacée.
  - **Mapping des erreurs Firebase**, dont `account-exists-with-different-credential` vers `existsWithOtherMethod`, en gardant la méthode d'origine.
- [ ] **2. Vérifier que ces tests échouent.**
  - Lancer `flutter test test/core/sync_service_test.dart test/core/firebase_auth_mapping_test.dart`.
  - Attendu : échecs.
- [ ] **3. Implémenter.**
  - **Google** : `google_sign_in`, puis `GoogleAuthProvider.credential`.
  - **Apple** : `FirebaseAuth.signInWithProvider(AppleAuthProvider())` (flux web sur Android).
  - **Liaison de comptes** : sur `existsWithOtherMethod`, conserver la credential en attente. Après connexion avec la méthode d'origine, appeler `linkWithCredential` (spec, « Choix de conception »).
  - **Firestore** : l'implémentation suit le schéma `users/{uid}/{collection}/{docId}` de la spec. `watch` part de `updatedAt > dernier appliqué`.
  - **`firestore.rules`** : lecture et écriture uniquement sous `users/{request.auth.uid}/**`.
  - **Pas de configuration Firebase** : `authServiceProvider` reste `UnavailableAuthService` et `syncStatusProvider` reste `SyncOff`.
- [ ] **4. Vérifier la suite.**
  - Lancer `flutter analyze && flutter test && flutter build apk --debug`, **sans** `google-services.json` ni `firebase_options.dart`.
  - Attendu : aucun problème, `All tests passed!`, et l'APK construit.

---

### Tâche 3 : écrans (accueil, e-mail, compte dans le Profil, import)

Dépend de T1. Peut tourner en parallèle de T2 et T4. Elle n'utilise de T2 que le contrat `SyncService` (`signOut`, `deleteAccount`, `SignOutBlocked`) : la coder contre un faux `SyncService` injecté par provider.

**Fichiers :**
- **Créer :**
  - `lib/features/welcome/welcome_screen.dart` ;
  - `lib/features/welcome/provider_button.dart` : le bouton « icône | séparateur | texte » ;
  - `lib/features/auth/email_screen.dart` ;
  - `lib/features/auth/pill_field.dart` ;
  - `lib/features/profile/account_pill.dart` ;
  - `assets/logos/google.png` et `assets/logos/apple.png`, en 1x, 2x et 3x, tirés des kits officiels (logo Google « G » multicolore, logo Apple noir).
- **Modifier :**
  - `lib/core/router/app_router.dart` : routes `/welcome` et `/auth/email`, et une redirection initiale ;
  - `lib/features/profile/profile_screen.dart` ;
  - `lib/features/profile/data_sheet.dart` : import fusionné quand on est connecté ;
  - `lib/l10n/app_en.arb` et `app_fr.arb` ;
  - `pubspec.yaml`, **assets uniquement**. T2 possède les dépendances : en cas de conflit, l'orchestrateur fusionne.
- **Tests :**
  - `test/features/welcome_test.dart` ;
  - `test/features/email_screen_test.dart` ;
  - `test/features/account_pill_test.dart` ;
  - `test/features/data_sheet_test.dart` : cas connecté ;
  - `test/app_shell_test.dart` : redirection.

**Interfaces :**
- **Utilise :** T1 (`AuthService`, `AppUser`, `AuthFailure`, `currentUserProvider`, `syncStatusProvider`, `hasLocalData`, `mergeBackup`) et le contrat `SyncService` de T2.
- **Produit :** rien pour les autres tâches.

**Étapes :**

- [ ] **1. Écrire les tests en échec.**
  - **Redirection, point de revue 1** :
    - sans compte, sans données et sans `welcomeDone`, l'app ouvre `/welcome` ;
    - avec des habitudes locales, l'app ouvre `/today`, sans accueil ;
    - connecté, l'app ouvre `/today`.
  - **Point de revue 2** : connecté et hors ligne, `/today` s'affiche dès le premier rendu.
  - **Accueil** :
    - les 4 actions sont présentes, avec Semantics et des cibles de 48 dp ;
    - « Continuer sans compte » écrit `welcomeDone` et mène à `/today` ;
    - un succès Google ou Apple (faux) mène à `/today` ;
    - `AuthFailure(cancelled)` ne montre rien ;
    - les autres échecs affichent un message clair ;
    - avec `available == false`, les trois boutons de compte sont masqués et seul « Continuer sans compte » reste.
  - **E-mail** :
    - la pilule e-mail se remplit et se coche quand l'adresse est valide ;
    - la pilule mot de passe suit la solidité (Faible / Moyen / Solide) ;
    - on bascule entre « créer » et « se connecter » ;
    - « Mot de passe oublié ? » appelle `sendPasswordReset` ;
    - `existsWithOtherMethod('google.com')` affiche « Connecte-toi avec Google pour retrouver ton compte » et propose le bouton Google ;
    - `emailInUse` propose de passer en mode connexion.
  - **Pilule du compte** :
    - les états sans compte (vide, « + »), `SyncRunning` (remplissage), `SyncUpToDate` (pleine, ✓) et `SyncWaiting` (neutre) ;
    - la toucher sans compte ouvre la feuille Google / Apple / e-mail ;
    - « Confirme ton adresse » s'affiche si l'e-mail n'est pas vérifié.
  - **Déconnexion** :
    - `SignOutBlocked` affiche le message de la spec, et l'utilisateur reste connecté ;
    - sinon, retour à `/welcome`.
  - **Suppression du compte** :
    - une double confirmation ;
    - `needsRecentLogin` redemande l'identification par la méthode d'origine, puis réessaie (**point de revue 5**).
  - **Import connecté** : il confirme « Ajouter ce fichier à ton compte ? » puis appelle `mergeBackup`, pas `restore`.
- [ ] **2. Vérifier que ces tests échouent.**
  - Lancer `flutter test test/features/welcome_test.dart test/features/email_screen_test.dart test/features/account_pill_test.dart test/app_shell_test.dart`.
  - Attendu : échecs.
- [ ] **3. Implémenter, selon les maquettes** `welcome-a-v4.html` (variante A3) et `email-and-profile-v3.html`, dans `.superpowers/brainstorm/1447873-1793635203/content/`, et selon la section « Écrans » de la spec.
  - Réutiliser `PressSink`, le ressort `fill` (via `SpringBuilder`), `SegmentedStrip` si utile, `FadeThroughSwitcher` entre les modes, `showSorbetSheet` et les jetons Sorbet.
  - Pendant une action réseau, le bouton touché montre un indicateur, et les autres sont désactivés.
- [ ] **4. Vérifier la suite.**
  - Lancer `flutter analyze && flutter test`.
  - Attendu : aucun problème, `All tests passed!`.

---

### Tâche 4 : documents publics, store et guide de configuration

Aucune dépendance de code. Peut partir dès le début.

**Fichiers :**
- **Modifier :**
  - `docs/privacy.html` : FR et EN, nouvelle date d'effet ;
  - `docs/index.html` : lien vers la suppression ;
  - `docs/store/play-console.md` : fiche « compte facultatif », Sécurité des données (e-mail, identifiants, activité de l'app collectés pour le fonctionnement, non partagés, chiffrés en transit, suppression possible), lien de suppression, notes de version 1.1 FR/EN.
- **Créer :**
  - `docs/delete-account.html` : FR et EN, suppression depuis l'app ou par e-mail à damienprouet76@gmail.com, délai et données concernées ;
  - `docs/firebase-setup.md` : le pas-à-pas pour l'auteur.

**Contenu de `firebase-setup.md`, étape par étape, avec la commande exacte à chaque fois :**
1. Créer le projet Firebase.
2. Ajouter l'app Android `dev.golden.littlesteps`.
3. Lancer `dart pub global activate flutterfire_cli`, puis `flutterfire configure` : il génère `lib/firebase_options.dart`, que `firebase_config.dart` lit.
4. Ajouter dans Firebase les empreintes SHA-1 et SHA-256 de la clé d'upload (`keytool -list -v -keystore ~/keys/little-steps-upload.jks -alias upload`) et de la clé Play App Signing (Play Console › Intégrité de l'appli).
5. Activer les fournisseurs e-mail, Google et Apple.
6. Côté Apple Developer : App ID, Services ID, clé Sign in with Apple, domaine et URL de retour `https://<projet>.firebaseapp.com/__/auth/handler`.
7. Créer Firestore en mode production, région `eur3`.
8. Déployer les règles avec `firebase deploy --only firestore:rules`.
9. Vérifier sur le téléphone.

**Étapes :**

- [ ] **1. Rédiger les pages et le guide,** fidèles à la spec, sans promesse que le code ne tient pas.
- [ ] **2. Vérifier.**
  - Le HTML est bien formé (`python3 -m html.parser`, ou une vérification équivalente).
  - Les descriptions courtes de la fiche font 80 caractères au plus.
  - Les liens entre les pages sont relatifs et justes.

---

## Fin : intégration (orchestrateur)

- [ ] **Fusionner les worktrees de T2, T3 et T4.**
  - Les conflits attendus portent sur `pubspec.yaml` (dépendances de T2, assets de T3), les ARB et `providers.dart`.
  - Lancer `dart run build_runner build -d && flutter gen-l10n && flutter analyze && flutter test`.
- [ ] **Une seule revue finale**, suivie d'une seule vague de correctifs.
- [ ] **Vérifier la build sans configuration Firebase :** `flutter build apk --debug` et la CI. L'app tourne en mode local, et l'accueil ne montre que « Continuer sans compte ».
- [ ] **Sur l'appareil, avant toute configuration Firebase,** vérifier l'accueil, le mode local et la mise à jour depuis la 1.0 avec des données (migration v4).
- [ ] **Après le `firebase-setup.md` de l'auteur,** tester les vrais parcours sur deux appareils : Google, e-mail, Apple, synchro, fusion, conflit, déconnexion et suppression.
- [ ] **Un seul commit,** en français, avec le co-auteur. Puis `superpowers:verification-before-completion` et `superpowers:finishing-a-development-branch`.
