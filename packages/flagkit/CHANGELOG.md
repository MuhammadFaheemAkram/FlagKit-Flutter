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
