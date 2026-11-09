# Interview Notes

Questions a feature-flag SDK raises in a mobile interview, and how FlagKit answers them.

## The basics

**What is a feature flag, and why use one?**
A value read at runtime that decides what the app does, controlled from a server. It separates deploy from release: code ships dark, then turns on for chosen users, gradually, with a kill switch if it breaks. It also carries remote configuration (numbers, text, JSON).

**Why must a flag read be synchronous?**
It runs in `build`, on every frame. A `Future` would force a loading state for a value already in memory. FlagKit loads the cache into an immutable snapshot at start; reads evaluate it with no I/O.

**What happens when the flag isn't there?**
The caller's default, with a reason (`flagNotFound`, `typeMismatch`, `notInitialized`). A read never throws. The default should be the old, safe behaviour.

**How do you know why a user sees a value?**
`detail(key)`: the value, its source (`override`, `remote`, `cache`, `defaultValue`), its reason, and the bucket for a rollout. `debug.explain(key)` adds each rule's result.

## Evaluation

**In what order do you evaluate?**
Override → not found → type check → kill switch → targeting rules → rollout → the value. The kill switch beats rules and rollouts; overrides beat everything but are labelled.

**Rules and a percentage on the same flag: which first?**
Rules decide who's eligible; the rollout picks a share of the eligible. "25 % of users in Pakistan" is a quarter of the Pakistani users.

**Why does every flag have an off value?**
So targeting and rollouts work for strings and numbers: outside the rollout a user gets "classic", not the app's default.

## Rollouts

**How do you put a user in a rollout?**
`fnv1a32(utf8("flagKey:userId")) % 10000 < percent × 100`. Deterministic, the same on every platform, independent per flag, monotonic.

**Why not `hashCode`?**
It isn't stable across runs, isolates or platforms. A user would change buckets on every launch.

**Why the flag key in the hash?**
Otherwise the same users are first in every rollout.

**Raising 10 % to 25 %: does anyone lose the feature?**
No: `bucket < threshold`, so everyone under 1000 is still under 2500. Tested with a sweep.

**What's the unit for a signed-out user? What happens at sign-in?**
An anonymous id per install (stable across launches). At sign-in the unit becomes the user id (stable across devices), so the answer can change. The alternative gives one user different answers on two devices.

**How do you test code behind a 5 % rollout?**
A local override on the device; "try a user" until one lands inside; in automated tests, a known install id (`FlagKitTesting.useAnonymousId`).

## Targeting

**How do you compare app versions?**
As numbers, part by part: `2.10.0` > `2.9.0`, which a string compare gets wrong. A malformed version never matches.

**`country notIn [PK]` and the country is unknown: match?**
No. "Not in Pakistan" can't be said of someone whose country you don't know. A missing attribute never matches.

**The server adds an operator an old SDK doesn't know.**
The rule is kept as `unknown`, never matches, and is logged: the flag falls back to its off value for that audience rather than reaching everyone.

## Caching and refresh

**The cache expired and the device is offline. What do reads return?**
The cached values. Expiry changes how hard the SDK refreshes, never what a read returns: a cached kill switch must stay off.

**How do you poll without wasting requests?**
Conditional fetches (send the config version, get "not modified" with no body) and triggers that respect freshness (startup, staleness, resume, reconnect: never while fresh).

**What's wrong with `Timer.periodic(refreshInterval)`?**
It's measured from launch, not from the fetch. Started before the first fetch lands, it ticks while the data is still fresh and skips a period. Arm a one-shot timer for `fetchedAt + interval`.

**The server sends a bad flag.**
That flag is skipped and counted; the rest apply. A malformed payload changes nothing. One transaction for what's applied, then swap the snapshot: reads never see half a refresh.

**Two refreshes at once?**
Single-flight: the second joins the first, and `changes` reports once.

**A first launch: defaults, then a flash when the flags arrive?**
`startupWait`: with an empty cache, `initialize` waits up to N seconds for the first fetch. With any cache it never waits.

## Debug tools

**How do QA test a flag at 5 %?**
A local override: persisted, wins over everything, shown as `override` everywhere.

**Should clearing the cache clear overrides?**
No: the cache is the server's data, overrides are the developer's.

**Your change stream missed overrides. Why?**
It compared values before and after, but took "before" after the write. Take the values first.

## Testing

**How do you test a rollout?**
Golden vectors for the hash; 10,000 ids for the distribution; a monotonicity sweep; a known unit in app tests.

**How do you test timers and refreshes?**
A scripted transport, a fake network monitor and lifecycle, a clock you move, and `fake_async` over in-memory drift for a whole client.

**How do you know the tests test anything?**
Mutation checks: break each rule on purpose and see a test fail. Each phase's misses became new tests, simpler code, or a documented equivalent.
