# AGENTS.md — Agent guidance for this TaskFlow Flutter project

Purpose: provide concise, actionable instructions so AI coding agents and maintainers can get productive quickly.

Quick setup
- Install Flutter SDK (matching project's SDK in `pubspec.yaml`).
- Get dependencies: `flutter pub get`.
- Run app (debug): `flutter run`.
- Run tests: `flutter test` (project has basic widget test at `test/widget_test.dart`).

Key entry points & files
- Main app entry: [lib/main.dart](lib/main.dart#L1)
- App shell / composition: [lib/app.dart](lib/app.dart#L1)
- Firebase options: [lib/firebase_options.dart](lib/firebase_options.dart#L1)

Important directories
- UI & logic: [lib/screens](lib/screens)
- Shared widgets: [lib/widgets](lib/widgets)
- State & providers: [lib/providers](lib/providers)
- Data & repos: [lib/repositories](lib/repositories)

Build & platform notes
- Android: uses Gradle wrapper; build files under `android/` (use `./gradlew assembleDebug` on Windows via `gradlew.bat`).
- iOS/macOS: standard Flutter Xcode projects under `ios/` and `macos/`.
- Web: `flutter run -d chrome` if needed.

Conventions & important rules (short)
- Data flow: UI → Provider → Repository → Service. Follow this layering strictly (see [CLAUDE.md](claude.md) for rationale).
- Keep logic out of widgets; use providers for state and side-effects.
- Avoid hardcoded colors/strings — prefer central tokens under `lib/core/`.

Where to find design + style guidance
- Visual and UX guidelines: [docs/Skill.md](docs/Skill.md#L1)
- Design prompts & tokens: [docs/yc.md](docs/yc.md#L1)
- Engineering rules for dev + AI: [claude.md](claude.md#L1)

If you modify this file
- Preserve links to existing docs; prefer linking rather than duplicating content.
- Keep content minimal and actionable — agents should not need to read long prose here.

Next suggested customizations
- Create an agent prompt for automated PR descriptions and test-run checklist.
- Add a CI hook skill to run `flutter test` and `flutter analyze` on PRs.
