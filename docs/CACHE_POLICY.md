# Cache Policy

FlagKit keeps the server's definitions in its own SQLite database (`flagkit.sqlite`, drift) and serves every read from memory. The cache's **status** decides how hard the SDK refreshes; it **never** decides what a read returns.

---

## The four statuses

```dart
CacheStatus cacheStatusOf({DateTime? fetchedAt, required DateTime now,
                           required Duration refreshInterval, required Duration cacheExpiration});
```

| Status | When (age = now − the last successful fetch) | Reads | Refreshes |
|---|---|---|---|
| **empty** | never fetched (a first launch, or after `clearCache`) | the callers' defaults | at the first chance |
| **fresh** | age < `refreshInterval` (default 1 h); a fetch time in the future counts as fresh | cached values | none |
| **stale** | `refreshInterval` ≤ age < `cacheExpiration` (default 24 h) | cached values | at the next trigger |
| **expired** | age ≥ `cacheExpiration` | **still the cached values** | at every trigger |

- **Half-open intervals:** exactly at a boundary is the later status. The function is pure and tested at every edge (just under, exactly at, a future time, never fetched).
- **"Not modified" counts as a successful fetch:** it moves `fetchedAt`, so the cache is fresh again without a download.
- **A future `fetchedAt`** (the device's clock moved back) is fresh, not an error.

## Why expired values are still served

Offline, the last known flags are better than the app's defaults. A kill switch flipped off and cached must **stay off** for a user who's offline for two days; falling back to a default that may be "on" would undo it. "Expired" changes how hard the SDK tries to refresh, and the Dashboard warns about it; it never changes a read. (A "serve defaults when expired" option is on the [roadmap](ROADMAP.md).)

## Offline

- **Nothing is attempted offline.** The `NetworkMonitor` (`connectivity_plus` by default) says so; a manual `refresh()` returns `Offline` and is logged, automatic triggers are skipped.
- **Reads are unaffected:** they never touched the network.
- **A failed refresh changes nothing:** the cache and the snapshot stay, and the log says why.
- **Reconnecting refreshes**, if the cache isn't fresh.

The sample's **Device offline** switch wraps the real monitor, so a demo and a test behave exactly like a real outage.

---

## The refresh triggers

| Trigger | When | Skipped if |
|---|---|---|
| `startup` | `initialize` | fresh |
| `interval` | in the foreground, the moment the cache turns stale | fresh (re-armed for the new moment), offline, a rejected key |
| `resumed` | the app comes back to the foreground | fresh, offline, a rejected key |
| `reconnect` | the network comes back | fresh, a rejected key |
| `manual` | `FlagKit.refresh()` | — (it ignores freshness; offline → `Offline`) |

- **The interval timer is armed for `fetchedAt + refreshInterval`,** a one-shot timer re-armed when it fires, not a `Timer.periodic` from launch. A periodic timer started before the first fetch finishes ticks while the data is still fresh and skips a whole period (found on the device in Phase 3).
- **Single-flight:** triggers that overlap share one refresh; `changes` reports its value changes once.
- **A rejected key (401)** pauses automatic refreshes until the next `initialize`: every one would fail the same way.
- **Foreground only.** Flags are read in the foreground; background refresh (`workmanager`) is on the roadmap.

## The first launch

With nothing cached, a first screen would show the app's defaults and then flip when the first fetch lands. `startupWait` (0–10 s) lets `initialize` wait for that first fetch:

```dart
FlagKitConfig(apiKey: 'demo_key', startupWait: const Duration(seconds: 2))
```

- With **any** cache, it never waits: the cached flags are already better than defaults.
- If the fetch takes longer, `initialize` goes on with defaults, and the fetch lands when it lands.
- The timer is cancelled when the fetch wins, so none is left pending.

---

## What a refresh writes

One transaction: the valid definitions (upserted), the deletion of the ones the server no longer sends, the config version, `fetchedAt`. Then the snapshot is swapped. Reads see all of the old flags or all of the new, never a mix. The log entry and its counters are written in their own transaction.

## `clearCache()`

Deletes the cached definitions, the config version and `fetchedAt`: the status becomes **empty** and reads get the callers' defaults. It **keeps** the anonymous id (clearing a cache isn't a new install) and the local overrides (the developer's, not the server's). It doesn't refresh by itself; the next trigger does. `changes` reports every flag whose value changed.

## The database

| Table | Since | Holds |
|---|---|---|
| `flags` | v1 | the definitions: key, type, value and off value (JSON), enabled, `rollout_bp`, rules (JSON), updated at |
| `meta` | v1 | the anonymous id, `fetched_at`, the config version, the refresh counters |
| `refreshes` | v2 | the refresh log, the newest 50 |
| `overrides` | v3 | local overrides |

Every version is exported to `drift_schemas/` and an upgrade from each is tested with real rows; `CHECK`s refuse a broken row. If the file can't be opened, the session runs in memory (logged), and `initialize` still succeeds.
