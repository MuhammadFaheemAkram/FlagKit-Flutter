# flagkit

A small feature flag SDK for Flutter apps, built to show how one is designed:
- typed flag reads that are synchronous and never fail;
- an offline-first cache, and remote refresh;
- deterministic percentage rollouts and user targeting;
- an answer to "why does this flag have this value?" for every read.

It talks to a fake remote config server: this is a learning project, not a hosted service.

> **Status: 0.4.0: targeting and rollouts.** Definitions come from a `RemoteConfigTransport` (a fake server by default), are cached on the device, and every read evaluates them in memory for the current `EvaluationContext`: the kill switch, then targeting rules, then a percentage rollout. Overrides arrive in 0.5.0.
> See the [repository](https://github.com/MuhammadFaheemAkram/FlagKit-Flutter) for the plan, the sample app and the design docs.

## Usage

```dart
import 'package:flagkit/flagkit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlagKit.initialize(
    const FlagKitConfig(apiKey: 'demo_key', debugMode: true),
  );
  runApp(const MyApp());
}

// Anywhere in the app, synchronously:
if (FlagKit.isEnabled('new_home_screen')) { /* the new UI */ }
final pageSize = FlagKit.getInt('feed_page_size', 20);
final theme = FlagKit.getString('home_theme', 'classic');
final discount = FlagKit.getDouble('discount_percentage', 0);
final config = FlagKit.getJson('home_config', const {});

// Who is asking (targeting and rollouts use it):
FlagKit.setContext(const EvaluationContext(userId: 'user_123', country: 'PK'));

// Why a flag has its value:
final detail = FlagKit.detail('new_checkout'); // value, source, reason
```

**With dependency injection,** register `FlagKit.instance` (a `FlagKitClient`) and depend on the interface. Your tests can then pass a fake.

## Rules it keeps

- **Reads are synchronous and never throw.** They never wait for the disk or the network. With no value of the right type, they return the default you passed.
- **No silent conversion.** `getInt` on a string flag returns your default, not a parsed number. The one widening is `getDouble` on an integer flag.
- **A bad configuration is the one exception:** `initialize` throws an `ArgumentError` naming every broken rule, so you see it in development.
- **Before `initialize` and after `shutdown`,** reads return your defaults (reason `notInitialized`) and `refresh()` returns `NotInitialized`.
- **A context set before `initialize`** is the one the SDK starts with.
- **Without `debugMode`, the SDK is silent.** With it, an unknown flag or a wrong-typed read is logged once per session, not on every build.
- **Cached, read from memory.** Definitions live in the SDK's own `flagkit.sqlite`, survive restarts and work offline; `initialize` loads them once, and reads never touch the disk.
- **Every flag has a value and an off value.** Switched off on the server, a flag serves its off value (reason `off`), whatever else applies.
- **Expired flags are still served.** The cache's status (`fresh`, `stale`, `expired`, `empty`) decides how hard FlagKit refreshes, never what a read returns.
- **`clearCache()`** forgets the cached flags (not the install's anonymous id), and `changes` reports the flags whose value changed.
- **A cache file that can't be opened** never fails `initialize`: the session runs in memory, logged.

## Refreshing

`refresh()` fetches the definitions now and returns a `RefreshResult` (`Updated`, `NotModified`, `Offline`, `Failed`, `Unauthorized`); you rarely need it:
- **at `initialize`,** a cache that isn't fresh is refreshed. With nothing cached, `startupWait` lets `initialize` wait for that first fetch, so the first screen shows real values;
- **in the foreground,** the moment the cache turns stale (`refreshInterval`);
- **when the app comes back** to the foreground, and **on reconnect**, if the cache isn't fresh.

None runs offline or after the server rejected the key (401). Each fetch sends the cached config version, so an unchanged config comes back "not modified" with no body. A malformed payload changes nothing; an invalid flag is skipped and the rest apply. Refreshes run one at a time, and the new definitions replace the cache in one transaction.

The default transport is an empty `FakeRemoteConfigServer`. Give it your flags, or write your own transport:

```dart
await FlagKit.initialize(
  FlagKitConfig(
    apiKey: 'demo_key',
    transport: FakeRemoteConfigServer(flags: [
      {'key': 'new_home_screen', 'type': 'boolean', 'value': true, 'offValue': false},
    ]),
  ),
);

class HttpTransport implements RemoteConfigTransport {
  @override
  Future<FetchResponse> fetch(FetchRequest request) async {
    // GET the config with request.apiKey in a header and request.ifVersion
    // as If-None-Match; 304 → ConfigNotModified, 200 → FetchedConfig(json);
    // throw ServerUnreachable / ServerFailure / ApiKeyRejected.
  }
}
```

The wire format: `{"version": 7, "flags": [{"key": "home_theme", "type": "string", "value": "modern", "offValue": "classic", "enabled": true}]}`. Types: `boolean`, `string`, `int`, `double`, `json`.

## Targeting and rollouts

A flag's definition can carry **rules** and a **rollout**:

```json
{"key": "new_checkout", "type": "boolean", "value": true, "offValue": false,
 "rules": [{"attribute": "country", "operator": "in", "values": ["PK", "AE"]}],
 "rollout": 25}
```

Every read evaluates, in order:

1. no definition → your default (`flagNotFound`); another type → your default (`typeMismatch`);
2. switched off → the off value (`off`): **the kill switch beats everything below**;
3. rules that don't **all** match → the off value (`targetingMiss`);
4. a rollout → the value for that share of the users still eligible (`targetingMatch` with rules, `rolloutIncluded` without), the off value for the rest (`rolloutExcluded`);
5. otherwise → the value (`targetingMatch` with rules, `fallthrough` without).

**Rules** look at the `EvaluationContext`: `userId`, `country`, `appVersion`, or any key of `attributes`. Operators: `equals`, `notEquals`, `in`, `notIn`, `startsWith`, `endsWith`, `contains`, `greaterThan`, `lessThan`, `semverAtLeast`, `semverBelow`.
- **A missing attribute never matches,** not even `notEquals` or `notIn`: a user whose country isn't known isn't "not in Pakistan".
- Values compare by kind: text as text (country codes without regard to case), numbers as numbers, **versions as versions** (`2.10.0` is after `2.9.0`; a malformed version never matches).
- An operator this version doesn't know (a newer server's) never matches, and is logged.

**Rollouts** (0–100, in steps of 0.01) put each user in a bucket: FNV-1a (32-bit) of `"key:unit"` over UTF-8, mod 10,000. A user is in when their bucket is below the rollout × 100.
- **The same on every device and run,** and in any language that implements FNV-1a: no `hashCode`.
- **Independent per flag:** the key is in the hash, so no one is first in every rollout.
- **Monotonic:** raising 10 % to 25 % keeps everyone who had it.
- **The unit** is `context.userId`, else the install's anonymous id. A guest keeps their answer across launches; a signed-in user, across devices. Signing in can change the answer.

`setContext` re-evaluates every flag, and `changes` reports the ones whose value changed. `detail(key)` explains a read: its `reason`, and for a rollout the user's `bucket` and the `rolloutPercent`.

## Debug tools

```dart
FlagKit.debug.watchStats().listen((stats) {
  // stats.cacheStatus, .flagCount, .fetchedAt, .configVersion, .anonymousId,
  // stats.lastRefresh (a RefreshRecord)
});
FlagKit.debug.watchRefreshes(); // the refresh log, newest first
```

## Testing your app

```dart
import 'package:flagkit/testing.dart';

setUp(() async {
  FlagKitTesting.useInMemoryDatabase(); // widget tests have no file system
  FlagKitTesting.disableTimers();       // no timer pending when a test ends
  await FlagKit.initialize(
    FlagKitConfig(
      apiKey: 'test',
      transport: FakeRemoteConfigServer(latency: Duration.zero),
      networkMonitor: FakeNetworkMonitor(), // set `.online = false` to go offline
    ),
  );
});
tearDown(FlagKit.shutdown);
```

With rollouts, a new install's random id puts your test user in a random bucket. `FlagKitTesting.useAnonymousId('test-install')` names it, so the test knows which side of each rollout it's on (`useRandomAnonymousIds()` undoes it).

Or depend on `FlagKitClient` (register `FlagKit.instance`) and pass a fake.

## Configuration

| Option | Default | Range |
|---|---|---|
| `apiKey` | required | not blank |
| `refreshInterval` | 1 h | ≥ 1 min: how long fetched flags stay fresh |
| `cacheExpiration` | 24 h | ≥ `refreshInterval`: when they count as expired (still served) |
| `startupWait` | 0 | 0–10 s: with nothing cached, how long `initialize` waits for a first fetch |
| `transport` | an empty `FakeRemoteConfigServer` | any `RemoteConfigTransport` |
| `networkMonitor` | `ConnectivityNetworkMonitor()` | any `NetworkMonitor` |
| `debugMode` | false | |

## License

MIT
