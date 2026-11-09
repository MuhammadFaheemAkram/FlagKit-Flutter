# Testing

```bash
fvm flutter analyze                                    # the whole workspace
fvm dart format --output=none --set-exit-if-changed .
(cd packages/flagkit && fvm flutter test)              # the SDK
(cd sample_app && fvm flutter test)                    # the sample
(cd packages/flagkit && fvm flutter pub publish --dry-run && fvm dart doc --dry-run)
```

**525 tests: 304 in the SDK, 221 in the sample.** CI runs all of it on every push and pull request, after checking that the generated code is current.

---

## The SDK (304)

| Area (`packages/flagkit/test/`) | Tests | What they pin |
|---|---:|---|
| `evaluation/` | 59 | Every row of the evaluation order and its place (the kill switch over matching rules, overrides over everything); FNV-1a's golden vectors, UTF-8, 32 bits; bucket distribution at 0/10/25/50/100 %, independence per flag, monotonicity, the threshold's edge; `SemVer` (`2.10.0 > 2.9.0`, `2.0 == 2.0.0`, malformed); every operator, a missing attribute for every operator, kinds, caseless countries, unknown operators; the typed reads |
| `client/` | 57 | A real client on in-memory drift: from the cache, then refreshed; `startupWait` (waits, gives up, never with a cache); single-flight; `changes` for a refresh, a context change, an override, `clearCache`; overrides (typed, persisted across a restart from a real file, kept by `clearCache`); `watchFlags`, `explain`, `evaluateFor`; the stats (online, refreshing, reads, counters, no duplicates); the interval on a whole client in fake time |
| `refresh/` | 41 | The parser (a malformed payload refused whole; every kind of bad flag, rollout and rule skipped; basis points); the refresh manager (not modified, added / changed / removed, every failure leaving the cache, a 401 pausing, offline, the log and its limit, unknown operators logged) |
| `storage/` | 32 | The `CHECK`s of every table; the mappers' round trips (rules, rollouts); the refresh counters outliving the log |
| `model/` | 23 | Value equality of every public type; `FlagValue`'s JSON; rules from JSON (every unreadable shape) |
| `config/` | 14 | Every rule of `FlagKitConfig`, its masked key, its equality |
| `flagkit_test.dart` | 14 | The facade: before `initialize`, a shared start, a context and a `changes` stream that outlive a restart, `FlagKitTesting.useAnonymousId` |
| `network/` | 13 | The fake server: its config as JSON carries it, conditional fetches, latency (fake time), reachability, the key check, the failure rate, the console (rollouts, rules) |
| `repository/` | 13 | The anonymous id; write-then-swap (a failed write leaves the snapshot); unreadable rows skipped; overrides on disk |
| `scheduling/` | 13 | Every trigger in fake time; freshness respected; offline; a rejected key; the timer armed for the moment the cache turns stale |
| `drift/` | 5 | Migrations from every exported version, and v1 → v2 → v3 with real rows |
| `connectivity/`, `cache/`, `util/` | 13 | The network monitors; `cacheStatusOf` at every boundary; `startWith` |
| `public_api_test.dart`, `version_test.dart` | 7 | The exported names, used as a host would; the version in code, pubspec and changelog |

### Fakes and helpers

- **`ScriptedTransport`:** each fetch's answer or error in order, a `gate` to hold a fetch mid-flight, the requests it saw.
- **`FakeNetworkMonitor`** (public, in `testing.dart`), **`FakeAppLifecycle`**, a `Clock` the test moves, **`SequentialIds`** (`id-1`, `id-2`, …).
- **`openTestClient`**, **`seedCache`**, **`definition(...)`**, **`wireFlag(...)`**, **`testConfig(...)`**.
- **`test/flutter_test_config.dart`** disables the interval timer and drift's multiple-database warning for every test.
- **`fake_async` with in-memory drift:** a whole client, its latency and its timer, in fake time.

## The sample (221)

| Area (`sample_app/test/`) | Tests | What they pin |
|---|---:|---|
| `features/` | 66 | Each Cubit with `bloc_test` and fakes of the app's ports; each View in its states (Home, Checkout, Profile, the Dashboard's sections, a flag's page, Try a user, the console, Clear cache's confirmation) |
| `app/` | 57 | **Flows on the real SDK and the demo server** (a first launch within `startupWait`; a flag switched off then refreshed; "Up to date"; Device offline; the server failing; the country applying `home_theme`; signing in moving the bucket; app 1.9.0 losing the discount; the console → Refresh; an override from a flag's page; Clear cache → defaults → Refresh; Try a user; deep links) and **the accessibility tour** |
| `data/` | 51 | The adapters on the real SDK (inspect, readFor, overrides typed as text, the cache's counts, the log), with a fake client (every source and reason mapped), the console's adapter and its knobs |
| `core/` | 31 | The design system (themes, contrast in every theme and brightness; a stat at normal and large text), navigation, money and time formats |
| `domain/`, `di/`, `architecture/` | 16 | The domain models; the DI graph resolves; **only the data layer, DI and the bootstrap import `package:flagkit`**, and flag keys appear only in `AppFlagKeys` |

### The accessibility tour

`test/app/accessibility_tour_test.dart` opens every screen and state (the homes, Checkout's steps and why lines, Profile signed in and out, the Dashboard and its tools, a flag's page with a rollout, rules, an override and a refused one, "Flag not found", "Page not found") in **light and dark at 200 % text**, and checks: no overflow, tap targets of at least 48 × 48, a label on everything tappable, text contrast.

### Deterministic rollouts

`pumpSample` starts the SDK with `FlagKitTesting.useAnonymousId('test-install')`: the guest's bucket for `new_checkout` is 4486 (outside 25 %), and `maya` (bucket 404) is inside. A random install id would make every rollout flow flaky.

---

## Mutation checks

Each phase broke its key rules on purpose, one at a time, and ran the tests that should catch the break (a runner kills the whole process group of a hung run).

| Phase | Mutations | Caught | Notes |
|---|---:|---:|---|
| 1 | 44 | 44 | 2 after new tests (`Updated ==` ignoring `skipped`; a getter reading another flag's key) |
| 2 | 42 | 42 | 1 after a new test (an unknown type with boolean-looking values) |
| 3 | 43 | 42 | 3 after new tests (not modified → `remote`; shutdown waiting; config `==` on the transport); 1 equivalent (the harness's latency) |
| 4 | 54 | 54 | 5 after new tests (the kill switch before non-matching rules; rules- or rollout-only changes; `FlagDetail ==` with the bucket; the why sentence at the threshold) |
| 5 | 39 | 38 | 3 after new tests or simpler code (the stats' network; the rollout line; a redundant re-inspection removed); 1 equivalent (the end-of-refresh tick) |
| 6 | 26 | 26 | The key rules of every phase (reads after shutdown, the widening, the kill switch, a missed rule's off value, the override's source, the threshold, the hash, the unit, caseless countries, missing attributes, versions, the parser's two levels, removed flags, the fresh boundary, offline, the 401 pause, not modified, single-flight, `startupWait`, the timer, `clearCache` keeping the install, the app's theme fallback and clamps, the context's country, the stat layout), each against its package's **whole** suite |

**248 mutations over six phases, 246 caught, 2 equivalent.** A test that can't fail proves nothing. When a mutation survived, either a test was missing (and was added), the code was redundant (and was removed), or the mutation was equivalent (and the summary says why).
