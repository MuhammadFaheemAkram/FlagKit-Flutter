# Phase 4 — Rollouts + Targeting

## Phase Goal

Make a flag's answer depend on **who is asking**, and keep it explainable:
- **an evaluation context** (user id, country, app version, custom attributes) set once, with every flag re-evaluated when it changes;
- **targeting rules** that compare the context's attributes by kind (text, numbers, versions), and fail closed when they can't;
- **percentage rollouts** that put each user in a stable bucket: the same on every device, independent per flag, never dropping anyone as a rollout grows;
- **the full evaluation order**, with a reason for every outcome and the user's bucket in `detail()`;
- **the sample on targeted flags:** the look follows the country, the checkout is rolled out to 25 %, the discount needs app 2.0.0, and Home and Checkout say why.

---

## What Was Implemented

- **SDK 0.4.0 (public):**
  - **`TargetingRule`** (an attribute, a `TargetingOperator`, values) and **`TargetingOperator`**: `equals`, `notEquals`, `in`, `notIn`, `startsWith`, `endsWith`, `contains`, `greaterThan`, `lessThan`, `semverAtLeast`, `semverBelow`, and `unknown` for an operator a newer server sends.
  - **`FlagDetail.bucket` and `rolloutPercent`:** for a rolled-out flag, where the user fell.
  - **`setContext` re-evaluates every flag** and reports the changed ones on `changes`.
  - **`FakeRemoteConfigServer`:** `setRollout(key, percent)` and `setRules(key, rules)` in the console.
  - **`FlagKitTesting.useAnonymousId(id)`** / `useRandomAnonymousIds()`: a new install with a known id, so an app's tests know which side of a rollout they're on.
- **SDK (internal):**
  - `fnv1a32` (32-bit FNV-1a over UTF-8); `bucketOf(key, unit)` = `fnv1a32("key:unit") % 10000`; `rolloutIncludes(basisPoints, bucket)` = `bucket < basisPoints`;
  - `SemVer` (`major.minor.patch`, missing parts 0, compared as numbers; anything else isn't a version);
  - `matchesRule` / `matchesAll` (pure, total, typed);
  - `rulesFromJson` (one bad rule makes the list unreadable);
  - `FlagDefinition` gains `rolloutBasisPoints` and `rules` (stored in the columns Phase 2 created for them);
  - **the parser validates them** instead of skipping every such flag: a rollout must be 0–100 in steps of 0.01, every rule needs an attribute, an operator and values;
  - an unknown operator is logged at refresh;
  - `evaluateFlag` takes the context and the rollout unit (the user id, else the anonymous id).
- **The sample:**
  - **the demo server's config (version 2):** `new_checkout` on, rolled out to 25 %; `home_theme` "modern" for `country in [PK, AE]`; `discount_percentage` 15.5 for `appVersion semverAtLeast 2.0.0`;
  - **"Why am I seeing this?"** (`features/common/why_line.dart`): a button that opens a sentence per flag, on Home (the home, the look) and Checkout (the checkout, the discount); `whyWords` builds them from a `FlagReading`, with the bucket for a rollout;
  - **`AppFlags.explain(AppFlag)`:** the screens ask why by meaning (an `AppFlag` enum); `AppFlagKeys.of` maps it to a key in the data layer;
  - **`FlagReading`** moved to `domain/flags/` (Dashboard and screens share it), with `bucket` and `rolloutPercent`; one mapper (`readingOf`) for both adapters;
  - **Profile** shows the install id (`UserContext.watchInstallId()`), and whether rollouts use it now; a `ProfileState`;
  - **the Dashboard** shows a rollout's bucket, and its SDK card describes the order.

---

## SDK Concepts Demonstrated

- **Targeting decides who is eligible; the rollout decides what share of the eligible get it.** A 25 % rollout to Pakistan is a quarter of the users in Pakistan. The other order would make the rollout's share depend on the targeting.
- **The kill switch beats everything.** A flag switched off serves its off value whoever is asking, before any rule or bucket is looked at.
- **Stable hashing, not `hashCode`.** `String.hashCode` changes between runs and platforms; FNV-1a over UTF-8 is a few lines, the same everywhere, and pinned by its published test vectors. Changing it would reshuffle every user of every rollout.
- **The key is in the hash.** Without it, the same users would be first in every rollout: two independent 10 % rollouts share about 1 % of users, not 10 %. A test counts them.
- **Monotonic rollouts.** `bucket < threshold`: raising 10 % to 25 % keeps everyone who had it. A test raises a rollout in 5 % steps over 10,000 users.
- **Basis points.** 10,000 buckets make 12.5 % exact; a rollout that isn't a whole number of basis points is refused, not rounded, so what's served is what the server said.
- **The unit decides stability.** The user id when signed in (the same answer on every device), else the install's anonymous id (the same answer at every launch). Signing in can change the answer: documented, and shown in the sample.
- **Fail closed.** A missing attribute never matches, `notIn` included: an unknown user isn't "not in Pakistan". A malformed version never matches. An unknown operator never matches, and is logged, so a newer server's rule keeps the flag off rather than on for everyone.
- **Typed comparisons.** Versions compare as numbers (`2.10.0` > `2.9.0`, which a string compare gets wrong); countries without regard to case; a number never equals the text `"30"`.
- **Explainability includes the bucket.** "You're outside its 25 % rollout (bucket 2679 of 10,000, not below 2500)" answers the first question anyone asks of a rollout.
- **A context change is a change.** `setContext` re-evaluates every flag against the same snapshot and emits the keys whose value changed, so screens rebuild as a user signs in or moves country.

---

## Flutter / Dart Concepts Demonstrated

- **Exhaustive switches over enums and patterns** for the operators, the reasons and the why sentences: a new operator or reason is a compile error wherever it must be handled (the public API test has a host's switch).
- **Record patterns for typed comparisons:** `switch ((actual, expected)) { (final String a, final String b) => …, (final num a, final num b) => … }`.
- **Bit arithmetic on a 64-bit `int`:** `(hash * prime) & 0xffffffff` keeps 32 bits; the product of a 32-bit value and a 25-bit prime fits.
- **A global for tests, behind a public switch:** `FlagKitTesting.useAnonymousId` replaces the id factory the client uses, the same way `useInMemoryDatabase` replaces the database opener.
- **`MergeSemantics` + `Semantics(expanded:)`:** the "Why" button announces whether it's open; a test checks the merged node (the first version put the flag on a separate node, which a screen reader wouldn't tie to the button).
- **A `Stepper` inside a `ListView`** (`NeverScrollableScrollPhysics`), so the why line scrolls with it.
- **Widget tests and broadcast streams:** an event from a fake reaches the Cubit in one frame and the rebuild in the next; `pumpAndSettle` instead of a single `pump`.

---

## Flag Evaluation Flow

```
read(key, type)                                   (synchronous, from the snapshot, for the current context)
  → not running                                   → your default          (notInitialized)
  → no definition                                 → your default          (flagNotFound)
  → another type (int → double widens)            → your default          (typeMismatch)
  → switched off                                  → off value             (off)              ← the kill switch
  → rules, and not all match the context          → off value             (targetingMiss)
  → a rollout:
        unit   = context.userId ?? anonymousId
        bucket = fnv1a32(utf8("key:unit")) % 10000
        bucket < rollout × 100                    → value                 (targetingMatch with rules, else rolloutIncluded)
        otherwise                                 → off value             (rolloutExcluded)
  → otherwise                                     → value                 (targetingMatch with rules, else fallthrough)
  → FlagDetail(value, source, reason, bucket?, rolloutPercent?)

A rule matches when:
  the context has the attribute, the rule has values, and
  equals / in                 → same kind and equal (country: without regard to case)
  notEquals / notIn           → same kind and not equal
  startsWith / endsWith / contains → both text
  greaterThan / lessThan      → both numbers
  semverAtLeast / semverBelow → both versions (major.minor.patch, compared as numbers)
  unknown                     → never

setContext(new)
  → for every key in the snapshot: value for the old context vs. the new
  → changes.add(keys whose value differs)
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `packages/flagkit/lib/src/evaluation/fnv1a.dart` | The hash |
| `packages/flagkit/lib/src/evaluation/rollout.dart` | Buckets and the threshold |
| `packages/flagkit/lib/src/evaluation/semver.dart` | Versions, compared as numbers |
| `packages/flagkit/lib/src/evaluation/targeting.dart` | A rule against a context |
| `packages/flagkit/lib/src/model/targeting_rule.dart` | `TargetingRule`, `TargetingOperator` (public) |
| `packages/flagkit/lib/src/model/targeting_rule_codec.dart` | Rules from JSON |
| `packages/flagkit/test/evaluation/{rollout,semver,targeting}_test.dart`, `test/model/targeting_rule_test.dart` | Golden vectors, distribution, monotonicity, every operator |
| `sample_app/lib/features/common/{why_line,flag_words}.dart` | "Why am I seeing this?" and its words |
| `sample_app/lib/domain/flags/flag_reading.dart`, `lib/data/flags/flag_reading_mapper.dart` | A reading, shared by the Dashboard and the screens |
| `sample_app/lib/features/profile/cubit/profile_state.dart` | The user and the install id |

---

## Important Types Added

| Type | Kind | Role |
|---|---|---|
| `TargetingRule`, `TargetingOperator` | class, enum (public) | A flag's targeting |
| `FlagDetail.bucket`, `.rolloutPercent` | fields (public) | Where the user fell in a rollout |
| `FlagKitTesting.useAnonymousId` | method (public, `testing.dart`) | A known bucket in tests |
| `SemVer` | internal | A version |
| `AppFlag`, `AppFlags.explain` | sample | Why, by meaning |
| `WhyLine`, `Why` | sample | The explanation on a screen |
| `ProfileState` | sample | The user and the install id |

---

## Folder Structure Changes

```
packages/flagkit/
├── lib/src/
│   ├── evaluation/{fnv1a,rollout,semver,targeting}.dart   # new
│   └── model/targeting_rule{,_codec}.dart                # new
└── test/
    ├── evaluation/{rollout,semver,targeting}_test.dart    # new
    └── model/targeting_rule_test.dart                     # new

sample_app/
├── lib/
│   ├── domain/flags/flag_reading.dart                     # moved from domain/debug
│   ├── data/flags/flag_reading_mapper.dart                # new
│   ├── features/common/{why_line,flag_words}.dart          # new
│   └── features/profile/cubit/profile_state.dart          # new
└── test/features/common/why_line_test.dart                # new
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| The bucket | a hash of the user id, unspecified | the same | FNV-1a 32 of `"key:unit"` over UTF-8, mod 10,000; golden vectors |
| The unit | the user id per read | the user id per read | the context's user id, else the install's anonymous id |
| Rules | `country == PK`, `appVersion >= 2.0`, `userId suffix` | the same | eleven typed operators; all rules must match; an unknown one fails closed |
| Versions | compared as strings | compared as strings | compared as numbers; malformed never matches |
| Rules and rollout together | order undefined | order undefined | kill switch → rules → rollout among the eligible |
| A context change | the next read | the next read | every flag re-evaluated; `changes` names the ones that changed |
| Why a value | a source | a source | a reason, and the bucket for a rollout; "Why am I seeing this?" on the screens |

---

## Interview Notes

- **"How do you bucket users for a percentage rollout?"** Hash `"flagKey:userId"` with a stable hash (FNV-1a, not `hashCode`), take it mod 10,000, include buckets below `percent × 100`. Stable across devices, independent per flag, monotonic as the percentage grows.
- **"Why put the flag key in the hash?"** Otherwise the same 10 % of users get every experiment first.
- **"A user signs in. Can their flags change?"** Yes, if they were bucketed by the install's id; afterwards they're bucketed by their user id, the same on every device. The alternative (always bucket by install) means a user sees different variants on their phone and tablet.
- **"A rule says `country notIn [PK]` and the country is unknown. Match?"** No. "Not in Pakistan" can't be said of someone whose country you don't know; serving them the flag would be a guess.
- **"How do you compare app versions?"** As numbers, part by part. As strings, `2.10.0` is before `2.9.0`.
- **"The server adds a `regex` operator. What does an old SDK do?"** Keeps the rule as `unknown`, which never matches, and logs it: the flag falls back to its off value for the targeted audience instead of reaching everyone.
- **"How do you test a rollout?"** Golden vectors for the hash; 10,000 generated ids for the distribution (25 % → 23.5–26.5 %); a monotonicity sweep; and in the app's tests, a known install id so the test knows which side it's on.

---

## Learning Checklist

- ✅ A stable hash with golden vectors; buckets in basis points
- ✅ Independent, monotonic rollouts; the unit and what signing in does
- ✅ Typed targeting operators; versions compared as numbers
- ✅ Failing closed: missing attributes, malformed versions, unknown operators
- ✅ The full evaluation order with a reason for every outcome
- ✅ Re-evaluation and `changes` on a context change
- ✅ Validated rules and rollouts in the definitions
- ✅ Explainability on the screens, with the bucket
- ✅ Deterministic rollouts in an app's widget tests
- □ The debug dashboard: overrides, "try a user", the server's console (Phase 5)

---

## Future Improvements

- **Phase 5:** overrides (drift v3, source `override`), `watchFlags`, `evaluateFor` ("try a user"), the server console in the Dashboard (rollout and rules), evaluations by source.
- **Segments and OR:** reusable rule groups and "any of these groups" (the roadmap).
- **Sticky assignment** for experiments, so a user keeps a variant even if the rollout shrinks.

---

## Notes on This Phase

- **Spec adjustments:**
  - **`TargetingOperator.unknown`:** the spec's enum has eleven operators; an unknown one from a newer server is kept as `unknown` (it never matches, and is logged at refresh) instead of skipping the whole flag, so the flag's kill switch and its other rules still apply.
  - **A rollout must be a whole number of basis points** (12.5 is fine, 12.345 is refused): the spec said "up to two decimals"; refusing beats rounding, because the server's number is then the one served.
  - **`FlagKitTesting.useAnonymousId`** (not in the spec): with a random install id, the sample's widget tests didn't know which side of the 25 % rollout they were on.
  - **`AppFlags.explain(AppFlag)`:** the screens ask "why" by meaning, so keys still live only in `AppFlagKeys`.
  - **`FlagReading` moved to `domain/flags/`** and gained the bucket; one mapper for the Dashboard and the screens.
- **Found on the device (the iPhone 17 Pro simulator):**
  - **The new config didn't arrive.** The app kept the old look with no country set: the device's cache held the Phase 3 config at version 1, the new asset also said version 1, and the conditional fetch answered "not modified". A config's version must change whenever its flags do; the asset is now version 2, and the next launch fetched it.
  - **The rest:**
    - no country: the classic look ("its rules don't match you"); PK: the modern look at once ("the targeting rules match you");
    - signed out, the install's bucket was 2679, outside the 25 % rollout: the step-by-step checkout, and the same bucket after a relaunch;
    - signed in as `maya` (bucket 404): the one-page checkout; app 1.9.0: no discount, with the reason;
    - Profile showed the install id, "not used while you're signed in"; the Dashboard showed "bucket 404, rollout 25 %";
    - light and dark both read well. The first wording, "404 of 0–9999", broke across lines at the dash; it's now "bucket 404 of 10,000, below 2500".
  - **The Dashboard's SDK card still said "Rules and rollouts come in 0.4.0"**: replaced.
- **Found in the tests:**
  - **The "Why" button didn't say it was open:** `Semantics(expanded:)` sat on its own node, apart from the button's. `MergeSemantics` makes them one, and a test checks it.
  - **The sample's flows depended on a random install id** until the harness named it (`test-install`, bucket 4486).
- **Mutation checks:** 54 rules broken on purpose, one at a time (two anchors first had to be fixed after formatting).
  - **47 were caught at first.**
  - **Five were missed, and now have tests:**
    - **the kill switch checked after the rules:** the test used a context the rules matched, so both orders served the off value. It now also uses a context they don't match, where the reason must still be `off`;
    - **a definition's equality ignoring its rules, or its rollout:** no refresh had changed only those. One now does, and must report both flags as changed;
    - **`FlagDetail ==` ignoring the bucket:** details that differ only by bucket or percentage are now compared;
    - **the why sentence at the threshold:** bucket 2500 of a 25 % rollout must read "not below 2500", as the SDK excludes it.
  - **54 of 54 caught.**
- **429 tests:** 264 SDK, 165 sample.
