<!-- Thanks for contributing to FlagKit! -->

## Summary

<!-- What does this PR change, and why? -->

## Changes

-

## Checklist

- [ ] `fvm flutter analyze` reports no issues.
- [ ] `fvm dart format --output=none --set-exit-if-changed .` passes.
- [ ] Both packages' tests pass (`packages/flagkit` and `sample_app`); new logic is covered by tests (rules at their edges, failure and offline paths).
- [ ] `fvm flutter pub publish --dry-run` and `fvm dart doc --dry-run` in `packages/flagkit` are clean (a warning or a broken doc reference fails CI).
- [ ] Generated code is regenerated from the root and committed (`fvm dart run build_runner build --workspace`).
- [ ] **The public API:** a new or changed public name is in `lib/flagkit.dart`'s `show` list, `test/public_api_test.dart` and the SDK's README, with a doc comment.
- [ ] **The SDK's rules hold:** reads are synchronous and never throw; the evaluation order and its reasons are unchanged (or `docs/EVALUATION.md` and its tests say how); the golden hash vectors pass; targeting fails closed; writes come before the swap.
- [ ] A schema change bumps `schemaVersion` and ships with `make-migrations` output and a migration test.
- [ ] A change to `sample_app/assets/remote_config.json` bumps its `version`.
- [ ] A new SDK dependency is justified (it becomes every host's), with a caret on a major.
- [ ] The sample's Cubits still depend only on the app's ports, and flag keys stay in `AppFlagKeys` (the boundary tests pass).
- [ ] UI changes work in every theme, in dark mode and at large text sizes, and new screens or states are added to the accessibility tour.
- [ ] The SDK's `CHANGELOG.md` says what a host would notice; the version is bumped in code, pubspec and changelog together if releasing.
- [ ] A release build launches, if a plugin or native setup changed.
- [ ] Commit messages follow Conventional Commits.

## Screenshots (if UI changed)

| Before | After |
|--------|-------|
|        |       |
