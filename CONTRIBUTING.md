# Contributing to FlagKit (Flutter)

Thanks for your interest! FlagKit is a learning-focused reference project for SDK design, so contributions that improve clarity, correctness or teaching value are especially welcome.

## Ground Rules

- Be respectful. See the [Code of Conduct](CODE_OF_CONDUCT.md).
- **The SDK's rules** (`packages/flagkit`):
  - **The public API is a promise.** A new public name goes in `lib/flagkit.dart`'s `show` list *and* `test/public_api_test.dart`, with a doc comment. Everything in `lib/src/` is `@internal`.
  - **Reads are synchronous, never throw, never wait.** They evaluate the in-memory snapshot and return a value with a source and a reason. Only `initialize` may throw, for a bad config (`ArgumentError`).
  - **The evaluation order is the contract** (see [docs/EVALUATION.md](docs/EVALUATION.md)): override → not found → type → off → rules → rollout → fallthrough. A new step needs a row there, a reason, and a test of its place in the order.
  - **The hash is frozen.** `fnv1a32` and `bucketOf` are pinned by golden vectors: changing them would move every user of every rollout. A different hash would be a new major version.
  - **Fail closed.** A missing attribute, a malformed version or an unknown operator never matches; an invalid flag is skipped, never half-applied; a malformed payload changes nothing.
  - **Writes first, then the swap.** The snapshot and the overrides change only after the database has the change, in one transaction where it belongs together.
  - **`changes` reports evaluated values,** taken before and after a change; the debug tools follow a separate tick (a bucket or reason can change without a value).
  - **Times are UTC; "now" comes from the injected `Clock`,** never `DateTime.now()`.
  - **Dependencies:** few, with a caret on a major. No DI container, no state management, no generated code in the public API. Explain any new one in the README's tech stack.
  - **Silent without `debugMode`.** Never log the API key.
- **The sample's rules** (`sample_app`):
  - **Cubits depend on the app's ports** (`AppFlags`, `UserContext`, `FlagsDebug`, `DemoServer`, `DeviceNetwork`), never on `package:flagkit`. Only the adapters in `data/`, the DI module and the bootstrap import it (`test/architecture/sdk_boundary_test.dart` checks).
  - **Flag keys and defaults live in `AppFlagKeys` / `AppFlagDefaults`** only (a test checks). A screen asks `flags.newCheckout`, never `isEnabled('new_checkout')`.
  - **UI:** import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`.
  - **Navigation happens in Views,** through typed routes.

## Development Setup

- Install [FVM](https://fvm.app), then run `fvm install`. It reads `.fvmrc`, which pins Flutter 3.47.6.
- iOS needs Xcode. Android needs the Android SDK and Java 17+ (Android Studio's bundled JDK works).
- From the root, `fvm flutter pub get` resolves the whole workspace (one lockfile). Then `cd sample_app && fvm flutter run`.
- **Trying the SDK:** Profile changes who you are (a country, an app version, a user id); the Dashboard's flag pages, **Try a user**, the **server console** (then **Refresh**) and **Device offline** show targeting, rollouts, refreshes and offline behaviour in seconds.
- **Changing the demo's flags** (`sample_app/assets/remote_config.json`): bump its `"version"` too. With conditional fetches, a device that cached the old flags at the same version gets "not modified" and never sees the change.
- After changing annotated code (drift, freezed, injectable, typed routes), regenerate it **from the root**:

  ```bash
  fvm dart run build_runner build --workspace
  ```

  Generated files are committed, and CI fails if they are stale or missing.
- **Changing the SDK's database schema:**
  1. Bump `schemaVersion` in `flagkit_database.dart`.
  2. Run `fvm dart run drift_dev make-migrations` in `packages/flagkit`. It exports the new version to `drift_schemas/` and generates the steps and the migration tests.
  3. Write the new step in the migration strategy, and a test that the old data survives.
- **Releasing a new SDK version:** bump `flagKitVersion` (`lib/src/version.dart`), `pubspec.yaml` and the top of `CHANGELOG.md` together (`test/version_test.dart` checks), and run `fvm flutter pub publish --dry-run`.
- **Before a release:** launch a **release** build once. Tree shaking and the main manifest only show there.

## Coding Conventions

- **Lints:** `fvm flutter analyze` must report **no issues**. The rules are `flutter_lints` plus strict casts, inference and raw types; the SDK adds `public_member_api_docs`.
- **Formatting:** `fvm dart format .` (the tall style).
- **The SDK:** a hand-written composition root (`FlagKitClientImpl.open`); every part takes what it needs in its constructor, behind an interface or a function, so it can be tested with a fake. The evaluator, the hash, the targeting and the cache policy are pure functions.
- **The sample:** Pages create and provide a Cubit; Views render state and forward intents.
- **Accessibility:** every tappable is at least 48 × 48 and has a label, text contrast meets WCAG AA in every theme and both brightnesses, and color is never the only signal. Above 130 % text (`context.prefersStackedLayout`), side-by-side layouts stack. The accessibility tour (`test/app/accessibility_tour_test.dart`) checks this, so add new screens and states to it.
- **Comments** explain *decisions*, not obvious code.

## Commits

This project uses **[Conventional Commits](https://www.conventionalcommits.org/)**:

```
<type>(<scope>): <message>
```

Examples: `feat(targeting): add a regex operator`, `fix(refresh): keep the cache on a 5xx`, `test(rollout): pin the bucket at the threshold`, `docs(evaluation): walk through an override`.

## Pull Requests

1. Fork the repository and create a topic branch.
2. Make sure analyze, format and both packages' tests pass, and the publish and docs dry runs are clean:

   ```bash
   fvm flutter analyze
   fvm dart format --output=none --set-exit-if-changed .
   (cd packages/flagkit && fvm flutter test && fvm flutter pub publish --dry-run && fvm dart doc --dry-run)
   (cd sample_app && fvm flutter test)
   ```
3. Update the docs, and the SDK's `CHANGELOG.md` for any change a host would notice.
4. Open a PR with a clear description of the change and its motivation.

## Tests

- **The SDK:** pure functions alone (the evaluator, the hash, targeting, versions, the cache policy); each part with fakes at its boundaries (`ScriptedTransport`, `FakeNetworkMonitor`, `FakeAppLifecycle`, a `Clock`, `SequentialIds`) on an in-memory database; `fake_async` for timers; `openTestClient` for the client end to end.
- **The sample:** Cubits with `bloc_test` and the fakes of the app's ports; Views with fakes, one state per test; app flows on the real SDK and the demo server (`pumpSample`, with a known install id so rollouts are deterministic).
- **Prove a new test can fail:** break the rule it guards and run it.

See [docs/TESTING.md](docs/TESTING.md).
