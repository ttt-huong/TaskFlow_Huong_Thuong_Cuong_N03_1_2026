# PR Checklist (short)

Add this checklist to PR templates or use it when reviewing changes.

- [ ] PR summary clear and linked to issue (if any)
- [ ] Changes scoped and minimal
- [ ] `flutter pub get` completes successfully
- [ ] `flutter analyze` shows no new issues
- [ ] `flutter test` passes locally (or CI)
- [ ] No business logic in UI widgets
- [ ] No hardcoded colors; use tokens in `lib/core/`
- [ ] Screenshots or short recording for UI changes are included
- [ ] Changelog or migration notes added if needed
