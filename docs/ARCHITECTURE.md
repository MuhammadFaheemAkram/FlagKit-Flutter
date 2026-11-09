# Architecture

FlagKit is two packages in one [pub workspace](https://dart.dev/tools/pub/workspaces):

- **`packages/flagkit`:** the SDK. A Dart package with one public library (`package:flagkit/flagkit.dart`) and one for tests (`package:flagkit/testing.dart`). Everything else lives in `lib/src/`, marked `@internal`.
- **`sample_app`:** a normal Flutter app that uses the SDK the way a host app would, through its own ports.

The SDK and the sample follow **different rules on purpose**. An SDK's dependencies become every host's, so the SDK has no DI container, no state management and no generated code in its public API. The sample uses the full app stack (Cubits, `get_it` + `injectable`, `go_router`, `freezed`) to show how a real app integrates an SDK without leaking it everywhere.

---

## The SDK, layer by layer

```
FlagKit (static facade) ──▶ FlagKitClient (the interface) ◀── FlagKitClientImpl (the composition root)
                                                                   │
        reads (synchronous)                                        │  writes and refreshes (asynchronous)
        ───────────────────                                        │  ───────────────────────────────────
  TypedReads ─▶ evaluate(key, type)                                ├─▶ RefreshScheduler ── startup · stale · resumed · reconnect
                  │                                                │        │  (AppLifecycle, NetworkMonitor, Clock)
                  ▼                                                │        ▼
   evaluateFlag(definition, context, unit, override)   (pure)      ├─▶ RefreshManager ── single-flight, conditional, validated
     ├─ matchesAll(rules, context)  (targeting.dart)               │        │                         (parseConfig)
     │    └─ SemVer                                                │        ▼
     └─ bucketOf(key, unit) ─ fnv1a32  (rollout.dart)              │   RemoteConfigTransport (FakeRemoteConfigServer by default)
                  ▲                                                │
                  │ an immutable FlagSnapshot + the overrides      │
                  └────────────── FlagRepository ◀─────────────────┘
                                   writes first, then swaps
                                         │
                                         ▼
                    drift: flagkit.sqlite (flags · meta · refreshes · overrides)

  ClientDebug (FlagKit.debug) ── watchStats · watchRefreshes · watchFlags · definitions · evaluateFor · explain · overrides
```

| Layer | Files (`lib/src/`) | Role |
|---|---|---|
| Facade | `flagkit.dart` | `FlagKit`: one shared client, a context kept across restarts, one `changes` stream for the app's lifetime |
| Client | `client/` | `FlagKitClient` (the interface) and `FlagKitClientImpl` (opens everything, answers reads, reports changes) |
| Config | `config/` | `FlagKitConfig` and its rules, checked at `initialize` |
| Model | `model/` | The public value types: `FlagValue`, `FlagDetail`, `EvaluationContext`, `TargetingRule`, `FeatureFlag`, `FlagKitStats`, … and their JSON codecs |
| Evaluation | `evaluation/` | Pure functions: `evaluateFlag`, `matchesRule`, `SemVer`, `fnv1a32`, `bucketOf`, the typed reads |
| Repository | `repository/` | `FlagDefinition` (internal), `FlagSnapshot`, `FlagRepository` (the snapshot and the overrides, kept in step with the disk) |
| Storage | `storage/` | drift: the tables, DAOs, mappers, the schema's migrations |
| Cache | `cache/` | `cacheStatusOf`: fresh, stale, expired, empty |
| Network | `network/` | `RemoteConfigTransport`, its requests, responses and errors; `FakeRemoteConfigServer` |
| Refresh | `refresh/` | `parseConfig` (validation) and `RefreshManager` |
| Scheduling | `scheduling/` | `RefreshScheduler` and `AppLifecycle` |
| Connectivity | `connectivity/` | `NetworkMonitor`, `ConnectivityNetworkMonitor`, `FakeNetworkMonitor` |
| Debug | `debug/` | `FlagKitDebug` and `ClientDebug` |
| Testing | `testing/` | `FlagKitTesting`: an in-memory database, no timers, a known install id |

### Three decisions everything else follows

1. **Reads are synchronous, from memory.** `initialize` loads the cached definitions once into an immutable `FlagSnapshot`; every read evaluates against it. A read never touches the database or the network, so it can sit in a `build` method.
2. **The server sends definitions, not answers.** The device evaluates (like LaunchDarkly's and Statsig's client SDKs), so targeting and rollouts work offline, and a context change needs no request.
3. **Write first, then swap.** A refresh writes the new definitions, the deletions, the version and the time in one transaction, *then* replaces the snapshot. A failed write leaves the snapshot as it was: memory never claims what the disk doesn't have, and a read sees all of the old flags or all of the new ones.

---

## Data flow

### A read

```
FlagKit.getString('home_theme', 'classic')
  → client.evaluate(key, FlagType.string)
  → evaluateFlag(snapshot.flags[key], context, unit: userId ?? anonymousId, override)
  → FlagDetail(value, source, reason, bucket?)
  → the typed read returns the value, or the caller's default when there's none of the right type
```

### A refresh

```
a trigger (startup · stale · resumed · reconnect · refresh())
  → RefreshManager.refresh: offline? → Offline (nothing attempted)
  → transport.fetch(apiKey, sdkVersion, ifVersion: the cached version)
      ConfigNotModified → fetchedAt = now (fresh again)
      FetchedConfig     → parseConfig: the payload or nothing; each flag valid or skipped
                        → one transaction: definitions, deletions, version, fetchedAt
                        → swap the snapshot
      an error          → nothing changes; Failed / Unauthorized (automatic refreshes pause)
  → the refresh log (and its counters, in the same transaction)
  → changes.add(the keys whose evaluated value changed)
```

### A context change or an override

```
setContext(context) / debug.setOverride(key, value)
  → the values of every flag, before
  → the change (an override is written to the database first)
  → the values of every flag, after
  → changes.add(the keys that differ); a tick for the debug tools (a new bucket or reason counts too)
```

---

## The sample app

```
View ─▶ Cubit ─▶ AppFlags · UserContext · FlagsDebug · DemoServer · DeviceNetwork   (domain/: the app's ports)
                        ▲
                        │ implemented by (data/)
      FlagKitAppFlags · FlagKitUserContext · FlagKitFlagsDebug · FakeServerDemo · DemoNetworkMonitor
                        │
                        ▼
                  package:flagkit
```

- **Ports by meaning.** A Cubit asks `flags.newCheckout` or `flags.homeTheme`, never `isEnabled('new_checkout')`. The keys and the app's defaults live in one place (`AppFlagKeys`, `AppFlagDefaults`); a test checks they appear nowhere else.
- **Only the data layer, the DI module and the bootstrap import the SDK.** A test lists the files that may.
- **The bootstrap** (`app/bootstrap.dart`) is shared by `main()` and the tests: build the graph (the demo server from `assets/remote_config.json`, the network monitor), start the SDK with them, give it the starting user.
- **Every flag change reaches the screens** through `AppFlags.watch()` (the SDK's `changes`, filtered to the app's keys); the theme follows `home_theme` app-wide through a `ThemeCubit` above the router.

| Feature | What it shows |
|---|---|
| Home | `new_home_screen` (two layouts), `home_config` (JSON), `feed_page_size`; the look from `home_theme`; "Why am I seeing this?" |
| Checkout | `new_checkout` (a 25 % rollout: one page or a stepper), `discount_percentage` (for app 2.0.0+); why |
| Profile | The evaluation context: a user id, a country, an app version; the install id |
| Dashboard | The cache and its actions, the network, every flag and its page (definition, bucket, rules, override), Try a user, the server console, the refresh log, the counts |

---

## Folder structure

```
FlagKit/
├── packages/flagkit/
│   ├── lib/flagkit.dart              # the public API (show lists)
│   ├── lib/testing.dart              # for an app's tests
│   ├── lib/src/                      # everything else, @internal (layers above)
│   ├── drift_schemas/                # every schema version (v1–v3), kept to migrate from
│   ├── test/                         # one folder per layer; helpers/; drift/ (generated migration tests)
│   └── example/main.dart
├── sample_app/
│   ├── assets/remote_config.json     # the demo server's flags (bump "version" when they change)
│   ├── lib/{app,core,di,domain,data,features}/
│   └── test/{app,architecture,core,data,di,domain,features,helpers}/
├── docs/                             # these documents and one summary per phase
└── .github/                          # CI, issue and PR templates
```

---

## Where to read next

- [SDK_DESIGN.md](SDK_DESIGN.md): the public API and why it's shaped this way.
- [EVALUATION.md](EVALUATION.md), [ROLLOUTS.md](ROLLOUTS.md), [TARGETING.md](TARGETING.md): how a read is answered.
- [CACHE_POLICY.md](CACHE_POLICY.md): freshness, offline behaviour, the refresh triggers.
- [TESTING.md](TESTING.md): how each layer is tested.
