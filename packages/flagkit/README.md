# flagkit

A small feature flag SDK for Flutter apps, built to show how one is designed:
- typed flag reads that are synchronous and never fail;
- an offline-first cache, and remote refresh;
- deterministic percentage rollouts and user targeting;
- an answer to "why does this flag have this value?" for every read.

It talks to a fake remote config server: this is a learning project, not a hosted service.

> **Status: 0.2.0: cached flags, read from memory.** Definitions are cached on the device and every read evaluates against them; the server arrives in 0.3.0, so until then nothing fills the cache.
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

## Debug tools

```dart
FlagKit.debug.watchStats().listen((stats) {
  // stats.cacheStatus, .flagCount, .fetchedAt, .configVersion, .anonymousId
});
```

## Testing your app

```dart
import 'package:flagkit/testing.dart';

setUp(() async {
  FlagKitTesting.useInMemoryDatabase(); // widget tests have no file system
  await FlagKit.initialize(const FlagKitConfig(apiKey: 'test'));
});
tearDown(FlagKit.shutdown);
```

Or depend on `FlagKitClient` (register `FlagKit.instance`) and pass a fake.

## Configuration

| Option | Default | Range |
|---|---|---|
| `apiKey` | required | not blank |
| `refreshInterval` | 1 h | ≥ 1 min: how long fetched flags stay fresh |
| `cacheExpiration` | 24 h | ≥ `refreshInterval`: when they count as expired (still served) |
| `startupWait` | 0 | 0–10 s: with nothing cached, how long `initialize` waits for a first fetch |
| `debugMode` | false | |

## License

MIT
