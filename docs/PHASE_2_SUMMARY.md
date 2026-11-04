# Phase 2 — Storage + Cache Layer

## Phase Goal

Give the SDK a memory that survives the app:
- **a cache of definitions** in the SDK's own database: what the server sends, stored as it sent it;
- **a snapshot in memory**, loaded once at `initialize`, that every read answers from, synchronously;
- **the first steps of the evaluation order:** a flag that doesn't exist, a read of the wrong type, the kill switch;
- **a cache policy with exact boundaries:** fresh, stale, expired, empty, and the rule that expired flags are still served;
- **an anonymous id** per install, for the rollouts of Phase 4;
- **`clearCache()`**, and `changes` reporting what it changed;
- **a first debug tool** (`FlagKit.debug.watchStats()`), so the Dashboard can show the cache.

Nothing fills the cache from a server yet (that's Phase 3), so on a device it stays empty, and every read is still the app's default, now for a reason the SDK can explain.

---

## What Was Implemented

- **SDK 0.2.0 (public):**
  - **`CacheStatus`** (`fresh`, `stale`, `expired`, `empty`).
  - **`FlagKitDebug`** with `watchStats()`, and **`FlagKitStats`**: cache status, flag count, fetched at, config version, anonymous id. `FlagKitClient.debug` and `FlagKit.debug`.
  - **`package:flagkit/testing.dart`:** `FlagKitTesting.useInMemoryDatabase()` / `useDeviceDatabase()`.
  - `JsonValue.toString()` prints JSON.
- **SDK internals:**
  - **drift v1** (`flagkit.sqlite`, its own file): `flags` (key, type, value and off value as JSON, enabled, `rollout_bp`, `rules`, `updated_at`) and `meta`; a `CHECK` on every column that can be wrong; the schema exported (`drift_schemas/flagkit_database/drift_schema_v1.json`). The rollout and rules columns are there from v1, so Phase 4 needs no migration to add them.
  - **`FlagDao`:** `all`, `byKey`, `save` (`INSERT OR REPLACE`: a whole definition, every column, nothing references the table), `replaceAll` (save each, delete the rest), `clear`. **`MetaDao`:** read, write, remove.
  - **`FlagDefinition`:** key, value, off value (one type), enabled, updated at; `sameAs` for "the same definition".
  - **`flagValueFromJson(type, json)`:** a JSON value as a typed value, with the one conversion JSON forces (an integral, safe `double` is an `int`; an `int` is a `double`) and no other.
  - **The mapper:** a row that can't be read (an unknown type, a value of another type, bad JSON) is no definition, never a crash.
  - **`FlagSnapshot`:** the definitions, their source (`cache` or `remote`), fetched at, config version; immutable, replaced whole.
  - **`FlagRepository`:** opens the cache (creating the anonymous id on the first start; skipping unreadable rows, logged), `replace` (definitions, deletions, version and time in one transaction, then the swap), `clear` (keeps the anonymous id).
  - **`evaluateFlag`** (pure): not found → `flagNotFound`; another type → `typeMismatch` (`getDouble` on an `int` flag widens); switched off → the off value, `off`; otherwise the value, `fallthrough`.
  - **`cacheStatusOf`** (pure): half-open intervals; a future fetch time is fresh.
  - **The client:** opens the database (falling back to memory if it can't, logged), the repository and `DatabaseDebug`; reads evaluate against the snapshot; a wrong-typed read logs once per key; `clearCache` reports every key whose **evaluated value** changed; `shutdown` closes the database.
- **The sample:**
  - `FlagsDebug.watchCache()` → `CacheInfo` (`CacheState`, count, fetched at, install id), mapped from `FlagKitStats`.
  - **The Dashboard's Cache card:** the status as a chip-colored icon and a word, what it means, "Flags cached", "Fetched" (or "Never"), the install id and what it's for.
  - The tests start the real SDK on an in-memory cache (`FlagKitTesting.useInMemoryDatabase()` in the harness).
- **Tests: 231** (115 SDK, 116 sample).

---

## SDK Concepts Demonstrated

- **Cache the definitions, not the answers.** The cache holds what the server sends (a value, an off value, the kill switch, later rules and a rollout), so a context change re-evaluates without a request, offline included.
- **A snapshot, replaced whole.** Reads see one immutable object; a change builds the next and swaps a reference. No read waits for a write, and none sees half of two configs.
- **Write first, then swap.** The repository writes in one transaction and only then replaces the snapshot. A failed write leaves memory as it was: it never claims what the disk doesn't have.
- **Boundaries written down.** "Stale" and "expired" are useless until someone says exactly where they start. Half-open intervals give every instant one status; a clock moved back can't make flags look older than they are.
- **Expired is still served.** Offline, the last known flags beat defaults: a feature switched off and cached must stay off for a user offline for two days. Expiry changes how hard the SDK refreshes, never what a read returns.
- **Changes are about values.** `changes` reports flags whose evaluated value changed, not definitions that were touched: a refresh that rewrites the same values rebuilds nothing.
- **An anonymous id per install,** kept by `clearCache`: clearing a cache isn't a new install, and Phase 4's rollouts must not reshuffle users who press it.
- **Never fail `initialize` over storage:** a broken file means a session in memory, logged.

---

## Flutter / Dart Concepts Demonstrated

- **drift for an SDK:** its own file (`driftDatabase(name: 'flagkit')`), `CHECK` constraints as the last line of defence, JSON columns validated with `json_valid` and `json_type`, ISO text dates (`store_date_time_values_as_text`), `make-migrations` from v1.
- **`INSERT OR REPLACE` where it's right:** a whole row, no foreign keys; the upsert from a data class would leave `NULL`s unwritten (§11.57).
- **A watched custom query** (`customSelect(...).watchSingle()` with `readsFrom`) for stats that update on every write.
- **Pattern matching on JSON** (`final double value when value == value.truncateToDouble()`).
- **An immutable snapshot** with `Map.unmodifiable`, swapped by reference.
- **A second public library** (`testing.dart`) for hosts' tests, keeping test switches out of the everyday API.
- **Injected time and ids** (`Clock`, `SequentialIds`) for deterministic stats and anonymous ids.
- **Cancelling a Cubit's subscriptions together** (`Future.wait`, §11.94).

---

## Flag Evaluation Flow

```
FlagKit.initialize(config)
  → open flagkit.sqlite (or memory, logged)
  → FlagRepository.open: anonymous id (create on first start) · every readable row → FlagDefinition
  → FlagSnapshot(flags, source: cache, fetchedAt, configVersion)

FlagKit.getString('home_theme', 'ocean')
  → TypedReads → evaluate('home_theme', string)
  → evaluateFlag(definition: snapshot['home_theme'], source: cache, requested: string)
      no definition          → 'ocean'     (defaultValue, flagNotFound)
      an int flag            → 'ocean'     (defaultValue, typeMismatch; logged once)
      enabled: false         → 'classic'   (cache, off)          ← its off value
      otherwise              → 'modern'    (cache, fallthrough)

FlagKit.clearCache()
  → one transaction: delete flags, fetched_at, config_version (the anonymous id stays)
  → snapshot = empty → re-evaluate every key → changes.add({keys whose value changed})

FlagKit.debug.watchStats()
  → SELECT count(flags), fetched_at, config_version, anonymous_id (watched)
  → cacheStatusOf(fetchedAt, now, refreshInterval, cacheExpiration)
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `packages/flagkit/build.yaml` | drift's options: text dates, `make-migrations` paths |
| `packages/flagkit/drift_schemas/flagkit_database/drift_schema_v1.json` | Schema v1, to migrate from |
| `packages/flagkit/lib/src/storage/{tables,flagkit_database,flag_dao,meta_dao,meta_keys,flag_mapper}.dart` | The cache on disk |
| `packages/flagkit/lib/src/repository/{flag_definition,flag_snapshot,flag_repository}.dart` | Definitions, the snapshot, the repository |
| `packages/flagkit/lib/src/model/{flag_value_codec,cache_status,flagkit_stats}.dart` | JSON → values; the status; the stats |
| `packages/flagkit/lib/src/cache/cache_policy.dart` | `cacheStatusOf` |
| `packages/flagkit/lib/src/evaluation/flag_evaluator.dart` | `evaluateFlag` |
| `packages/flagkit/lib/src/debug/flagkit_debug.dart` | `FlagKitDebug`, `DatabaseDebug` |
| `packages/flagkit/lib/testing.dart`, `lib/src/testing/flagkit_testing.dart` | The testing library |
| `packages/flagkit/test/helpers/sdk.dart` | `testNow`, `SequentialIds`, `definition`, `seedCache`, `openTestClient` |
| `sample_app/lib/core/common/time_text.dart` | `clockTime` (from TrackLite) |

---

## Important Types Added

| Type | Kind | Role |
|---|---|---|
| `CacheStatus` | enum (public) | How fresh the cache is |
| `FlagKitDebug`, `FlagKitStats` | interface, class (public) | The debug surface and its stats |
| `FlagKitTesting` | class (public, `testing.dart`) | Switches for hosts' tests |
| `FlagDefinition` | class (internal) | A flag as the server defines it |
| `FlagSnapshot` | class (internal) | What reads see |
| `FlagRepository` | class (internal) | The cache in memory and on disk |
| `FlagKitDatabase`, `FlagDao`, `MetaDao` | drift (internal) | The cache on disk |
| `CacheInfo`, `CacheState` | class, enum (sample) | The cache in the app's words |

---

## Folder Structure Changes

```
packages/flagkit/
├── build.yaml                                   # new
├── drift_schemas/flagkit_database/drift_schema_v1.json   # new
├── lib/testing.dart                             # new
└── lib/src/
    ├── storage/      # new: tables, database, DAOs, mapper, meta keys
    ├── repository/   # new: definition, snapshot, repository
    ├── cache/        # new: the policy
    ├── debug/        # new: FlagKitDebug
    ├── testing/      # new: FlagKitTesting
    ├── evaluation/flag_evaluator.dart           # new
    └── model/{flag_value_codec,cache_status,flagkit_stats}.dart   # new
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| The cache | Room (`FlagEntity`, `FlagDao`) + DataStore | SwiftData + UserDefaults | drift: `flags` + `meta`, one file, one transaction |
| What's stored | `value: String` + type | the same | JSON values, an off value, the kill switch, room for rules and a rollout |
| Reads | from the cache | from an actor | from an immutable in-memory snapshot |
| Cache status | FRESH/STALE/EXPIRED/EMPTY (boundaries undefined) | the same | half-open boundaries; expired still served; a future time is fresh |
| Bad rows | — | — | skipped and logged; `CHECK`s refuse them at the write |
| Rollout unit | the user id | the user id | the user id, else an anonymous id per install (kept by `clearCache`) |
| Host tests | — | in-memory container | `FlagKitTesting.useInMemoryDatabase()` |

---

## Interview Notes

- **"Why cache the definitions rather than the evaluated values?"** Values depend on who's asking. With definitions on the device, a context change (sign in, a country) re-evaluates at once, offline included, and the server sends one config for every user.
- **"How do reads stay synchronous with a database underneath?"** The database is for surviving restarts. At start the client loads everything into an immutable snapshot; reads look up a map. Writes build the next snapshot and swap it in after the transaction commits.
- **"Should expired flags be served?"** Yes, here: the alternative is defaults, which may switch a feature back on that the server turned off. Expiry is a signal to refresh harder, not to forget.
- **"What happens if the cache file is corrupt?"** The SDK logs it and runs the session in memory: the app gets its defaults, never a crash at startup.
- **"Why an anonymous id, and why keep it on clearCache?"** Rollouts need a stable unit for signed-out users. Clearing a cache is a debugging action, not a new install: it mustn't move the user to another bucket.

---

## Learning Checklist

- ✅ A drift database for an SDK: its own file, `CHECK`s, JSON columns, an exported schema
- ✅ Definitions with a value and an off value, mapped safely from rows
- ✅ An immutable snapshot, loaded once, replaced whole, written before it's swapped
- ✅ The first steps of the evaluation order, as a pure function
- ✅ A cache policy with exact boundaries, as a pure function
- ✅ An anonymous id that survives `clearCache`
- ✅ `changes` reporting evaluated-value changes
- ✅ A debug stats stream from one watched query
- ✅ A testing library for hosts
- □ Fetching definitions (Phase 3)
- □ Rules and rollouts (Phase 4)

---

## Future Improvements

- **Phase 3:** the transport and the fake server, `refresh()` (single-flight, conditional by config version, per-flag validation, the atomic replace), the refresh log (drift v2), the network monitor and the triggers (startup, interval, resume, reconnect), `startupWait`.
- **Stats that age by themselves:** `watchStats()` emits on writes; a stale-turning cache with no write is noticed by the next emission. Phase 3's interval trigger writes on every refresh, and Phase 5's Dashboard can tick.

---

## Notes on This Phase

- **Spec adjustments:**
  - **`FlagKitDebug` arrives now** (the spec had it in Phase 5), with only `watchStats()`: the Dashboard's cache card needs it. Adding `debug` to `FlagKitClient` is a breaking change for hosts that implement it, noted in the changelog (TrackLite did the same in its Phase 2).
  - **The `flags` table has its final columns in v1** (`rollout_bp`, `rules`), written as `NULL` and `[]` until Phase 4.
  - **The anonymous id is shown on the Dashboard** ("Install id"); Profile shows it in Phase 4, when rollouts use it.
- **On the iPhone 17 Pro simulator:**
  - the Dashboard showed an empty cache, "Never" fetched, and the install id; after a relaunch, the same id (read with `sqlite3` from the app's container: `user_version` 1, one `meta` row);
  - **the read path on a real device:** six definitions written into the app's `flagkit.sqlite`, fetched two hours earlier, then a relaunch. The app opened on the new home with its banner and sections, 8 stories, in the teal "modern" look; Checkout was the one-page checkout with no discount (that flag was switched off: its off value, `0`); the Dashboard said **Expired** (the sample's 10-minute expiry), 6 flags, each from the cache with its reason. The rows were removed afterwards.
  - Found there: a JSON flag printed as Dart's `{banner: Spring sale, …}`; `JsonValue.toString()` now prints JSON.
- **CI on a clean copy:**
  - every step passed: generated code current, format, analyze, both suites, the publish dry run (0 warnings), `dart doc` (0 warnings);
  - **the first build of a fresh copy is slow:** drift's `sqlite3` builds its native library through a build hook the first time. Codegen took 26 minutes in this sandbox (25 seconds once built), and the first SDK test run failed with "Building native assets failed"; a second run passed all 115. A GitHub runner fetches the library over a normal network; the CI workflow is unchanged.
  - **the dry run's one hint:** a package named `flagkit` already exists on pub.dev (0.0.3, someone else's). Nothing here is published, so it's only a hint; publishing would need another name (noted for the roadmap).
- **Mutation checks:** 42 rules broken on purpose, one at a time, against both suites.
  - **40 were caught at first**, one of them by its timeout: "the harness on the device database" made a widget test try to open a real SQLite file, and it hung. That is why the harness calls `FlagKitTesting.useInMemoryDatabase()`.
  - **One didn't apply:** the formatter had wrapped `replaceAll`'s delete differently. Retargeted, it was caught.
  - **One was missed, and now has a test:** "an unknown type read as a boolean". The test's unknown-type row held `30`, which fails as a boolean anyway, so the mutation looked the same. An unknown type with `true` / `false` values must be skipped too.
  - **42 of 42 caught.**
