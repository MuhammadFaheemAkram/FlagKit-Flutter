# 🚩 FlagKit

[![Flutter CI](https://github.com/MuhammadFaheemAkram/FlagKit-Flutter/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/MuhammadFaheemAkram/FlagKit-Flutter/actions/workflows/flutter-ci.yml)
![Flutter 3.47.6](https://img.shields.io/badge/Flutter-3.47.6-02569B?logo=flutter)
![Dart 3.13](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A small **feature flag and remote configuration SDK for Flutter apps**, and a sample app that integrates it. The goal is the SDK, not an app: a reusable Dart package with typed flag reads that never fail, an offline-first cache, remote refresh, deterministic percentage rollouts and user targeting. It works like a simplified Firebase Remote Config, LaunchDarkly, Statsig or Unleash SDK.

It runs on **Android and iOS**. There is **no API key and no server**: the SDK will talk to a fake remote config server, with a delay, failures and an offline switch.

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
| 2 | Storage and the cache: drift, the cache policy, the anonymous id, `clearCache` | ⏳ Next |
| 3 | The remote config pipeline: the fake server, refresh, offline-first reads, the triggers | |
| 4 | Rollouts and targeting: stable hashing, the context, rules and the evaluation order | |
| 5 | The debug dashboard and SDK tools: overrides, "try a user", the refresh log | |
| 6 | Documentation & CI | |

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
| `RefreshResult` | What a refresh did: `Updated`, `NotModified`, `Offline`, `Failed`, `Unauthorized`, `NotInitialized` |

Everything else is in `lib/src/`, marked `@internal`, and out of reach.

**Rules the SDK keeps (0.1.0):**
- **Reads never throw and never wait.** They return the caller's default when there is no value of the right type; nothing converts silently (`getDouble` on an integer flag is the one widening).
- **A bad configuration fails fast.** It is the one exception: `initialize` throws an `ArgumentError` naming every broken rule, in development.
- **Not running, defaults.** Before `initialize` and after `shutdown`, reads return the caller's default with the reason `notInitialized`, and `refresh()` says `NotInitialized`.
- **The context outlives a client.** One set before `initialize` is the one the client starts with.
- **Silent unless asked.** Without `debugMode`, the SDK logs nothing; with it, an unknown flag is logged once, not on every frame.

There are **no flags yet**: they come from the device's cache in 0.2.0 and from the server in 0.3.0, so in 0.1.0 every read is the caller's default (`flagNotFound`).

---

## ✨ The Sample App

- 🏠 **Home:** the new home (a banner and sections from a JSON flag) or the classic list, as `new_home_screen` says; `feed_page_size` stories. The whole app's **look** follows `home_theme` (classic, modern, ocean).
- 🛒 **Checkout:** a fixed cart with the discount from `discount_percentage`, in the style `new_checkout` picks: a one-page checkout that asks before paying, or a classic stepper.
- 👤 **Profile:** the **evaluation context**: sign in as a user id, pick a country and an app version. They go to the SDK at once.
- 🚩 **Dashboard:** every flag the app reads, with its value, where it came from and why. The cache, refresh, overrides and the server's console arrive with the later phases.
- ♿ **Accessible:** dark mode and large text on every screen; never color alone. A test tour checks every screen in light and dark at 200 % text.

**The app never reads a flag by its key.** Its Cubits ask the app's own `AppFlags` port (`flags.newCheckout`, `flags.feedPageSize`); one adapter holds every key and default, and a test checks that the keys appear nowhere else.

---

## 🧰 Tech Stack

An SDK's dependencies become every host app's dependencies, so **the SDK and the sample follow different rules**.

| Area | SDK (`packages/flagkit`) | Sample (`sample_app`) | Since |
|------|----------------------------|-----------------------|:-----:|
| Toolchain | Flutter 3.47.6 · Dart 3.13, pinned with [FVM](https://fvm.app); one **pub workspace** | the same | 1 |
| Public models | hand-written immutable and sealed classes; `meta` (`@internal`) | — | 1 |
| The cache | `drift` (its own file) | — | 2 |
| Network | `connectivity_plus`, behind `NetworkMonitor` | a demo switch | 3 |
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
View ─▶ Cubit ─▶ AppFlags / UserContext / FlagsDebug  (the app's ports)
                        │
                        ▼
      FlagKitAppFlags · FlagKitUserContext · FlagKitFlagsDebug ──▶ FlagKitClient ◀── FlagKit (static facade)
             (the adapters: every key and default here)                  │
                                                                         ▼
                                                     evaluate(key, type) ─▶ FlagDetail (value, source, reason)
                                                     (the snapshot and the evaluation engine arrive in 0.2–0.4)
```

```
FlagKit/                       # the repo root: a pub workspace (one lockfile)
├── packages/flagkit/          # THE SDK
│   ├── lib/flagkit.dart       # the public API (show lists)
│   ├── lib/src/               # everything else (@internal): the facade, client/, config/, model/, evaluation/, util/
│   ├── example/main.dart      # the snippet pub.dev shows
│   └── README.md  CHANGELOG.md  LICENSE  dartdoc_options.yaml
├── sample_app/                # THE SAMPLE (a normal app)
│   └── lib/
│       ├── app/  core/{common,design_system,navigation}  di/
│       ├── domain/            # the ports (AppFlags, UserContext, FlagsDebug), HomeConfig, the cart, the feed
│       ├── data/              # the adapters, AppFlagKeys (the one place keys live)
│       └── features/          # shell, home, checkout, profile, dashboard
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

**170 tests** after Phase 1:
- **The SDK (59):** the config's rules at their edges; the values (typed, frozen JSON compared deeply); the context; the facade (before, during and after a start, one start shared, a bad config rejected); the client; the typed reads (no silent conversion); the public API's exact names; the version in code, pubspec and changelog.
- **The sample (111):** the adapters (keys, defaults, the app's ranges for remote numbers); the Cubits and views of every screen; the theme in every look and brightness (contrast at WCAG AA); navigation; the DI graph; the SDK boundary; the accessibility tour; the app on the real SDK, running on its defaults.

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
| Reads | sync over a cache | sync | synchronous, from an immutable snapshot (0.2.0) |
| Why a value | `FlagSource` | `FlagSource` | `FlagSource` + `EvaluationReason`, in a `FlagDetail` |
| Targeting input | `userId` per read | `userId` per read | an evaluation context, set once |
| CI | `android-ci.yml` | `ios-ci.yml` | `flutter-ci.yml` (+ `pub publish --dry-run`, `dart doc`) |

The full table (the cache, rollouts, targeting, refresh) grows with the phases.

---

## 📚 Documentation

- [Phase 1 — SDK Foundation](docs/PHASE_1_SUMMARY.md)
- The SDK's own [README](packages/flagkit/README.md) and [CHANGELOG](packages/flagkit/CHANGELOG.md)

---

## 🗺️ Roadmap

The phases above. Ideas after them (a real HTTP transport, streaming updates, exposure events for experiments, multi-variant flags, fetch / activate) are collected in `docs/ROADMAP.md` in Phase 6.

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse
