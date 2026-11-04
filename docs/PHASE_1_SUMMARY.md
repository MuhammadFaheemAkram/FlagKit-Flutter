# Phase 1 — SDK Foundation

## Phase Goal

Lay the ground every later phase builds on, before a single flag exists:
- **the repository's shape:** a pub workspace with two packages, the SDK (`packages/flagkit`) and a sample app that depends on it (`sample_app`), resolved together, analyzed together, tested apart;
- **the SDK's public API, as a promise:**
  - the names a host app can use;
  - **the rule every read keeps:** synchronous, never throws, never waits, always returns a value;
  - **a read that can explain itself:** a value, where it came from and why;
  - the tests that make any change to the API visible;
- **the sample app:** four tabs whose screens already read their flags (through the app's own typed port) and run on their defaults, a look picked by a flag, and a Profile that sets who is asking.

Phase 1 caches nothing and fetches nothing. What it fixes is the contract: which names exist, what each read promises, and how the sample reaches the SDK without depending on it.

---

## What Was Implemented

- **The workspace** (from TrackLite's):
  - a root `pubspec.yaml` with `workspace: [packages/flagkit, sample_app]`; `.fvmrc` (3.47.6);
  - one `analysis_options.yaml` (strict casts, inference, raw types; `implementation_imports` and `depend_on_referenced_packages` as errors), and the SDK's own (`public_member_api_docs`, `type_annotate_public_apis`);
  - `.gitignore`, the MIT license, and **CI from day one**: generated code current and complete, format, analyze, both packages' tests, `pub publish --dry-run`, and `dart doc --dry-run` (`dartdoc_options.yaml` makes a broken doc reference an error).
- **The SDK package** (`flagkit` 0.1.0, depending on `flutter` and `meta` only):
  - **`lib/flagkit.dart`:** the whole public API, each export with a `show` list.
  - **`FlagKit`**, the static facade:
    - `initialize`: validates **before the start exists** (TrackLite's Phase 2 lesson), shares one start between concurrent calls, and ignores a second call while running (without validating it);
    - the typed reads (`isEnabled`, `getString`, `getInt`, `getDouble`, `getJson`), `getValue`, **`detail`**;
    - `setContext` / `context`: kept by the facade, so a context set before `initialize` (or across a restart) is the one the client starts with;
    - `changes`: one broadcast stream for the app's lifetime, forwarded from whichever client is running;
    - `refresh`, `clearCache`, `shutdown` (which waits for a start in progress), `instance`, `version`.
  - **`FlagKitClient`**, the interface the facade forwards to, with `create(config)` as the composition root.
  - **`FlagKitConfig`:** `apiKey`, `refreshInterval` (1 h, ≥ 1 min), `cacheExpiration` (24 h, ≥ `refreshInterval`), `startupWait` (0, 0–10 s), `debugMode`; `problems` lists every broken rule; `toString` masks the key.
  - **The models:**
    - **`FlagValue`**, sealed: `BoolValue`, `StringValue`, `IntValue`, `DoubleValue` (finite), `JsonValue` (a deep, unmodifiable copy, compared deeply, refusing what JSON can't carry);
    - `FlagType` (with the wire's names: `int`, `double`), `FlagSource`, `EvaluationReason` (**complete now**: ten reasons, though rules and rollouts arrive in Phase 4), `FlagDetail`, `EvaluationContext` (`valueOf(attribute)` for rules), `RefreshResult` (six cases, with value equality).
  - **Internals:** `TypedReads` (every typed read written once over `evaluate`), `FlagKitClientImpl` (no flags yet: `flagNotFound`; after shutdown `notInitialized`; an unknown flag logged once per session), `FlagKitLogger` (silent without `debugMode`), the JSON helpers (`freezeJson`, `jsonEquals`, `jsonHash`), `flagKitVersion`.
  - The SDK's README, CHANGELOG, LICENSE and `example/main.dart`.
- **The sample app** (`flagkit_sample`, app ID `co.bitfuse.flutter.flagkit`, "FlagKit"):
  - **Ports** (domain): **`AppFlags`** (typed: `newHomeScreen`, `newCheckout`, `homeTheme`, `feedPageSize`, `discountPercentage`, `homeConfig`, `watch()`), `UserContext`, `FlagsDebug`; models `HomeConfig` (from JSON, tolerant), `AppThemeChoice`, the cart (`CartTotals` in integer cents, a half-up discount), the feed.
  - **Adapters** (data): `FlagKitAppFlags` (one read per getter; the app's ranges for remote numbers), `FlagKitUserContext` (every change → `setContext`), `FlagKitFlagsDebug`; **`AppFlagKeys` / `AppFlagDefaults`: the one place keys and defaults are written.**
  - **Screens:** Home (the new home with a banner and sections, or the classic list), Checkout (a one-page checkout that asks before paying, or a classic stepper; the discount line), Profile (sign in, country, app version), the Dashboard (the SDK's version and each app flag's value, source and reason).
  - **The look follows `home_theme`:** a `ThemeCubit` above the router; three `AppThemeSpec`s (classic indigo, modern teal with rounder shapes, ocean blue).
  - `bootstrap()`: what `main()` does before the first frame (start the SDK, build the graph, give the SDK its first context), shared with the tests.
  - The design system (from TrackLite, plus RoamReady's adaptive confirm dialog): `AppColors` for the four sources and four cache statuses, contrast-tested in every look and brightness.
- **Tests: 170** (59 SDK, 111 sample).

---

## SDK Concepts Demonstrated

- **Reads that can't fail.** A feature flag is read on every screen, often in `build`. So a read is synchronous, returns a value whatever happens, and never throws: the caller's default is part of every call.
- **Explainability.** `detail(key)` returns the value, its **source** (`override`, `remote`, `cache`, `defaultValue`) and its **reason**. "Why is this off for me?" is the first question anyone asks of a flag system; the answer is built in, not reconstructed from logs.
- **Typed values, no silent conversion.** A wrong-typed read gets the default (`typeMismatch`, from Phase 2), never a parsed guess: `"30"` becoming `30` today and failing tomorrow is worse than an obvious default.
- **A complete enum and sealed class from the first version.** `EvaluationReason` and `RefreshResult` list cases that can't happen yet: adding one later would break every host's exhaustive `switch`.
- **The context API.** Who is asking is set once (`setContext`), not passed to every read: the native editions' `isEnabled(key, userId)` pushes targeting into every call site.
- **The host's own port.** The sample's screens never see a key or a `FlagValue`; one adapter maps meaning (`newCheckout`) to key and default, and a test checks the keys appear nowhere else.
- **Safe defaults.** Every app default is the old behaviour (classic home, classic checkout, no discount), so a flag missing, offline on a first launch, or switched off can only bring the app back to what it was.

---

## Flutter / Dart Concepts Demonstrated

- **A pub workspace** with an SDK and an app; `resolution: workspace`; one lockfile.
- **`show` lists and `@internal`:** a public API you can list; `implementation_imports` as an error in the host.
- **A sealed class with value equality** for results and values; a deep-frozen `Map` (`List.unmodifiable`, `Map.unmodifiable` at every depth).
- **A mixin as shared behaviour** (`TypedReads`): the typed reads written once, over one abstract `evaluate`.
- **Pattern matching as the read:** `switch (value) { IntValue(:final value) => value, _ => default }` can't throw.
- **A static broadcast stream** that outlives clients (with a scoped `close_sinks` ignore and a reason).
- **Validation before the shared start** (an `async` function runs synchronously up to its first `await`).
- **A theme from data:** `MaterialApp.router` rebuilt by a `BlocBuilder` above it; `ColorScheme.fromSeed` with `fidelity` per look.
- **Integer money:** discounts in hundredths of a percent, rounded half up, no `double` in totals.
- **`startWith`** (a `StreamController` subscribing in `onListen`) instead of an `async*` that loses an early change (§11.99).

---

## Flag Evaluation Flow

```
FlagKit.getInt('feed_page_size', 20)
  → not running?                     → 20   (defaultValue, notInitialized)
  → FlagKitClientImpl.getInt         (TypedReads)
      → evaluate('feed_page_size', integer)
          → closed?                  → fallback (notInitialized)
          → no definitions yet       → fallback (flagNotFound), logged once in debug mode
      → switch (detail.value) { IntValue(:value) => value, _ => 20 }
  → 20

The sample:
  HomeCubit → AppFlags.feedPageSize → FlagKitAppFlags
            → client.getInt(AppFlagKeys.feedPageSize, AppFlagDefaults.feedPageSize)
            → clamp(5, 50) → FeedCatalog.items(20)
  Profile → UserContext.signIn('alex') → FlagKitUserContext → client.setContext(EvaluationContext(userId: 'alex', …))
  ThemeCubit ← AppFlags.watch() ← client.changes (filtered to the app's keys) → AppThemeSpec → MaterialApp
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `packages/flagkit/lib/flagkit.dart` | The public API: `show` lists only |
| `packages/flagkit/lib/src/flagkit.dart` | The `FlagKit` facade |
| `packages/flagkit/lib/src/client/flagkit_client*.dart` | The interface and its implementation |
| `packages/flagkit/lib/src/config/flagkit_config.dart` | The config and its rules |
| `packages/flagkit/lib/src/model/*.dart` | Values, types, sources, reasons, details, the context, results |
| `packages/flagkit/lib/src/evaluation/typed_reads.dart` | The typed reads, once |
| `packages/flagkit/lib/src/util/{flagkit_logger,json}.dart` | Opt-in logging; JSON freezing and equality |
| `packages/flagkit/test/public_api_test.dart`, `version_test.dart` | The API's exact names; one version in three places |
| `sample_app/lib/domain/flags/app_flags.dart` | The app's typed flags port |
| `sample_app/lib/data/flags/app_flag_keys.dart` | Every key and default, once |
| `sample_app/lib/data/**` | The adapters |
| `sample_app/lib/app/bootstrap.dart` | Startup, shared by `main()` and the tests |
| `sample_app/lib/features/{home,checkout,profile,dashboard}/` | The screens |
| `sample_app/test/architecture/sdk_boundary_test.dart` | Only the wiring imports the SDK; keys live in one file |
| `.github/workflows/flutter-ci.yml` | CI |

---

## Important Types Added

| Type | Kind | Role |
|---|---|---|
| `FlagKit` | `abstract final class` | The static facade |
| `FlagKitClient` | `abstract interface class` | The SDK as an injectable object |
| `FlagKitConfig` | `final class` | Validated options |
| `FlagValue` + 5 cases | `sealed class` | A typed value |
| `FlagType`, `FlagSource`, `EvaluationReason` | enums | A value's type, origin, reason |
| `FlagDetail` | `final class` | A read, explained |
| `EvaluationContext` | `final class` | Who is asking |
| `RefreshResult` + 6 cases | `sealed class` | What a refresh did |
| `TypedReads` | mixin (internal) | The reads, written once |
| `AppFlags`, `UserContext`, `FlagsDebug` | interfaces (sample) | The app's ports |

---

## Folder Structure Changes

```
FlagKit/
├── pubspec.yaml  analysis_options.yaml  .fvmrc  .gitignore  LICENSE  README.md
├── .github/workflows/flutter-ci.yml
├── docs/PHASE_1_SUMMARY.md
├── packages/flagkit/
│   ├── lib/flagkit.dart
│   ├── lib/src/{flagkit.dart, version.dart, client/, config/, model/, evaluation/, util/}
│   ├── example/main.dart  test/
│   └── pubspec.yaml  README.md  CHANGELOG.md  LICENSE  analysis_options.yaml  dartdoc_options.yaml
└── sample_app/
    ├── android/  ios/  build.yaml  pubspec.yaml
    ├── lib/{main.dart, app/, core/{common,design_system,navigation}, di/, domain/, data/, features/}
    └── test/
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Delivering the SDK | a library module + a sample module | a local Swift Package + a sample target | a package in a pub workspace + `sample_app` |
| Hiding internals | `internal` | `internal` | `lib/src/` + `show` lists + `@internal` |
| The entry point | `object FlagKit` | `enum FlagKit` | `abstract final class FlagKit` + `FlagKitClient` |
| Config | `refreshIntervalMinutes`, `cacheExpirationHours` | `Duration`s | `Duration`s, validated, + `startupWait` |
| A flag's value | `value: String` + `FlagType` | the same | a sealed `FlagValue`, parsed once |
| Read result | the value | the value | the value, or a `FlagDetail` with source and reason |
| Rollout input | `isEnabled(key, userId)` | `isEnabled(key, userId:)` | `setContext(EvaluationContext(...))`, once |
| Sample state | ViewModel + StateFlow | `@Observable` | Cubits behind a typed `AppFlags` port |
| CI | `android-ci.yml` (Phase 6) | `ios-ci.yml` (Phase 6) | `flutter-ci.yml` from Phase 1, with `pub publish --dry-run` and `dart doc` |

---

## Interview Notes

- **"Why are flag reads synchronous?"** They're called in `build` methods and on hot paths. An `await` per read would mean a loading state for every flag on every screen. The SDK loads flags into memory once and answers from there; refreshes replace the snapshot in the background.
- **"What should a read return when there's no value?"** The caller's default, always passed at the call. A flag SDK that throws, returns `null` or blocks makes every call site handle a failure that has a perfectly good answer: the app's old behaviour.
- **"Why not convert types?"** `getInt` on `"30"` working today hides a server-side type change that fails tomorrow on `"thirty"`. A wrong type gets the default and a reason (`typeMismatch`) you can see.
- **"Why an `EvaluationReason` at all?"** Support and debugging. "The flag is off for me" has ten possible causes; the reason names one.
- **"How does the app avoid sprinkling flag keys everywhere?"** A typed port (`AppFlags`) with one adapter holding every key and default. Renaming a flag is one change; a test checks no other file mentions a key.

---

## Learning Checklist

- ✅ A pub workspace with an SDK package and a sample app
- ✅ A public API in one library with `show` lists; internals in `src/` and `@internal`
- ✅ A static facade over an injectable client interface; a context kept across restarts
- ✅ Reads that never throw, never wait, and always return a value
- ✅ A typed, sealed value model with deep-frozen JSON
- ✅ A source and a reason for every read
- ✅ A validated config that fails fast with every problem named; the key masked
- ✅ `public_member_api_docs`, a public-API test, a version test, `pub publish --dry-run` and `dart doc` in CI
- ✅ A typed flags port in the app, keys in one place, and a boundary test
- ✅ A theme picked by a flag
- ✅ Meaning colors tested for contrast in every look; an accessibility tour from day one
- □ Caching flags (Phase 2)
- □ Fetching them (Phase 3)
- □ Rollouts and targeting (Phase 4)

---

## Future Improvements

- **Phase 2:** drift as the cache (`flags`, `meta`), the snapshot loaded at `initialize` (source `cache`), the cache policy and its boundaries, the anonymous id, `clearCache`, type checks (`typeMismatch`), and the Dashboard's cache card.

---

## Notes on This Phase

- **From earlier projects:** the workspace, CI, lint rules, logger, public-API and version tests from TrackLite; the design system's widgets from TrackLite; the adaptive confirm dialog from RoamReady. `flutter create` derived the app IDs `co.bitfuse.flutter.flagkit_sample` and `…flagkitSample`, both changed to `co.bitfuse.flutter.flagkit`.
- **Spec adjustments:**
  - **`FlagType.integer` and `FlagType.decimal`,** not `int` and `double`: as enum values those names would shadow the types inside the enum. The wire keeps `"int"` and `"double"` (`wireName`).
  - **The sample's screens are built in full now** (both homes, both checkouts, Profile's context), on the app's defaults: they're UI over the `AppFlags` and `UserContext` ports, and the later phases then only feed them real values. Phase 4's sample work becomes the "Why am I seeing this?" lines.
  - **`refresh()` returns `Failed`** in 0.1.0 ("no remote config in this version"), rather than pretending nothing changed.
  - **`bootstrap()`** is new: the tests start the app the way `main()` does, from the same function, so a mistake in startup can't hide behind a test harness that does it differently.
- **Found while building:**
  - A vertical `Stepper` builds every step's controls (hidden ones too): three "Continue" buttons in the tree, and in the semantics tree. The controls builder now returns nothing for steps other than the current one.
  - `DropdownMenu` contains its own `TextField`, so "the" text field on Profile is ambiguous in tests: the user id field has a key.
  - `dart fix` removed the explicit `false` defaults in `FlagKitAppFlags` (`avoid_redundant_argument_values`), which would have broken "change the default in `AppFlagDefaults`". They're back, with a scoped ignore and the reason.
  - injectable's `@disposeMethod` on an `as:` registration (§11.42) again: `FlagKitUserContext.dispose()` is a plain method, for tests.
- **On the iPhone 17 Pro simulator:** the classic home (20 stories), the classic checkout through its three steps and the order message, Profile (country menu, app version), the Dashboard's six flags on their defaults; light and dark. Two fixes from it: the stepper's buttons now align with the step content, and Profile's "Country" heading (a repeat of the menu's label) is gone.
- **Mutation checks:** 44 rules broken on purpose, one at a time, against both suites.
  - **42 were caught at first.**
  - **Two were missed, and now have tests:**
    - **`Updated` ignoring `skipped` in `==`:** no test compared two results that differ only there;
    - **the new home reading the checkout's key:** the adapter test set every flag at once, so a getter reading another getter's key still passed. Each key is now set alone, and every other getter must keep its default.
  - **44 of 44 caught.**
