# Evaluation

Every read (`isEnabled`, `getString`, `getInt`, `getDouble`, `getJson`, `getValue`, `detail`) runs the same pure function, `evaluateFlag` (`lib/src/evaluation/flag_evaluator.dart`), against the in-memory snapshot. It takes a definition (or none), the read's type, the evaluation context, the rollout unit and the override (or none), and returns a `FlagDetail`.

---

## The order

```
1. FlagKit not running                       → the caller's default   notInitialized
2. a local override for the key              → the override          override
     read as another type                    → the caller's default   typeMismatch
3. no definition                             → the caller's default   flagNotFound
4. read as another type than the flag's      → the caller's default   typeMismatch     (getDouble accepts an int flag)
5. switched off (enabled: false)             → the off value          off              ← the kill switch
6. rules, and not all of them match          → the off value          targetingMiss
7. a rollout:
     bucket(key, unit) < rollout × 100       → the value              targetingMatch (with rules) / rolloutIncluded
     otherwise                               → the off value          rolloutExcluded
8. otherwise                                 → the value              targetingMatch (with rules) / fallthrough
```

**The first step that applies decides.** Each row is a test in `test/evaluation/flag_evaluator_test.dart`, and so is each row's place in the order (for example, the kill switch with rules that match, and with rules that don't).

### Why this order

- **Overrides first:** they're a developer's tool for testing a path ("show me the new checkout"). They must win over everything, or they'd be useless for exactly the flags that are off or rolled out.
- **The kill switch before targeting and the rollout:** switching a flag off must work for everyone, whatever rules or percentages it has. That's the whole point of a kill switch.
- **Targeting before the rollout:** targeting decides who is **eligible**, the rollout decides what **share of the eligible** get it. "25 % of users in Pakistan" means a quarter of the Pakistani users, not "a quarter of everyone, if they happen to be in Pakistan". This is the order Unleash and LaunchDarkly use.
- **Type checks before the value:** a read never converts silently. `getInt` on a string flag is a bug in the app; it gets its own default, and the SDK logs it once.

---

## Sources

| Source | Meaning |
|---|---|
| `override` | A local override set on this device (`FlagKit.debug.setOverride`) |
| `remote` | A definition fetched (or confirmed "not modified") in this session |
| `cache` | A definition loaded from the device's cache at start, not yet confirmed by the server this session |
| `defaultValue` | The caller's default: FlagKit had no value of the right type |

## Reasons

| Reason | Value | When |
|---|---|---|
| `override` | the override | A local override is set |
| `off` | the off value | The flag is switched off on the server |
| `targetingMatch` | the value (or, with a rollout, the value only inside it) | The flag has rules and all of them match |
| `targetingMiss` | the off value | Some rule doesn't match (or the context lacks its attribute) |
| `rolloutIncluded` | the value | No rules; the user's bucket is inside the rollout |
| `rolloutExcluded` | the off value | The user's bucket is outside the rollout |
| `fallthrough` | the value | On, no rules, no rollout: everyone |
| `notInitialized` | the caller's default | Before `initialize` or after `shutdown` |
| `flagNotFound` | the caller's default | No definition and no override |
| `typeMismatch` | the caller's default | The read's type isn't the flag's (or the override's) |

---

## Worked examples

The demo server's flags (`sample_app/assets/remote_config.json`):

```json
{ "key": "new_checkout", "type": "boolean", "value": true, "offValue": false, "enabled": true, "rollout": 25 }
{ "key": "home_theme", "type": "string", "value": "modern", "offValue": "classic", "enabled": true,
  "rules": [{ "attribute": "country", "operator": "in", "values": ["PK", "AE"] }] }
```

| Who is asking | `detail('new_checkout')` | `detail('home_theme')` |
|---|---|---|
| A guest, install bucket 2679 | `false`, `rolloutExcluded`, bucket 2679 of 25 % | `"classic"`, `targetingMiss` (no country) |
| The same guest, country PK | `false`, `rolloutExcluded` | `"modern"`, `targetingMatch` |
| Signed in as `maya` (bucket 404) | `true`, `rolloutIncluded`, bucket 404 | depends on the country |
| `new_checkout` switched off in the console, then Refresh | `false`, `off` (whoever is asking) | — |
| An override `new_checkout = true` | `true`, `override`, source `override` | — |
| `getInt('new_checkout', 0)` | `0`, `typeMismatch` (it's an on/off flag) | — |
| A key the server doesn't send | the caller's default, `flagNotFound` | — |

Try them in the sample: Profile sets the country and the user; the Dashboard's flag pages show the reason and the bucket; the console switches flags off; "Try a user" evaluates another id.

---

## `changes`

```dart
FlagKit.changes.listen((Set<String> keys) { /* rebuild what reads them */ });
```

- It emits the keys whose **evaluated value** changed, not the definitions that changed: a new definition that changes nothing a read returns emits nothing.
- It fires after a refresh, a context change (`setContext`), an override, `clearCache`.
- The values "before" are taken **before** the change. (An override changes no definition, only what reads return; comparing values taken after the write missed it. Found in Phase 5.)
- One stream for the app's lifetime: it stays open across `shutdown` and a new `initialize`.

The debug tools follow a separate tick: `debug.watchFlags()` emits when anything an evaluation depends on changes, even when no value does (signing in to the same side of a rollout gives a new bucket, the same value).

## `FlagDetail`

```dart
final detail = FlagKit.detail('new_checkout');
detail.value;           // BoolValue(false), or null for the caller's default
detail.source;          // FlagSource.remote
detail.reason;          // EvaluationReason.rolloutExcluded
detail.bucket;          // 2679 (rollouts only)
detail.rolloutPercent;  // 25.0 (rollouts only)
```

For a debug screen, `FlagKit.debug.explain(key)` adds the definition, the override, and each rule with whether it matches.
