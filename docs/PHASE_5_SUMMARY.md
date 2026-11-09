# Phase 5 — Dashboard + SDK Features

## Phase Goal

Give the SDK the tools a team uses every day, and the sample a screen that shows everything the SDK knows:
- **local overrides:** force a flag on this device, kept across restarts, winning over everything, and always visible as an override;
- **explainability, in full:** every flag with its reason and bucket, the server's definitions, each rule and whether it matches, and "what would this other user get?";
- **stats that tell the story:** online, refreshing, reads by source, and counts of refreshes, failures and skipped definitions that outlive the log;
- **the Dashboard** as the learning screen: the cache and its actions, every flag and its detail page, "Try a user", the demo server's console, the refresh log and the counts.

---

## What Was Implemented

- **SDK 0.5.0 (public):**
  - **Overrides** on `FlagKitDebug`:
    - `setOverride(key, value)` validates the key and the type, then writes before it swaps (like the definitions);
    - `clearOverride(key)` and `clearOverrides()`;
    - `changes` reports them, `clearCache` keeps them.
  - **The order** starts with the override: override → not found → type mismatch → off → rules → rollout → fallthrough. An override read as another type still gets the caller's default.
  - **`watchFlags()`:** every flag the SDK can answer (each definition, and each override of a flag the server doesn't send), by key. It emits again after every refresh, context change or override, even when only a reason or a bucket changed.
  - **`definitions`** (`FeatureFlag`, a public view of a definition), **`evaluateFor(key, context)`** and **`explain(key, {context})`** (`FlagExplanation`: the detail, the definition, the override, and each rule as a `RuleMatch`).
  - **`FlagKitStats`** gains:
    - `overrideCount`, `online`, `refreshing`;
    - `evaluations` (this session's reads by source);
    - `refreshCount`, `failedRefreshCount` and `skippedCount`.

    A tick that changes nothing the stats show emits nothing.
- **SDK (internal):**
  - **schema v3:** the `overrides` table (key, type, JSON value, created at; `CHECK`s), exported, with a data migration test from v2;
  - **`OverrideDao`, the override mapper, `FlagRepository.overrides`** (an unreadable row is skipped);
  - **the counters** (`refresh_total`, `refresh_failed_total`, `skipped_total` in `meta`), written in the log's own transaction;
  - **`ClientDebug`** replaces `DatabaseDebug`: the stats come from one watched query plus the client's live state (a tick stream, the network monitor);
  - **`_changing`** takes the values before the change: an override changes no definition, only what reads return;
  - **`isValidFlagKey`**, shared by the parser and `setOverride`.
- **The sample:**
  - **`FlagsDebug` port** grows:
    - `inspect` (`FlagInspection`: the reading, the server's value and off value, the kill switch, each rule as a `RuleCheck`, the override);
    - `readFor(userId)`;
    - `setOverride(key, text)`, which returns what's wrong in words;
    - `clearOverride` / `clearOverrides`, `clearCache` and `watchRefreshLog`.

    `CacheInfo` gains the version, overrides, refreshing, reads and counts.
  - **A new `DemoServer` port** (`FakeServerDemo` over the SDK's fake server): flags on and off, a rollout, the look it serves, the failure rate and the latency.
  - **The Dashboard** in sections:
    - the cache with Refresh, Clear cache (asks first) and Clear overrides;
    - the network;
    - every flag (kind, source, reason, bucket), tappable;
    - "Try a user" (`TryUserCubit`);
    - the server console (`ServerConsoleCubit`);
    - the refresh log and the stats.
  - **A flag's page** (`/dashboard/flags/:flagKey`, `FlagDetailCubit`) shows:
    - what you get;
    - the server's definition;
    - the rollout and where you fall in it;
    - each rule with a check or a cross;
    - an override: On / Off for an on/off flag, a typed value for the rest.

    A stale link shows "Flag not found".

---

## SDK Concepts Demonstrated

- **Overrides are debug tools, and look like it.** They win over everything (even the kill switch), but the source says `override`, so nobody mistakes a forced value for the server's. They're kept until cleared, because a developer testing a flow restarts the app.
- **Overrides belong to the device, not the server.** `clearCache` forgets what the server said, and keeps what the developer set.
- **An override is still typed.** Forcing a string onto an int flag is a developer error (an `ArgumentError`); a read of another type than the override's still gets the caller's default.
- **Report evaluated changes, measured before the change.** The definitions don't move when an override is set; comparing "before" values taken after the write reported nothing. The values are now taken first.
- **Two kinds of "something changed."** `changes` is for the app: a value changed. The debug tools need more: a new bucket or reason with the same value (signing in to the same side of a rollout) must refresh the Dashboard too. The client has a separate tick for them.
- **Explainability is a public API.** `explain` returns each rule's result, so a support screen can say "the rule *country is one of PK, AE* doesn't match you" without knowing how targeting works.
- **"What would this user get?"** `evaluateFor` evaluates for another context without touching the current one. Overrides still apply: they're this device's, whoever is asking.
- **Counters outlive the log.** The log keeps 50 entries; the totals live in `meta`, updated in the same transaction as the log entry, so they can't drift apart.
- **Schema evolution, again:** a new table, a new exported version, a migration tested with real rows.

---

## Flutter / Dart Concepts Demonstrated

- **A stream merged by hand:** `watchStats` listens to a drift query, the client's ticks and the network monitor, builds the stats in order (one `Future` chain), and skips duplicates. No rxdart.
- **`late final debug = ClientDebug(this)`:** an object that needs its owner, without a constructor cycle.
- **Typed routes with a path parameter** (`FlagDetailRoute(flagKey:)`), nested under the Dashboard's route so a deep link has the Dashboard beneath it.
- **`@factoryParam` in injectable** (`getIt<FlagDetailCubit>(param1: key)`).
- **One Cubit per concern** on one screen (`MultiBlocProvider`): the Dashboard, Try a user, the server console.
- **Widget tests at large sizes:** a surface taller than about 15,000 physical pixels fails to rasterize page transitions; lazy lists build only what's on screen (`scrollUntilVisible`).

---

## Flag Evaluation Flow

```
read(key, type)                                    (synchronous, for the current context)
  → not running                                    → your default     (notInitialized)
  → an override                                    → the override     (override)       ← a debug tool: wins over everything
       read as another type                        → your default     (typeMismatch)
  → no definition                                  → your default     (flagNotFound)
  → another type                                   → your default     (typeMismatch)
  → switched off                                   → off value        (off)
  → rules that don't all match                     → off value        (targetingMiss)
  → a rollout: bucket < rollout × 100              → value / off value (rolloutIncluded or targetingMatch / rolloutExcluded)
  → otherwise                                      → value            (fallthrough or targetingMatch)
  → evaluations[source] += 1                       (the app's reads only)

setOverride(key, value)
  → a valid key? the flag's type? (else ArgumentError)
  → values before → write the row → swap the overrides → values after → changes + tick

debug
  watchFlags   = every known key, sorted, evaluated now and on every tick
  explain(key) = detail + definition + override + [rule → matches?]
  watchStats   = the database row + live state (online, refreshing, reads), on every write, tick or network change
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `packages/flagkit/lib/src/debug/client_debug.dart` | The debug tools over a running client |
| `packages/flagkit/lib/src/model/{feature_flag,flag_explanation,flag_key}.dart` | `FeatureFlag`, `FlagExplanation`, `RuleMatch`; the key rule |
| `packages/flagkit/lib/src/storage/{override_dao,override_mapper}.dart`, `Overrides` table | Overrides on disk |
| `packages/flagkit/drift_schemas/flagkit_database/drift_schema_v3.json`, `test/drift/flagkit_database/generated/schema_v3.dart` | Schema v3 and its migration test |
| `packages/flagkit/test/client/client_debug_test.dart` | Overrides, `watchFlags`, `explain`, the stats on a real client |
| `sample_app/lib/domain/demo/demo_server.dart`, `lib/data/demo/fake_server_demo.dart` | The server console's port and adapter |
| `sample_app/lib/features/dashboard/flag_detail_page.dart`, `cubit/{flag_detail,try_user,server_console}_cubit.dart` | A flag's page; the new Cubits |
| `sample_app/lib/features/dashboard/widgets/` | The Dashboard's sections |
| `sample_app/test/data/flagkit_flags_debug_test.dart`, `test/features/dashboard/dashboard_tools_test.dart` | The adapters on the real SDK; the tools' Cubits and views |

---

## Important Types Added

| Type | Kind | Role |
|---|---|---|
| `FeatureFlag` | class (public) | A definition as the server sent it |
| `FlagExplanation`, `RuleMatch` | classes (public) | Everything behind one read |
| `FlagKitDebug` (+ 7 members), `FlagKitStats` (+ 7 fields) | public | Overrides, flags, another user, the counts |
| `ClientDebug`, `OverrideDao`, `OverrideRow` | internal | The tools; overrides on disk |
| `FlagInspection`, `RuleCheck`, `FlagKind` | sample domain | A flag explained, in the app's words |
| `DemoServer`, `ServerFlag`, `ServerKnobs`, `ServerFailures`, `ServerSpeed` | sample domain | The console |
| `TryUserCubit`, `ServerConsoleCubit`, `FlagDetailCubit` | sample | The Dashboard's tools |

---

## Folder Structure Changes

```
packages/flagkit/
├── drift_schemas/flagkit_database/drift_schema_v3.json    # new
├── lib/src/
│   ├── debug/client_debug.dart                          # new (replaces DatabaseDebug)
│   ├── model/{feature_flag,flag_explanation,flag_key}.dart # new
│   └── storage/{override_dao,override_mapper}.dart        # new
└── test/client/client_debug_test.dart                     # new

sample_app/lib/
├── domain/demo/demo_server.dart                           # new
├── data/demo/fake_server_demo.dart                        # new
└── features/dashboard/
    ├── flag_detail_page.dart                              # new
    ├── cubit/{flag_detail,try_user,server_console}_cubit.dart  # new
    └── widgets/{reading_tile,try_user_section,server_console_section,stats_section}.dart  # new
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Overrides | — | — | persisted (schema v3), win over everything, source `override`, kept by `clearCache` |
| Every flag | a list of values | a list of values | `watchFlags`: value, source, reason, bucket; updates on any input change |
| Why one flag | the source | the source | `explain`: the definition, the override, each rule's result |
| Another user | the user id per read | the user id per read | `evaluateFor(key, context)`, the app's context unchanged |
| A server console | a hardcoded fake | a hardcoded fake | a console over the fake server (on/off, rollout, the look, failures, latency) |
| Counts | — | — | reads by source; refreshes, failures and skipped definitions that outlive the log |

---

## Interview Notes

- **"How do QA and developers test a flag that's at 5 %?"** A local override: persisted, winning over everything, clearly marked as an override in every explanation. Or "try a user" until one lands in the rollout.
- **"Should clearing the cache clear overrides?"** No. The cache is the server's data; overrides are the developer's. Clearing one mustn't silently undo the other.
- **"Your `changes` stream missed overrides. Why?"** It compared values before and after a change, but took the "before" values after the write. With definitions that's invisible (the snapshot was replaced), with overrides it isn't. Take the snapshot of values first.
- **"Why a separate tick for the debug screen?"** `changes` fires when a value changes; a debugging screen also needs a new reason or bucket with the same value.
- **"How do you keep counters correct when the log is capped?"** Keep the totals separately, and update them in the same transaction as the log entry.
- **"How do you explain a flag to support?"** Return each rule's result, not just the outcome: "country is one of PK, AE — doesn't match you."

---

## Learning Checklist

- ✅ Persisted local overrides, first in the evaluation order, typed, visible as overrides
- ✅ A third schema version with a data migration test
- ✅ `watchFlags`, `definitions`, `evaluateFor`, `explain`
- ✅ Stats from a database query merged with live state, without duplicates
- ✅ Counters that outlive a capped log
- ✅ A full debug dashboard: a flag's page, "try a user", a server console
- ✅ Typed routes with a parameter; factory parameters in DI
- □ The final documentation set, screenshots, a release build (Phase 6)

---

## Future Improvements

- **Phase 6:** the docs (`ARCHITECTURE.md`, `SDK_DESIGN.md`, `EVALUATION.md`, `ROLLOUTS.md`, `TARGETING.md`, …), screenshots, a release-build launch, a final mutation pass.
- **Overrides that expire** (a debugging override left on by mistake), and an override for a whole user, not just this device.
- **The reads-by-source count** is as of the stats' last change; a periodic tick could keep it live while the Dashboard is open.

---

## Notes on This Phase

- **Spec adjustments:**
  - **`explain` / `FlagExplanation` / `RuleMatch`** (not in the spec's API): the detail page shows "each rule and whether it matched", and only the SDK can evaluate a rule.
  - **`FeatureFlag`** is a public view, separate from the internal definition: the debug API shows rollouts in percent and doesn't expose basis points or `sameAs`.
  - **Overrides apply to `evaluateFor` too:** they're this device's, whoever is asking.
  - **A flag's page is always a pushed page** (the spec offered a sheet at normal text): one layout to test, and it's a deep link. Nested under the Dashboard's route, a cold link opens with the Dashboard beneath, so no Close fallback is needed.
  - **`FakeRemoteConfigServer.watchStats()`** arrived in Phase 3; this phase only uses it (for the console).
  - **The counters start with 0.5.0:** an upgraded install counts from 0, while its log already holds older entries.
- **Found on the device (the iPhone 17 Pro simulator):**
  - the Phase 4 database (v2) migrated in place to v3, keeping the six flags, config version 2 and the install id; `PRAGMA user_version` read 3;
  - `new_checkout`'s page showed bucket 2679, "not below 2500, so you're out"; **Override: on** turned Checkout into the one-page checkout, and the override was still there after a relaunch (the row in `overrides`, source `override`);
  - the counters matched the database (`refresh_total` 2, then counting each interval refresh);
  - "Try a user" with `maya` showed every flag for her; `new_checkout` showed the override, as documented;
  - the console, its rollout and theme choices, the log and the stats read well in dark mode; Clear 1 override brought the count back to 0.
- **Found in the tests:**
  - **`changes` missed overrides:** `_changing` compared values taken after the write. Taken before, an override is reported.
  - **Stats emitted duplicates** once ticks fed them (a context change re-sent identical stats); identical stats are now skipped.
  - **The first `FlagExplanation` had a field named `override`,** which hid the `@override` annotation in that class. It's now `overrideValue`.
  - **Widget tests on a long screen:** a surface 8,000 points tall failed to rasterize page transitions; 5,000 works, and a lazy list needs `scrollUntilVisible` at 200 % text.
- **Mutation checks:** 39 rules broken on purpose, one at a time.
  - **34 were caught at first** (one anchor had to be fixed after formatting).
  - **Three were missed, and now have tests or simpler code:**
    - **the stats ignoring the network:** no test changed it while watching; one does now;
    - **the rollout line's "in" or "out":** the tests checked only the number; they now check the sentence, and the threshold's edge;
    - **the flag page re-inspecting after an override:** redundant, as the page already follows the flags' stream. The line is gone, and a mutation of the stream (the page not following the flags) is caught.
  - **One is equivalent:** the tick when a refresh ends. Every refresh writes its log entry, and the stats re-read the live "refreshing" when that write lands, after it ended. The tick stays, so the stats don't depend on that order.
  - **38 of 39 caught, 1 equivalent.**
- **523 tests:** 304 SDK, 219 sample.
