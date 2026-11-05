# Phase 3 — Remote Config Pipeline

## Phase Goal

Connect the cache to a server, and keep it current without the app asking:
- **a network boundary** (`RemoteConfigTransport`) a real backend could implement, and a fake server behind it, with a console to change flags as an admin would;
- **refresh**, done properly:
  - one at a time;
  - conditional: an unchanged config costs no body;
  - validated: a malformed payload changes nothing, an invalid flag is skipped while the rest apply;
  - atomic: reads see the old flags or the new, never a mix;
  - logged;
- **offline-first:** offline, nothing is attempted and the cached flags keep serving reads;
- **the triggers:**
  - startup, with an optional wait on a first launch;
  - when the cache turns stale;
  - back in the foreground;
  - on reconnect;
  - all of them respecting freshness;
- **the sample on real flags:** the server's flags drive Home, Checkout and the theme, and the Dashboard can refresh and simulate offline.

---

## What Was Implemented

- **SDK 0.3.0 (public):**
  - **`RemoteConfigTransport`** with `FetchRequest` (key, SDK version, `ifVersion`), the sealed `FetchResponse` (`FetchedConfig(json)`, `ConfigNotModified`) and the sealed `TransportException` (`ServerUnreachable`, `ServerFailure(status)`, `ApiKeyRejected`).
  - **`FakeRemoteConfigServer`**, the default transport:
    - definitions in the wire format, from a list or `fromJson`;
    - a config `version` bumped by every change;
    - latency (600 ms), a failure rate (a 503), reachability, a key check;
    - conditional fetches;
    - each client gets its own copy (through JSON, as an HTTP body would be);
    - **a console:** `setFlag`, `setValue`, `setEnabled`, `removeFlag`;
    - `FakeServerStats` and `watchStats()`.
  - **`NetworkMonitor`** (`ConnectivityNetworkMonitor` by default, online until the plugin answers), `FlagKitConfig.transport` and `.networkMonitor`.
  - **`RefreshRecord`, `RefreshTrigger`, `RefreshOutcome`:**
    - `FlagKit.debug.watchRefreshes()`;
    - `FlagKitStats.lastRefresh`.
  - **`testing.dart`:** `FakeNetworkMonitor`, `FlagKitTesting.disableTimers()` / `enableTimers()`.
- **SDK internals:**
  - **`parseConfig`:**
    - the payload must have an integer `version` and a `flags` list, or nothing applies;
    - each flag is checked on its own: the key `[a-z0-9_.-]{1,64}`, a known type, value and off value of that type, `enabled` a bool (absent: on), no second definition of a key. A failing flag is skipped and reported.
    - **A flag with rules or a rollout is skipped until 0.4.0 can evaluate them** (failing closed).
  - **`RefreshManager`:**
    - single-flight; offline → `Offline`, logged only for a manual refresh;
    - the cached version sent, so an unchanged config comes back as not modified, and `markFetched` makes the cache fresh again (source `remote`);
    - the added, changed (`!sameAs`) and removed keys, then `repository.replace` in one transaction;
    - every transport error kind, and a transport that throws anything else, leaves the cache as it was;
    - a 401 sets `pausedByRejectedKey`;
    - the refresh log; `watchRefreshing()`.
  - **drift v2:** `refreshes` (the newest 50 kept, `CHECK`s on its names), `RefreshDao`; a tested migration (the generated schema check, plus a data test keeping the flags, the anonymous id and the meta).
  - **`RefreshScheduler`:**
    - one timer armed **for the moment the cache turns stale**, re-armed each time it fires;
    - a stale cache waits one interval before the next try, never "at once";
    - `resumed` on coming back to the foreground; no timer in the background;
    - `reconnect` on the monitor's `false → true`;
    - every trigger skipped when the cache is fresh, the device offline, or the key rejected.
  - **`AppLifecycle`** (from TrackLite): Flutter's, or always-foreground with a warning when there's no binding.
  - **The client:**
    - the startup refresh when the cache isn't fresh, waiting up to `startupWait` only when nothing is cached (the timer is cancelled if the fetch wins);
    - one refresh at a time at the client too, so `changes` is reported once however many triggers joined;
    - `shutdown` stops the scheduler, waits for a refresh in flight, then closes the database.
- **The sample:**
  - `assets/remote_config.json` (six flags), loaded into the demo server by a pre-resolved DI registration (async `configureDependencies`);
  - `DemoNetworkMonitor` and the `DeviceNetwork` port (from TrackLite);
  - `bootstrap()` builds the graph first, then starts the SDK with the app's server and monitor; `beforeStart` lets tests swap the device network and the server's latency at exactly that point;
  - **the Dashboard:**
    - **Refresh**, which says "Refreshing…" and shows a progress line, then a SnackBar with the result in words;
    - the last refresh (why, what, when, the error);
    - the network row, and **Device offline**.
- **Tests: 335** (195 SDK, 140 sample).

---

## SDK Concepts Demonstrated

- **The transport is the contract.** The SDK owns caching, validation, retries and the log; a transport only fetches, and says what went wrong with one of three sealed errors. A real HTTP client is one class.
- **Conditional fetches.** Sending the cached version lets the server answer "not modified" with no body. A refresh every minute then costs almost nothing, and still confirms the cache is current (`fetchedAt` moves, the source becomes `remote`).
- **Two levels of validation.** A payload you can't trust changes nothing; a flag you can't read is skipped and the rest apply. A newer server can add a type without breaking older SDKs' flags.
- **Fail closed on features you don't have.** A flag with rules or a rollout, served by an SDK that can't evaluate them, would reach everyone. Skipping it keeps the app on its default.
- **Offline-first, honestly:**
  - offline, nothing is attempted, and reads go on with the last known flags;
  - a failed refresh changes nothing;
  - the network monitor is an interface, so a demo switch and a test behave like a real outage.
- **Triggers that respect freshness.** Every automatic trigger asks "is the cache stale?" first: a resume a minute after a refresh costs no request.
- **Time a timer from the data, not the clock.** A periodic timer started at launch ticks just before the cache it fetched turns stale, and skips a whole period. Arming for "fetched at + interval" refreshes on time.
- **A first launch with no cache** can wait a moment for real values (`startupWait`), so the first screen doesn't flash defaults. With any cache, it never waits.
- **A rejected key pauses automatic refreshes.** Every one would fail the same way; hammering a server with a bad key helps no one.

---

## Flutter / Dart Concepts Demonstrated

- **Sealed classes as a protocol:** `FetchResponse` and `TransportException` switched over exhaustively by the SDK and by a host's own transport tests.
- **A one-shot `Timer` re-armed from state,** instead of `Timer.periodic`; never armed "at once" for a time already past (§11.100).
- **Racing a future against a timeout without leaving a timer:** a `Completer` completed by whichever comes first, with the timer cancelled when the fetch wins.
- **Single-flight with a stored future** (`_running ??= …whenComplete(…)`), at two layers.
- **`fake_async` with in-memory drift:** a whole client, its latency and its timer, tested in fake time.
- **`@preResolve` in injectable:** an asset loaded before the graph is built; `configureDependencies()` becomes async.
- **Widget tests and database writes** (§11.95): the bootstrap runs in `tester.runAsync`, because the startup refresh writes to drift and `initialize` waits for it.
- **`AppLifecycleListener`** for resume, with a fallback when there's no binding.
- **A process-group kill** around `flutter test` in the mutation runner, so a hanging mutation can't leave a `flutter_tester` behind.

---

## Flag Evaluation Flow

```
FlagKit.initialize(config)
  → open the cache (Phase 2) → the scheduler starts (one timer: fetched at + interval)
  → cache fresh?                     → nothing
  → else refresh(startup)            → nothing cached and startupWait > 0? wait up to startupWait

refresh(trigger)                      (one at a time, at the client and in the manager)
  → offline?                         → Offline (logged if manual); the cache stays
  → transport.fetch(FetchRequest(apiKey, sdkVersion, ifVersion: cached version))
      ConfigNotModified              → markFetched(now): fresh again, source remote → NotModified
      FetchedConfig(json)            → parseConfig: payload or nothing; each flag or skipped
                                     → added / changed / removed against the snapshot
                                     → one transaction: definitions, deletions, version, fetched at
                                     → swap the snapshot → Updated(...)
      ServerUnreachable / ServerFailure / a bad payload / a transport bug → Failed(reason)
      ApiKeyRejected                 → Unauthorized; automatic refreshes pause
  → the refresh log
  → changes.add(keys whose evaluated value changed)

Triggers (each skipped when the cache is fresh, offline, or the key was rejected):
  the cache turns stale (foreground) · the app resumes · the network comes back · refresh()
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `packages/flagkit/lib/src/network/remote_config_transport.dart` | The transport, requests, responses, errors |
| `packages/flagkit/lib/src/network/fake_remote_config_server.dart` | The fake server and its console |
| `packages/flagkit/lib/src/refresh/{config_parser,refresh_manager}.dart` | Validation; the refresh |
| `packages/flagkit/lib/src/scheduling/{refresh_scheduler,app_lifecycle}.dart` | The triggers; the lifecycle |
| `packages/flagkit/lib/src/connectivity/network_monitor.dart` | The monitor, the real one, the fake |
| `packages/flagkit/lib/src/storage/{refresh_dao,refresh_mapper}.dart`, `refreshes` table | The refresh log |
| `packages/flagkit/lib/src/model/refresh_record.dart` | The log's public record |
| `packages/flagkit/drift_schemas/flagkit_database/drift_schema_v2.json`, `test/drift/` | Schema v2 and its migration test |
| `packages/flagkit/test/helpers/fakes.dart`, `test/flutter_test_config.dart` | `FakeAppLifecycle`, `ScriptedTransport`, wire helpers; timers off |
| `sample_app/assets/remote_config.json` | The demo server's starting flags |
| `sample_app/lib/data/network/demo_network_monitor.dart`, `lib/domain/network/device_network.dart` | The demo switch |

---

## Important Types Added

| Type | Kind | Role |
|---|---|---|
| `RemoteConfigTransport`, `FetchRequest` | interface, class (public) | The network boundary |
| `FetchResponse` (`FetchedConfig`, `ConfigNotModified`) | sealed (public) | A fetch's answer |
| `TransportException` (`ServerUnreachable`, `ServerFailure`, `ApiKeyRejected`) | sealed (public) | Why a fetch failed |
| `FakeRemoteConfigServer`, `FakeServerStats` | class (public) | The default transport and its counts |
| `NetworkMonitor`, `ConnectivityNetworkMonitor` | interface, class (public) | Online or not |
| `RefreshRecord`, `RefreshTrigger`, `RefreshOutcome` | class, enums (public) | The refresh log |
| `FakeNetworkMonitor` | class (public, `testing.dart`) | A network for tests |
| `RefreshManager`, `RefreshScheduler`, `ParsedConfig` | internal | Refreshing, and when |
| `DeviceNetwork`, `NetworkStatus`, `RefreshSummary`, `LastRefresh` | sample | The Dashboard's ports and models |

---

## Folder Structure Changes

```
packages/flagkit/
├── drift_schemas/flagkit_database/drift_schema_v2.json     # new
├── lib/src/
│   ├── network/        # new: the transport, the fake server
│   ├── refresh/        # new: the parser, the manager
│   ├── scheduling/     # new: the scheduler, the lifecycle
│   ├── connectivity/   # new: the network monitor
│   └── util/start_with.dart                                # new
└── test/
    ├── drift/flagkit_database/                             # new: the migration test
    ├── flutter_test_config.dart                            # new
    └── network/ refresh/ scheduling/ connectivity/         # new

sample_app/
├── assets/remote_config.json                               # new
└── lib/{domain,data}/network/                              # new
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| The server | `FakeRemoteConfigApi` (hardcoded, a delay, `SHOULD_THROW_ERROR`) | `FakeRemoteConfigService` | `FakeRemoteConfigServer`: the app's flags, a version, a console, a failure rate, a key check |
| The boundary | `RemoteConfigApi.fetchFlags()` | `RemoteConfigService` protocol | `RemoteConfigTransport` with sealed responses and errors |
| A refresh | fetch all | fetch all | conditional on the config version; validated per flag; atomic; logged |
| Bad server data | undefined | undefined | the payload or nothing; an invalid flag skipped; rules/rollouts skipped until 0.4.0 |
| Auto refresh | WorkManager "if practical" | `BGTaskScheduler` optional | foreground: startup, staleness, resume, reconnect; never when fresh |
| Offline | serve cached flags | serve cached flags | the same, and nothing attempted; a demo switch on the same interface |
| First launch | defaults | defaults | `startupWait`: wait up to N for real values |

---

## Interview Notes

- **"How would you poll for remote config without wasting requests?"** Conditional fetches: send the version you have, get "not modified" with no body. And trigger on what matters (staleness, resume, reconnect), never while the cache is fresh.
- **"The server sends a flag of a type your SDK doesn't know. What happens?"** That flag is skipped and logged; the rest apply. A malformed payload, by contrast, changes nothing: you can't trust any part of it.
- **"What if the server sends targeting rules an old SDK can't evaluate?"** Skip the flag (fail closed). Serving its value to everyone would turn a 10 % rollout into 100 %.
- **"How do you avoid a refresh storm?"** Single-flight (joined, not repeated), freshness checks on every trigger, a failed refresh retried one interval later rather than at once, and a rejected key pausing automatic refreshes.
- **"What's wrong with `Timer.periodic(refreshInterval)`?"** It's measured from when it started, not from when the data was fetched: started before the first fetch finishes, it ticks while the data is still fresh and skips a whole period. Arm from `fetchedAt + interval`.
- **"How do you test it?"** A scripted transport (responses, errors, a gate to hold a fetch mid-flight), a fake network monitor and lifecycle, a clock you move, and `fake_async` over in-memory drift for the timer on a whole client.

---

## Learning Checklist

- ✅ A transport interface with sealed responses and errors; a fake server with a console
- ✅ Conditional fetches by config version
- ✅ Two-level validation, and failing closed on unsupported features
- ✅ Single-flight, atomic refreshes that report value changes once
- ✅ A refresh log, with a schema migration and a data test
- ✅ A network monitor, offline-first behaviour, a demo switch
- ✅ Triggers that respect freshness; a timer armed from the data's age
- ✅ A startup wait that never leaves a timer pending
- ✅ A pre-resolved async dependency in the sample
- □ Rollouts and targeting (Phase 4)

---

## Future Improvements

- **Phase 4:** the context and the full evaluation order, FNV-1a buckets in basis points, typed targeting operators, rules and rollouts in the definitions (no longer skipped), Profile's anonymous id, the "Why am I seeing this?" lines, the server's flags gaining a 25 % rollout and targeting.
- **The Dashboard's cache status ages only on writes** (Phase 2's note): with a one-minute refresh it rarely shows; Phase 5's stats can tick.

---

## Notes on This Phase

- **Spec adjustments:**
  - **The interval is "when the cache turns stale"**, not a fixed period (see *Found on the device*).
  - **`FlagKitDebug.watchRefreshes()`, `RefreshRecord` and `FlagKitStats.lastRefresh` arrive now** (the spec had them in Phase 5): the Dashboard shows the last refresh.
  - **Flags with rules or a rollout are skipped in 0.3.0**, a rule the spec didn't have.
  - **`bootstrap(beforeStart:)`:** the one point tests swap registrations, between the graph and the SDK.
- **Found on the device (the iPhone 17 Pro simulator):**
  - **The interval waited twice as long as configured.** The timer was `Timer.periodic(refreshInterval)` from launch. The first fetch took 0.6 s, so at 60 s the cache was 59.4 s old, fresh, and the refresh was skipped until 120 s. The refresh log showed it (no interval refresh after a minute). Now the timer is armed for "fetched at + interval", and re-armed each time it fires. On the device, the next refreshes ran at 04:11:10 and 04:12:11, a minute after each fetch, and a fake-time client test pins it.
  - **The rest:**
    - the Phase 2 database (`user_version` 1) migrated in place to v2, keeping the install id;
    - the first launch showed the server's flags with no default first: the new home, its banner, 12 stories, the modern look, and Checkout's 15.5 % discount ($9.69);
    - Refresh said "Up to date" (a conditional fetch) and moved the fetch time;
    - Device offline → Refresh said "You're offline" with no request;
    - switched back on after the cache had gone stale, a `reconnect` refresh ran.
- **Found in the tests:**
  - **The widget tests hung:** the startup refresh writes to drift and `initialize` waits for it, which never completes in fake time (§11.95). `pumpSample` now runs the bootstrap in `tester.runAsync`.
  - **A test can pass without testing anything:** two client tests (a "restart" that never restarted, a "resume" that never resumed) were rewritten, with a real file and a movable clock.
- **The client doesn't re-arm the scheduler after a refresh,** and doesn't need to: an edit meant to add it didn't apply, the timer was on time anyway, and the reason is better than the call. When the timer fires and finds the cache fresh (another trigger refreshed meanwhile), it re-arms for the new moment.
- **Mutation checks:** 43 rules broken on purpose, one at a time, against both suites (a runner that kills the whole process group of a hung run).
  - **39 were caught at first**, one of them by its timeout: "a stale cache re-armed at once" looped forever in fake time, the very bug the rule prevents.
  - **Three were missed, and now have tests:**
    - **"not modified" leaving the source as `cache`:** the test's cache came from a refresh, so it was `remote` already. A cache loaded from disk is now confirmed by a "not modified" and must turn `remote`;
    - **`shutdown` not waiting for a refresh in flight:** the refresh then failed quietly against the closed database, and the test only checked it returned something. It now checks that `shutdown` hasn't finished while the fetch is held, and that the refresh stored its flags (`Updated`);
    - **the config's `==` ignoring the transport:** configs with different transports or monitors are now compared.
  - **One is equivalent:** the test harness keeping the demo server's 600 ms latency changes only how long the tests take.
  - **42 of 43 caught, 1 equivalent.**
