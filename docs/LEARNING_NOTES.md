# Learning Notes

What building FlagKit taught, phase by phase: the lessons worth carrying to the next SDK.

## SDK design

- **Make the hot path boring.** A flag read runs on every frame of every screen. Synchronous, from an immutable snapshot, no I/O, no exceptions: everything clever happens elsewhere (at a refresh, at a context change).
- **The caller owns the default.** `getInt('feed_page_size', 20)`: the app decides its fallback, which is the behaviour it shipped before the flag existed. Defaults in one place (`AppFlagDefaults`) make "no flag" a reviewed decision.
- **Explainability is a feature, not a log line.** A source and a reason on every read, the bucket on a rollout, each rule's result in `explain`: "why do I see this?" is the first question anyone asks of a flag system.
- **A facade and an interface.** A static `FlagKit` for the one-liner; a `FlagKitClient` interface for apps with DI and fakes. The facade outlives clients (a context and a `changes` stream across restarts).
- **Developer errors fail fast, runtime errors never escape.** A bad config or override throws at once, in development; a bad network, cache or payload degrades quietly to the cache or the default.

## Evaluation

- **Write the order down, test each row and each row's place.** Override → kill switch → targeting → rollout → value. The kill switch over matching rules, an override over the kill switch: a test per pair that matters.
- **Targeting decides eligibility; the rollout picks a share of the eligible.** The other order makes the rollout's share depend on the targeting.
- **Every flag needs an off value.** Without one, only on/off flags can be rolled out; with one, "modern" for 25 % and "classic" for the rest works for any type.
- **Fail closed.** A missing attribute, a malformed version, an unknown operator: no match. An unevaluable rule must never widen an audience.

## Rollouts

- **Never `hashCode` for anything persisted or shared.** FNV-1a over UTF-8, pinned by golden vectors: the same bucket on every device and in every language.
- **Put the key in the hash,** or the same users are first in every experiment. A test counts the overlap.
- **Monotonic by construction:** `bucket < threshold`. Raising a rollout only adds users.
- **Test with a known unit.** A random install id made the sample's flows depend on luck; `FlagKitTesting.useAnonymousId` fixed it, and is public because every host has the same problem.

## The cache and refreshes

- **Status decides effort, never answers.** Expired flags are still served: a cached kill switch must stay off for a user offline for two days.
- **Half-open boundaries,** tested at every edge, including a clock moved back.
- **Arm timers from the data, not from launch.** A `Timer.periodic(interval)` started at launch ticks just before the cache it fetched turns stale, and skips a period. Arm for `fetchedAt + interval`.
- **Conditional fetches need honest versions.** The demo config changed its flags but not its version, and a device holding the old config got "not modified" forever. A version is a promise that nothing changed.
- **Two levels of validation:** a payload you can't trust changes nothing; a flag you can't read is skipped while the rest apply.
- **Write first, then swap,** in one transaction where things belong together. Memory never claims what the disk doesn't have.

## Change reporting

- **Report evaluated values, measured before the change.** `changes` compared values taken after an override's write and found nothing to report.
- **A debug screen needs more than value changes.** The same value with a new bucket or reason must refresh the Dashboard: a separate tick.
- **Deduplicate derived streams.** Once ticks fed the stats, identical stats were re-sent; compare before emitting.

## Testing

- **A whole client in fake time.** `fake_async` with in-memory drift covers latency, timers and refreshes end to end in milliseconds.
- **Widget tests and databases:** a bootstrap that writes to drift must run in `tester.runAsync`, or it never completes in fake time.
- **Mutation checks every phase.** 222 mutations over the first five phases found missing tests (a kill switch tested only with matching rules), redundant code (a re-inspection the stream already did), and equivalent changes worth writing down.
- **Test the tests' surfaces:** a widget-test surface over about 5,000 points tall fails to rasterize page transitions; at 200 % text a lazy list builds only what's on screen.

## Flutter and Dart

- **Sealed classes as protocols** (`FlagValue`, `FetchResponse`, `TransportException`, `RefreshResult`): exhaustive switches in the SDK and in a host's code.
- **Records and patterns for typed comparisons:** `switch ((actual, expected)) { (final String a, final String b) => … }`.
- **Don't name a field `override`:** it hides the `@override` annotation in that class.
- **`MergeSemantics` + `Semantics(expanded:)`:** otherwise the expanded state is a separate node a screen reader doesn't tie to the button.
- **Bloc lets a Cubit's first emit through** even when it equals the initial state.
- **Static methods can't take a cascade** (`FlagKitTesting..useInMemoryDatabase()` doesn't compile).
