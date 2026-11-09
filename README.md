# 🚩 FlagKit

[![Flutter CI](https://github.com/MuhammadFaheemAkram/FlagKit-Flutter/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/MuhammadFaheemAkram/FlagKit-Flutter/actions/workflows/flutter-ci.yml)
![Flutter 3.47.6](https://img.shields.io/badge/Flutter-3.47.6-02569B?logo=flutter)
![Dart 3.13](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A small **feature flag and remote configuration SDK for Flutter apps**, and a sample app that integrates it. The goal is the SDK, not an app: a reusable Dart package with typed flag reads that never fail, an offline-first cache, remote refresh, deterministic percentage rollouts and user targeting. It works like a simplified Firebase Remote Config, LaunchDarkly, Statsig or Unleash SDK.

It runs on **Android and iOS**. There is **no API key and no server**: the SDK talks to a fake remote config server, with a delay, failures, an offline switch and a console to change flags.

> **Why this repo exists**
>
> A feature flag decides, at runtime, what a user sees: the new home or the old one, a checkout rolled out to a quarter of users, a feature switched off in seconds when it breaks. The SDK that answers "is this on?" runs on every screen, so it must answer at once, never fail, and work offline, and it must be able to say *why* a flag has the value it has.
>
> This project shows those rules applied, one phase at a time. It is the Flutter edition of an SDK that also exists natively for [Android](https://github.com/MuhammadFaheemAkram/FlagKit) and [iOS](https://github.com/MuhammadFaheemAkram/iFlagKit), and the second SDK in the series after [TrackLite](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter) (analytics). Each phase ships with a beginner-to-intermediate friendly write-up in [`docs/`](docs/).

---

## 📏 The One Rule

```
A flag read is synchronous, never throws, never waits for the network, and always returns a value:
the flag's evaluated value if FlagKit knows the flag, else the default the caller passed.
Every read can say where its value came from, and why.
```

---

## 📋 Project Status

The SDK is built in **strict, reviewable phases**. Each phase ends with:
- a building sample app (Android + iOS);
- a clean analyzer and passing tests in both packages;
- a summary doc;
- exactly one commit.

| Phase | Scope | Status |
|------:|-------|:------:|
| 1 | SDK foundation: the workspace, the public API's shape, the config and its rules, the sample app's screens on defaults, CI | ✅ Done |
| 2 | Storage and the cache: drift, the snapshot, the cache policy, the anonymous id, `clearCache`, the first debug stats | ✅ Done |
| 3 | The remote config pipeline: the transport and fake server, conditional and validated refreshes, the refresh log, the network monitor, the triggers, `startupWait` | ✅ Done |
| 4 | Rollouts and targeting: FNV-1a buckets, typed rules, the full evaluation order, re-evaluation on a context change, "Why am I seeing this?" | ✅ Done |
| 5 | The debug dashboard and SDK tools: local overrides (schema v3), every flag explained, "try a user", the server console, the refresh log and counts | ✅ Done |
| 6 | Documentation & CI | ⏳ Next |

---

## 🧩 Using the SDK

```dart
import 'package:flagkit/flagkit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlagKit.initialize(
    const FlagKitConfig(apiKey: 'demo_key', debugMode: true),
  );
  FlagKit.setContext(const EvaluationContext(country: 'PK', appVersion: '2.1.0'));
  runApp(const MyApp());
}

if (FlagKit.isEnabled('new_home_screen')) { /* the new UI */ }
final pageSize = FlagKit.getInt('feed_page_size', 20);
final theme = FlagKit.getString('home_theme', 'classic');
final discount = FlagKit.getDouble('discount_percentage', 0);
final config = FlagKit.getJson('home_config', const {});

final detail = FlagKit.detail('new_checkout');  // the value, where it came from, and why
final result = await FlagKit.refresh();         // a RefreshResult, never an exception
FlagKit.changes.listen((keys) { /* rebuild what reads them */ });
```

The public API is one library, [`package:flagkit/flagkit.dart`](packages/flagkit/lib/flagkit.dart):

| Name | What it is |
|---|---|
| `FlagKit` | The static facade: `initialize`, the typed reads, `detail`, `setContext`, `changes`, `refresh`, `clearCache`, `shutdown`, `instance`, `version` |
| `FlagKitClient` | The same calls as an interface, for apps with dependency injection (and their fakes) |
| `FlagKitConfig` | The API key and the options, with their rules checked at `initialize` |
| `FlagValue` (`BoolValue`, `StringValue`, `IntValue`, `DoubleValue`, `JsonValue`), `FlagType` | A flag's value, typed: parsed once, never at a read |
| `FlagDetail`, `FlagSource`, `EvaluationReason` | A read explained: the value, where it came from (`override`, `remote`, `cache`, `defaultValue`) and why |
| `EvaluationContext` | Who is asking: a user id, a country, an app version, custom attributes |
| `TargetingRule`, `TargetingOperator` | A flag's targeting: an attribute, an operator (`in`, `semverAtLeast`, …) and values; every rule must match |
| `RefreshResult` | What a refresh did: `Updated`, `NotModified`, `Offline`, `Failed`, `Unauthorized`, `NotInitialized` |
| `CacheStatus` | How fresh the cache is: `fresh`, `stale`, `expired`, `empty` |
| `FlagKitDebug`, `FlagKitStats` | The debug tools (`FlagKit.debug`): live stats (the cache, the last refresh, overrides, online, refreshing, reads by source, refresh counts), the refresh log, every flag (`watchFlags`), `definitions`, `evaluateFor` another user, `explain`, local overrides |
| `FeatureFlag`, `FlagExplanation`, `RuleMatch` | A definition as the server sent it; everything behind one read, with each rule's result |
| `RefreshRecord`, `RefreshTrigger`, `RefreshOutcome` | One refresh in the log: why it ran, what came of it |
| `RemoteConfigTransport`, `FetchRequest`, `FetchResponse` (`FetchedConfig`, `ConfigNotModified`) | The network boundary: set `FlagKitConfig.transport` to fetch from a real backend |
| `TransportException` (`ServerUnreachable`, `ServerFailure`, `ApiKeyRejected`) | Why a fetch failed |
| `FakeRemoteConfigServer`, `FakeServerStats` | The default transport: latency, failures, a key check, conditional fetches, a console |
| `NetworkMonitor`, `ConnectivityNetworkMonitor` | Online or not: offline, nothing is attempted; pass your own with `FlagKitConfig.networkMonitor` |

A second library, [`package:flagkit/testing.dart`](packages/flagkit/lib/testing.dart), is for an app's tests: `FlagKitTesting.useInMemoryDatabase()`, `FlagKitTesting.disableTimers()`, `FlagKitTesting.useAnonymousId()` (a known bucket in every rollout) and `FakeNetworkMonitor`.

Everything else is in `lib/src/`, marked `@internal`, and out of reach.

**Rules the SDK keeps:**
- **Reads never throw and never wait.** They return the caller's default when there is no value of the right type; nothing converts silently (`getDouble` on an integer flag is the one widening).
- **A bad configuration fails fast.** It is the one exception: `initialize` throws an `ArgumentError` naming every broken rule, in development.
- **Not running, defaults.** Before `initialize` and after `shutdown`, reads return the caller's default with the reason `notInitialized`, and `refresh()` says `NotInitialized`.
- **The context outlives a client.** One set before `initialize` is the one the client starts with.
- **Silent unless asked.** Without `debugMode`, the SDK logs nothing; with it, an unknown flag is logged once, not on every frame.

- **Cached, read from memory** (0.2.0):
  - definitions are kept in the SDK's own `flagkit.sqlite` (drift), with a value and an **off value** each; they survive restarts and work offline;
  - `initialize` loads them once into an immutable snapshot, and every read evaluates against it (source `cache`);
  - **the order so far:** unknown → your default (`flagNotFound`); another type → your default (`typeMismatch`); switched off → the off value (`off`); otherwise the value (`fallthrough`).
- **The cache policy:** fresh under `refreshInterval`, stale until `cacheExpiration`, expired after, empty when nothing is cached; exactly at a boundary is the later state, a future fetch time is fresh. **Expired flags are still served.**
- **`clearCache()`** forgets the flags (not the install's anonymous id), and `changes` reports every flag whose value changed.
- **A broken cache file never fails `initialize`:** the session runs in memory, logged.

- **Refreshed from a server** (0.3.0):
  - `refresh()` fetches through the transport, **one at a time**, and returns a `RefreshResult`;
  - **conditional:** the cached config version is sent, and an unchanged config comes back "not modified", with no body;
  - **validated in two levels:** a malformed payload changes nothing; an invalid flag (a bad type, value, key, rollout or rule) is skipped and the rest apply;
  - **atomic:** the new definitions replace the cache in one transaction, and reads see the old flags or the new, never a mix.
- **Automatic refreshes,** never while the cache is fresh, offline, or after a rejected key: at `initialize`, when the cache turns stale (in the foreground), when the app comes back, and on reconnect.
- **`startupWait`:** with nothing cached, `initialize` waits up to this long for the first fetch.
- **Offline, nothing is attempted,** and the cached flags keep serving reads.

- **Local overrides** (0.5.0): `FlagKit.debug.setOverride(key, value)` wins over everything (source `override`), for a flag the server sends or not; kept across restarts and by `clearCache` until cleared; a wrong type or key is an `ArgumentError`.
- **Debug tools that explain** (0.5.0): `watchFlags` (every flag, again when a reason or bucket changes, not only a value), `evaluateFor` another user without changing the context, `explain` (each rule and whether it matches), and stats with counters that outlive the 50-entry log.

- **Targeted and rolled out** (0.4.0):
  - **the full order:** unknown or another type → your default; switched off → the off value (**the kill switch beats everything**); rules that don't all match → the off value (`targetingMiss`); a rollout → the value for that share of the eligible (`rolloutIncluded` / `targetingMatch`), the off value for the rest (`rolloutExcluded`); otherwise the value;
  - **rules** compare an attribute of the context by kind: text (countries without regard to case), numbers, **versions as versions** (`2.10.0` after `2.9.0`); **a missing attribute never matches**, `notIn` included; an unknown operator never matches, and is logged;
  - **rollouts:** FNV-1a (32-bit) of `"key:unit"` mod 10,000, pinned by the published test vectors: the same bucket on every device, independent per flag, monotonic as a rollout grows; the unit is the user id, else the install's anonymous id;
  - **`setContext` re-evaluates every flag,** and `changes` names the ones whose value changed; `detail()` gives the bucket.

---

## ✨ The Sample App

- 🏠 **Home:** the new home (a banner and sections from a JSON flag) or the classic list, as `new_home_screen` says; `feed_page_size` stories. The whole app's **look** follows `home_theme` (classic, modern, ocean), **targeted at Pakistan and the UAE**. The demo server's flags come from [`assets/remote_config.json`](sample_app/assets/remote_config.json).
- 🛒 **Checkout:** a fixed cart with the discount from `discount_percentage` (**apps 2.0.0 and later**), in the style `new_checkout` picks, **rolled out to 25 %**: a one-page checkout that asks before paying, or a classic stepper.
- ❓ **"Why am I seeing this?"** on Home and Checkout: each flag's reason in a sentence, with the user's bucket for a rollout ("outside its 25 % rollout (bucket 2679 of 10,000, not below 2500)").
- 👤 **Profile:** the **evaluation context**: sign in as a user id, pick a country and an app version, see the install id rollouts use while signed out. They go to the SDK at once, and the other tabs follow.
- 🚩 **Dashboard:** the learning screen.
  - **The cache:** its status, flag and override counts, the config version, when it was fetched, the last refresh, the install id, a progress line while any refresh runs; **Refresh** (its result in words), **Clear cache** (asks first), **Clear overrides**.
  - **The network** and a **Device offline** switch.
  - **Every flag:** its value, kind, source and reason (with the bucket for a rollout). Tap one for its page: the server's value and off value, the kill switch, the rollout and **this user's bucket**, **each rule and whether it matches**, and an **override** (On / Off, or a typed value checked against the flag's kind).
  - **Try a user:** type an id, see what every flag would give them, without changing who the app is for.
  - **The server console** (the demo's, not the SDK's): switch flags on and off, set a rollout, change the look the server serves, make answers fail (0 / 50 / 100 %) or slow; then Refresh to see it arrive.
  - **The refresh log** (the last 10) and **stats** (reads by source, refreshes, failures, invalid flags left out).
- ♿ **Accessible:** dark mode and large text on every screen; never color alone. A test tour checks every screen in light and dark at 200 % text.

**The app never reads a flag by its key.** Its Cubits ask the app's own `AppFlags` port (`flags.newCheckout`, `flags.feedPageSize`); one adapter holds every key and default, and a test checks that the keys appear nowhere else.

---

## 🧰 Tech Stack

An SDK's dependencies become every host app's dependencies, so **the SDK and the sample follow different rules**.

| Area | SDK (`packages/flagkit`) | Sample (`sample_app`) | Since |
|------|----------------------------|-----------------------|:-----:|
| Toolchain | Flutter 3.47.6 · Dart 3.13, pinned with [FVM](https://fvm.app); one **pub workspace** | the same | 1 |
| Public models | hand-written immutable and sealed classes; `meta` (`@internal`) | — | 1 |
| The cache | [`drift`](https://pub.dev/packages/drift) + `drift_flutter` (its own `flagkit.sqlite`, schema v1 exported) | — | 2 |
| Ids and time | `uuid` (the anonymous id), `clock` (an injected "now") | `intl` (times) | 2 |
| Network | `connectivity_plus`, behind `NetworkMonitor` | `DemoNetworkMonitor` (the device's network + a demo switch) | 3 |
| Lifecycle | `AppLifecycleListener` (refresh on resume) | — | 3 |
| UI | — | [`material_ui`](https://pub.dev/packages/material_ui) (Material 3), `cupertino_ui` | 1 |
| Navigation | — | `go_router` + `go_router_builder` (typed routes, `StatefulShellRoute`) | 1 |
| DI | none: a hand-written composition root | `get_it` + `injectable` | 1 |
| State | — | `flutter_bloc` Cubits, `freezed` states | 1 |
| Lints / CI | strict analysis + `public_member_api_docs`; `pub publish --dry-run`; `dart doc` | strict analysis; `implementation_imports` as an error | 1 |
| Testing | `flutter_test` | `flutter_test`, `bloc_test`, `mocktail` | 1 |

---

## 🏛️ Architecture

```
sample app                                       the SDK (package:flagkit)
──────────                                       ─────────────────────────
View ─▶ Cubit ─▶ AppFlags / UserContext / FlagsDebug / DemoServer  (the app's ports)
                        │
                        ▼
      FlagKitAppFlags · FlagKitUserContext · FlagKitFlagsDebug ──▶ FlagKitClient ◀── FlagKit (static facade)
             (the adapters: every key and default here)                  │
                                                                         ▼
                              evaluate(key, type, context) ─▶ FlagSnapshot + overrides (in memory) ─▶ FlagDetail (value, source, reason, bucket)
                      override → off → rules (targeting) → rollout (FNV-1a bucket of key:unit)   ▲ loaded at start, replaced whole
                                                                  FlagRepository ─▶ drift (flagkit.sqlite: flags, meta, refreshes, overrides)
                                                                         ▲
   RefreshScheduler (startup · stale · resumed · reconnect) ─▶ RefreshManager ─▶ RemoteConfigTransport (FakeRemoteConfigServer)
                                                                  (single-flight, conditional, validated, atomic, logged)
```

```
FlagKit/                       # the repo root: a pub workspace (one lockfile)
├── packages/flagkit/          # THE SDK
│   ├── lib/flagkit.dart       # the public API (show lists)
│   ├── lib/testing.dart       # the second public library, for apps' tests
│   ├── lib/src/               # everything else (@internal): the facade, client/, config/, model/, evaluation/,
│   │                          #   repository/, storage/, cache/, network/, refresh/, scheduling/, connectivity/,
│   │                          #   debug/, testing/, util/
│   ├── drift_schemas/         # every schema version, kept to migrate from
│   ├── example/main.dart      # the snippet pub.dev shows
│   └── README.md  CHANGELOG.md  LICENSE  build.yaml  dartdoc_options.yaml
├── sample_app/                # THE SAMPLE (a normal app)
│   ├── assets/remote_config.json   # the demo server's flags
│   └── lib/
│       ├── app/  core/{common,design_system,navigation}  di/
│       ├── domain/            # the ports (AppFlags, UserContext, FlagsDebug, DemoServer, DeviceNetwork), HomeConfig, the cart, the feed
│       ├── data/              # the adapters, AppFlagKeys (the one place keys live), DemoNetworkMonitor, FakeServerDemo
│       └── features/          # shell, home, checkout, profile, dashboard; common/ (the "Why am I seeing this?" line)
├── analysis_options.yaml      # one set of rules (the SDK adds its own)
└── .github/workflows/flutter-ci.yml
```

---

## ▶️ How to Run

Prerequisites: [FVM](https://fvm.app); Xcode, for iOS; the Android SDK with Java 17+.

```bash
fvm install                       # the version pinned in .fvmrc (3.47.6)
fvm flutter pub get               # at the root: resolves the SDK and the sample together
cd sample_app && fvm flutter run  # pick an Android emulator or an iOS simulator
```

Generated code (`*.g.dart`, `*.freezed.dart`, `*.config.dart`) is committed. After changing annotated code, regenerate it from the root:

```bash
fvm dart run build_runner build --workspace
```

---

## ✅ Testing

```bash
fvm flutter analyze                                    # the whole workspace
fvm dart format --output=none --set-exit-if-changed .
(cd packages/flagkit && fvm flutter test)              # the SDK
(cd sample_app && fvm flutter test)                    # the sample
(cd packages/flagkit && fvm flutter pub publish --dry-run && fvm dart doc --dry-run)
```

**523 tests** after Phase 5:
- **The SDK (304):** everything from Phase 4, plus:
  - **overrides** on a real client: winning over the kill switch, the rules and the rollout; for a flag the server doesn't send; a read of another type; a bad key or type refused; cleared one at a time or all, with `changes`; kept by `clearCache` and across a restart from a real file;
  - **`watchFlags`** (by key; again on a context change that changes no value; after an override and a refresh), **`definitions`**, **`evaluateFor`** (the context unchanged, not counted), **`explain`** (each rule's result);
  - **the stats:** overrides, online (and its changes), refreshing during a refresh, reads by source, counters for refreshes, failures and skipped definitions that outlive the log, no event for a tick that changes nothing;
  - schema v3: the overrides' `CHECK`s, the counters, the v2 → v3 migration with real rows; the models' value equality.
- **The sample (219):** everything from Phase 4, plus the adapters on the real SDK (inspect, try a user, overrides typed as text, the cache's counts, the log, the server console's adapter and knobs), the new Cubits and views (a flag's page in every state, Try a user, the console, Clear cache's confirmation), and **flows on the real SDK:** the console switches a flag off and Refresh brings it; an override from a flag's page changes Checkout and is cleared; Clear cache → defaults → Refresh; Try a user; deep links to a flag and to a flag that's gone; new accessibility stops for the flag page and Try a user.

CI runs on every push to `main` and every pull request: the FVM-pinned Flutter; generated code up to date and complete; format and analyze; each package's tests; `pub publish --dry-run` (a warning fails it); `dart doc --dry-run` (a broken doc reference fails it).

---

## 📱 Same SDK on Other Platforms

| Edition | Stack | Repo |
|---------|-------|------|
| Android | Kotlin · a library module · Room · DataStore · Compose sample | [MuhammadFaheemAkram/FlagKit](https://github.com/MuhammadFaheemAkram/FlagKit) |
| iOS | Swift 6 · a local Swift Package · SwiftData · actors · SwiftUI sample | [MuhammadFaheemAkram/iFlagKit](https://github.com/MuhammadFaheemAkram/iFlagKit) |
| **Flutter** | Dart · a package in a pub workspace · drift · Cubit sample | this repo |

| Concept | Android | iOS | Flutter |
|---|---|---|---|
| Delivery | a library module | a local Swift Package | a Dart package in a pub workspace |
| Public API | `object FlagKit` | `enum FlagKit` (static) | `abstract final class FlagKit` + a `FlagKitClient` interface |
| Values | `String` + a type | the same | a sealed `FlagValue`, parsed once |
| Cache | Room + DataStore | SwiftData + UserDefaults | drift: definitions (value + off value) and meta, in one file |
| Reads | sync over a cache | sync | synchronous, from an immutable snapshot |
| Cache statuses | boundaries undefined | the same | half-open boundaries; expired still served |
| Refresh | full fetch | full fetch | conditional by config version; validated per flag; atomic; single-flight; logged |
| Auto refresh | WorkManager "if practical" | `BGTaskScheduler` optional | foreground triggers that respect freshness: startup, staleness, resume, reconnect |
| Why a value | `FlagSource` | `FlagSource` | `FlagSource` + `EvaluationReason`, in a `FlagDetail` |
| Targeting input | `userId` per read | `userId` per read | an evaluation context, set once; a change re-evaluates every flag |
| Rollout hash | `hashCode`-style, undefined | undefined | FNV-1a 32 over UTF-8, golden vectors, basis points (12.5 % works) |
| Rules and rollout | order undefined | order undefined | kill switch → rules (all) → rollout among the eligible |
| Versions | string compare | string compare | numeric (`2.10.0` > `2.9.0`); malformed never matches |
| Overrides | — | — | persisted (drift v3), win over everything, source `override`, kept by `clearCache` |
| Debug tools | a dashboard | a dashboard + a network toggle + a user id | every flag explained (rules, bucket), `evaluateFor` another user, a server console, counters |
| CI | `android-ci.yml` | `ios-ci.yml` | `flutter-ci.yml` (+ `pub publish --dry-run`, `dart doc`) |

The full table (the cache, rollouts, targeting, refresh) grows with the phases.

---

## 📚 Documentation

- [Phase 1 — SDK Foundation](docs/PHASE_1_SUMMARY.md)
- [Phase 2 — Storage + Cache Layer](docs/PHASE_2_SUMMARY.md)
- [Phase 3 — Remote Config Pipeline](docs/PHASE_3_SUMMARY.md)
- [Phase 4 — Rollouts + Targeting](docs/PHASE_4_SUMMARY.md)
- [Phase 5 — Dashboard + SDK Features](docs/PHASE_5_SUMMARY.md)
- The SDK's own [README](packages/flagkit/README.md) and [CHANGELOG](packages/flagkit/CHANGELOG.md)

---

## 🗺️ Roadmap

The phases above. Ideas after them (a real HTTP transport, streaming updates, exposure events for experiments, multi-variant flags, fetch / activate) are collected in `docs/ROADMAP.md` in Phase 6.

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse
