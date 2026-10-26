# Little Steps

Tracker d'habitudes mobile en Flutter (Android d'abord), local-first, EN/FR.

- Spec et maquettes : [`design/DESIGN.md`](design/DESIGN.md), `design/maquettes/*.dc.html`
- Thème Sorbet : `lib/core/theme/` (couleurs via `SorbetColors`, un `ThemeExtension`)
- Traductions : `lib/l10n/app_en.arb` (source), `app_fr.arb` (tutoiement)
- Icônes : polices Phosphor embarquées, `lib/core/icons/phosphor_icons.dart`
  (`phosphor_flutter` 2.1.0 ne compile plus sous Flutter ≥ 3.47)

```bash
flutter pub get
flutter analyze && flutter test
flutter run
```

Tests unitaires, tests d'intégration sur appareil et CI : [`docs/testing.md`](docs/testing.md).
