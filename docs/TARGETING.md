# Targeting

Targeting shows a flag's value to the users it's meant for, and the off value to everyone else. It reads the **evaluation context**: who the app is for, right now.

---

## The context

```dart
FlagKit.setContext(const EvaluationContext(
  userId: 'maya',              // also the rollout unit when set
  country: 'PK',               // ISO 3166 code
  appVersion: '2.1.0',
  attributes: {'plan': 'pro', 'beta': true, 'age': 30},
));
```

- **Set once, not per read.** Reads don't take a user id; the context applies to every read until it changes. (The native editions pass a user id per read.)
- **A change re-evaluates every flag,** and `changes` names the ones whose value changed: signing in, moving country or upgrading the app updates the screens at once.
- **It stays on the device.** The server sends definitions; the device evaluates. Nothing in the context is stored or sent by the SDK.
- **To ask about someone else** without changing the context: `FlagKit.debug.evaluateFor(key, context)`.

## Rules

```json
"rules": [
  { "attribute": "country",    "operator": "in",            "values": ["PK", "AE"] },
  { "attribute": "appVersion", "operator": "semverAtLeast", "values": ["2.0.0"] }
]
```

**Every rule must match** (AND). No rules means everyone. If any rule misses, the read gets the off value with reason `targetingMiss`.

### Operators

| Operator (wire) | Matches when the attribute… | Kind |
|---|---|---|
| `equals` | equals the first value | text, number, boolean |
| `notEquals` | is known, of the same kind, and differs | text, number, boolean |
| `in` | equals one of the values | text, number, boolean |
| `notIn` | is known, of the same kind, and equals none | text, number, boolean |
| `startsWith` / `endsWith` / `contains` | (text) starts with / ends with / contains the value | text |
| `greaterThan` / `lessThan` | (a number) is more / less than the value | number |
| `semverAtLeast` / `semverBelow` | (a version) is at least / below the value's version | version |

The native specs' examples: `country == PK` is `in ["PK"]`; `appVersion >= 2.0` is `semverAtLeast "2.0.0"`; a user id ending in 5 is `endsWith "5"`.

---

## Failing closed

When a rule can't be evaluated, it **doesn't match**. The flag then serves its off value to that user, which is the safe direction: an unevaluable rule must never widen an audience.

- **A missing attribute never matches,** `notEquals` and `notIn` included. A user whose country is unknown isn't "not in Pakistan"; serving them a flag aimed at "everyone outside Pakistan" would be a guess.
- **Kinds must agree.** A number never equals the text `"30"`; `greaterThan` on text never matches; `notIn [18, "thirty"]` with a numeric age doesn't match (one value isn't comparable).
- **A malformed version never matches** (`"2.0.0-beta"`, `"v2"`, `"latest"`).
- **An unknown operator never matches.** A newer server may send an operator this SDK doesn't know; the rule is kept as `TargetingOperator.unknown` (its name preserved, logged at refresh), and the flag's kill switch and other rules still apply.
- **A rule that can't be read** (no attribute, no operator, no values, a value that isn't text, a finite number or a boolean) makes the whole flag invalid: it's skipped at refresh, never half-applied.

## Versions

Versions compare **as numbers, part by part**: `2.10.0` is after `2.9.0` (as text it would be before). Missing parts are zero (`2.0` is `2.0.0`). Anything else (a pre-release suffix, a `v` prefix, a letter) isn't a version here, and a version rule on it never matches. (`lib/src/evaluation/semver.dart`.)

## Countries

Country codes compare **without regard to case** (`pk` matches `PK`). Other text compares exactly.

---

## Personalization examples

| Goal | Rules |
|---|---|
| A market-specific look | `country in [PK, AE]` |
| Only on app versions that support it | `appVersion semverAtLeast 2.0.0` |
| The team's own accounts first | `userId endsWith @bitfuse.co` (with emails as ids) |
| A paid feature (the server still enforces it) | `plan equals pro` (a custom attribute) |
| A beta group, rolled out gradually | `beta equals true`, plus `rollout: 10` |

---

## In the sample

- Profile sets the context (sign in, a country, an app version); every tab follows at once.
- `home_theme` is "modern" for PK and AE: pick PK and the whole app's look changes.
- `discount_percentage` needs app 2.0.0+: pick 1.9.0 and the discount disappears from Checkout.
- "Why am I seeing this?" on Home and Checkout, and each flag's page on the Dashboard, show which rule matched and which didn't.
