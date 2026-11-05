## 0.3.0

- **Flags come from a server.** `refresh()` fetches the definitions through a `RemoteConfigTransport` (`FlagKitConfig.transport`), and returns a `RefreshResult`: `Updated` (what was added, changed, removed and skipped), `NotModified`, `Offline`, `Failed` or `Unauthorized`.
- **Conditional fetches:** the SDK sends the config version it has (`FetchRequest.ifVersion`); an unchanged config comes back as `ConfigNotModified`, with no body, and the cache is fresh again.
- **Validation in two levels:** a malformed payload changes nothing; an invalid flag (an unknown type, a value of another type, a bad key, a second definition) is skipped and logged, and the rest apply. A flag with rules or a rollout is skipped until 0.4.0 can evaluate them.
- **One refresh at a time,** and the new definitions replace the cache in one transaction; reads see the old flags or the new ones, never a mix. `changes` reports the flags whose value changed.
- **Automatic refreshes,** none of them while the cache is fresh, offline, or after a rejected key: at `initialize`, every `refreshInterval` in the foreground, when the app comes back to the foreground, and on reconnect.
- **`startupWait`:** with nothing cached, `initialize` waits up to this long for the first fetch.
- **`NetworkMonitor`** (`ConnectivityNetworkMonitor` by default, or `FlagKitConfig.networkMonitor`): offline, nothing is attempted and the cached flags keep serving reads.
- **A rejected API key (401)** pauses automatic refreshes until the next `initialize`.
- **`FakeRemoteConfigServer`**, the default transport: definitions in the wire format, latency, a failure rate, reachability, a key check, conditional fetches, a console (`setFlag`, `setValue`, `setEnabled`, `removeFlag`) and `watchStats()`.
- **The refresh log** (schema v2, with a tested migration): `FlagKit.debug.watchRefreshes()` and `FlagKitStats.lastRefresh`, as `RefreshRecord`s.
- **`package:flagkit/testing.dart`:** `FakeNetworkMonitor`, `FlagKitTesting.disableTimers()`.

## 0.2.0

- **Flags are cached** in the SDK's own database (`flagkit.sqlite`, drift, schema v1 exported): every definition the server sends, with its value and its off value. They survive a restart and work offline.
- **Reads come from memory:** `initialize` loads the cached definitions once, into a snapshot; every read evaluates against it, synchronously. Its source is `cache` until a refresh.
- **The evaluation order starts:** no definition → your default (`flagNotFound`); another type → your default (`typeMismatch`, logged once); switched off → the flag's off value (`off`); otherwise its value (`fallthrough`). Rules and rollouts come in 0.4.0.
- **`CacheStatus`** (`fresh`, `stale`, `expired`, `empty`) with half-open boundaries on `refreshInterval` and `cacheExpiration`. Expired flags are still served.
- **`clearCache()`** forgets the cached flags, and `changes` reports every flag whose value changed. The anonymous id stays.
- **An anonymous id** per install (a UUID), created on the first start: the rollout unit when no user is signed in.
- **Debug tools:** `FlagKit.debug.watchStats()` gives `FlagKitStats` (cache status, flag count, fetched at, config version, anonymous id).
- **`package:flagkit/testing.dart`:** `FlagKitTesting.useInMemoryDatabase()` for an app's widget tests.
- If the database file can't be opened, the session's flags live in memory (logged), and `initialize` still succeeds.
- `JsonValue.toString()` prints JSON.
- **Breaking:** `FlagKitClient` has a new member, `debug`. Apps that implement the interface (a fake in their tests) add it.

## 0.1.0

- The public API's shape:
  - `FlagKit` (`initialize`, `isEnabled`, `getString`, `getInt`, `getDouble`, `getJson`, `getValue`, `detail`, `setContext`, `context`, `changes`, `refresh`, `clearCache`, `shutdown`, `instance`, `version`);
  - `FlagKitClient`, the same calls as an interface;
  - `FlagKitConfig`, with its rules checked at `initialize`;
  - `FlagValue` (`BoolValue`, `StringValue`, `IntValue`, `DoubleValue`, `JsonValue`), `FlagType`, `FlagSource`, `EvaluationReason`, `FlagDetail`, `EvaluationContext`;
  - `RefreshResult` and its six cases.
- Reads never throw and never wait. There are no flags yet, so every read returns the caller's default (`flagNotFound`, or `notInitialized` before `initialize`). The cache comes in 0.2.0 and the server in 0.3.0.
