# Tests

## Tests unitaires et widgets (sans appareil)

```bash
flutter analyze
flutter test
```

Base en mémoire, horloge fixe (mardi 20 octobre 2026), notifications et sons
remplacés : voir `test/helpers.dart`.

## Tests d'intégration (sur un appareil Android)

`integration_test/app_test.dart` lance la vraie app (base sur fichier, plugins,
sons, vibrations) sur un téléphone ou un émulateur :

- création d'une habitude en 3 étapes depuis l'écran vide, tap, « Annuler »,
  appui long pour compléter une quantité ;
- séance chronométrée (idée « Méditer 5 min »), pause, valeur enregistrée,
  puis redémarrage de l'app sur le même fichier : les données sont toujours là.

```bash
adb devices                                  # l'identifiant de l'appareil
flutter test integration_test -d <appareil>
```

Attention : ça installe un build debug de `dev.golden.littlesteps`. Si l'app
installée est signée avec une autre clé (build release), l'installation échoue
ou l'app doit être désinstallée d'abord, **ce qui efface ses données**.
Préférer un émulateur ou un appareil de test.

Les tests utilisent leur propre base (`little_steps_it`, vidée à chaque test)
et une horloge fixe ; aucun rappel n'est planifié, donc pas de demande de
permission de notifications.

Vérifier qu'ils compilent sans appareil :

```bash
dart analyze integration_test
flutter build apk --debug --target=integration_test/app_test.dart
```

## CI (GitHub Actions)

`.github/workflows/ci.yml`, à chaque push et pull request sur `main`
(ubuntu, Java 17, Flutter 3.47.2) :

1. `flutter pub get`
2. code drift à jour : `dart run build_runner build -d` puis `git diff --exit-code`
3. traductions à jour : `flutter gen-l10n` puis `git diff --exit-code`
4. formatage : `dart format --set-exit-if-changed lib integration_test`
   (`test/` pas encore formaté)
5. `flutter analyze`, `flutter test`
6. `flutter build apk --debug`, APK publié en artefact `little-steps-debug-apk`

Les tests d'intégration ne tournent pas en CI (il faut un appareil).
