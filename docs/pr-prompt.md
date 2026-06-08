# PR Description & Checklist Prompt (template)

Use this template to auto-generate clear PR descriptions and a checklist for reviewers.

Prompt (copy → paste to AI):

"You are an expert engineering reviewer. Given the following changes (commit summary / diff):

- Briefly describe the purpose of the PR in 1-2 sentences.
- List the main files or areas changed.
- Explain the behavior changes and any user-visible impact.
- Note any migration, config, or environment changes required to run the branch.
- Provide a short testing checklist for reviewers including commands to run locally.

Return the PR body with sections: Summary, Files Changed, Behavior, Migration / Env, How to Test (commands), and Checklist (pass/fail items). Keep it concise and action-oriented."

Quick reviewer checklist (add to PR body):
- Code compiles and app runs: `flutter pub get` + `flutter run` (or `flutter build`).
- Static analysis: `flutter analyze`.
- Unit/widget tests: `flutter test`.
- No logic in widgets; uses providers for state.
- No hardcoded colors/strings (check `lib/core/`).
