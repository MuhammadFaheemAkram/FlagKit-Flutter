# SDK Design

How FlagKit's public API is shaped, and why. The API is one library, [`package:flagkit/flagkit.dart`](../packages/flagkit/lib/flagkit.dart), whose `show` lists name every public type; `test/public_api_test.dart` checks the list and uses every name the way a host would.

---

## The one rule

```
A flag read is synchronous, never throws, never waits for the network, and always returns a value:
the flag's evaluated value if FlagKit knows the flag, else the default the caller passed.
Every read can say where its value came from, and why.
```

Everything else follows from it.

- **Synchronous:** reads happen in `build` methods, on every frame. A `Future` would force every screen into a loading state for a value the SDK already has in memory.
- **Never throws:** a flag decides what a screen shows. A missing flag, a wrong type or a broken cache must degrade to the app's own default, never to a red screen.
- **Always a value:** the caller passes the default (`getInt('feed_page_size', 20)`), so the app decides its own fallback, the one it shipped before the flag existed.
- **Explainable:** `detail(key)` returns a `FlagDetail` with the value, its **source** (`override`, `remote`, `cache`, `defaultValue`) and its **reason** (`override`, `off`, `targetingMatch`, `targetingMiss`, `rolloutIncluded`, `rolloutExcluded`, `fallthrough`, `notInitialized`, `flagNotFound`, `typeMismatch`), plus the bucket for a rollout.

---

## The facade and the client

```dart
await FlagKit.initialize(const FlagKitConfig(apiKey: 'demo_key'));
FlagKit.isEnabled('new_checkout');            // the static facade

final FlagKitClient flags = FlagKit.instance;  // the same calls, as an interface
```

- **`FlagKit`** (static) is the quick path: one line to read a flag anywhere.
- **`FlagKitClient`** is the same API as an interface. An app with dependency injection registers `FlagKit.instance` and depends on the interface; its tests pass a fake. The sample does exactly this.
- **The facade outlives clients.** A context set before `initialize` is the one the client starts with; `changes` is one stream for the app's lifetime, across `shutdown` and a new `initialize`.
- **Before `initialize` and after `shutdown`,** reads return the caller's defaults (reason `notInitialized`) and `refresh()` returns `NotInitialized`: never an exception.

## Typed values

- **`FlagValue`** is sealed: `BoolValue`, `StringValue`, `IntValue`, `DoubleValue`, `JsonValue` (deep-frozen). A definition is parsed once, when it arrives; a read never parses.
- **No silent conversion.** `getInt` on a string flag returns the caller's default (`typeMismatch`, logged once), not a parsed number. The one widening is `getDouble` on an int flag.
- **Every flag has a value and an off value.** A string or number flag can be switched off, targeted or rolled out too: outside the rollout, a user gets the off value ("classic"), not the app's default.

## Errors

| Situation | What happens |
|---|---|
| A bad `FlagKitConfig` (a blank key, an interval under a minute, …) | `initialize` throws an `ArgumentError` naming every broken rule: a developer error, seen in development |
| A bad override (an invalid key, another type than the flag's) | `ArgumentError`: also a developer error |
| An unknown flag, a wrong type, not running | The caller's default, with the reason |
| A refresh that fails | A `RefreshResult` (`Failed`, `Unauthorized`, `Offline`, …), never an exception; the cache stays |
| A cache file that can't be opened | The session runs in memory, logged; `initialize` still succeeds |
| A malformed payload / an invalid flag | The refresh changes nothing / the flag is skipped and counted |

**Developer errors fail fast; runtime errors never reach the host.**

## Extension points

| Interface | Default | Why a host would replace it |
|---|---|---|
| `RemoteConfigTransport` | `FakeRemoteConfigServer` | A real backend: an HTTP client that sends the key in a header, `ifVersion` as `If-None-Match`, and maps 304 / 401 / 5xx to the sealed responses and errors |
| `NetworkMonitor` | `ConnectivityNetworkMonitor` (`connectivity_plus`) | A demo switch (the sample's), or a smarter reachability check |
| `EvaluationContext.attributes` | — | Any custom attribute a rule can target (a plan, a cohort) |

The transport's contract is small on purpose: fetch, return `FetchedConfig(json)` or `ConfigNotModified`, or throw `ServerUnreachable`, `ServerFailure(status)` or `ApiKeyRejected`. Validation, caching, retries, the log and the schedule stay in the SDK.

## The debug tools

`FlagKit.debug` (`FlagKitDebug`) is kept apart from the everyday API, so an app's screens never depend on it:
- `watchStats()`, `watchRefreshes()`: the cache, the network, refreshing, reads by source, the counters, the log;
- `watchFlags()`, `definitions`, `evaluateFor(key, context)`, `explain(key)`: every flag and why;
- `setOverride`, `clearOverride`, `clearOverrides`: local overrides.

## Dependencies

| Package | Why |
|---|---|
| `flutter`, `meta` | `@immutable`, `@internal`, `listEquals` and friends; `AppLifecycleListener` for resume |
| `drift`, `drift_flutter` | The cache: typed SQL, transactions, watched queries, exported schemas and tested migrations |
| `clock` | An injectable "now": every time-based rule is tested at its edges |
| `uuid` | The install's anonymous id |
| `connectivity_plus` | The default network monitor |

Each is a caret on a major. No DI container, no state management, no rxdart, no generated code in the public API.

## Versioning

- The SDK's version lives in three places (`lib/src/version.dart`, `pubspec.yaml`, the top of `CHANGELOG.md`); `version_test.dart` checks they agree.
- A new public name, or a new member of a public interface (`FlagKitClient`, `FlagKitDebug`), is noted in the changelog as breaking for apps that implement it (their fakes).
- **The hash is frozen:** a different bucketing would move every user of every rollout, so it would be a new major version.
- **Schemas only grow:** each version is exported to `drift_schemas/`, and an upgrade from every earlier version is tested.

## The host's setup

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlagKit.initialize(
    FlagKitConfig(
      apiKey: 'demo_key',
      refreshInterval: const Duration(minutes: 5),
      startupWait: const Duration(seconds: 2), // a first launch waits for real values
      transport: MyHttpTransport(),
    ),
  );
  FlagKit.setContext(EvaluationContext(userId: user?.id, country: 'PK', appVersion: '2.1.0'));
  runApp(const MyApp());
}
```

In tests: `FlagKitTesting.useInMemoryDatabase()`, `disableTimers()`, `useAnonymousId('test-install')`, and `FakeNetworkMonitor` (`package:flagkit/testing.dart`).
