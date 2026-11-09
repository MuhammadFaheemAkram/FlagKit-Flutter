# Rollouts

A **percentage rollout** gives a flag's value to a share of its users, and the off value to the rest:

```json
{ "key": "new_checkout", "type": "boolean", "value": true, "offValue": false, "rollout": 25 }
```

---

## The bucket

```
unit   = context.userId ?? anonymousId            (the signed-in user, else this install)
bucket = fnv1a32(utf8("$flagKey:$unit")) % 10000  (0–9999)
in     = bucket < rollout × 100                   (basis points: 25 % → 2500, 12.5 % → 1250)
```

(`lib/src/evaluation/fnv1a.dart`, `rollout.dart`.)

### Why FNV-1a, not `hashCode`

`String.hashCode` isn't stable across runs, isolates or platforms: a user would change buckets on every launch. A rollout needs the **same bucket on every device, after every update, in every language** (so a server, or the Android and iOS SDKs, could compute the same one). FNV-1a (32-bit) is a few lines, spreads short keys well, and is pinned by its published test vectors:

| Input | FNV-1a 32 |
|---|---|
| `""` | `0x811c9dc5` |
| `"a"` | `0xe40c292c` |
| `"foobar"` | `0xbf9cf968` |

It hashes the **UTF-8 bytes**, not Dart's UTF-16 code units (a test checks `é`). Changing the hash would reshuffle every user of every rollout: that would be a breaking change.

### Why the key is in the hash

Without it, the same users would be first in every rollout: whoever falls in the first 10 % of one experiment would be in the first 10 % of all of them (the "always the guinea pig" problem). With `"key:unit"`, two independent 10 % rollouts share about 1 % of users, as chance would have it. A test counts them over 10,000 ids.

### Why basis points

10,000 buckets make 12.5 % or 0.25 % exact. The parser refuses a rollout that isn't a whole number of basis points (12.345 %) instead of rounding it, so what's served is what the server said.

---

## Properties (each tested)

- **Deterministic:** the same key and unit give the same bucket, always.
- **Distributed:** of 10,000 generated ids, a 25 % rollout includes between 23.5 % and 26.5 % (tested at 0, 10, 25, 50 and 100 %).
- **Monotonic:** `bucket < threshold`, so raising 10 % to 25 % keeps everyone who had it; a sweep in 5 % steps checks that no one is ever dropped.
- **Edges:** 0 % includes no one, 100 % everyone; a bucket exactly at the threshold is out.

---

## The unit: who keeps the answer

| Situation | Unit | Stable across |
|---|---|---|
| Signed out | the install's anonymous id (a UUID created on the first start, kept by `clearCache`) | launches on this install |
| Signed in | the user id | every device the user signs in on |

**Signing in can change the answer.** A guest in bucket 2679 (out of a 25 % rollout) who signs in as `maya` (bucket 404) gets the new checkout. Every SDK that buckets by user has this property; the alternative (always bucket by install) gives one user different answers on their phone and their tablet. The sample shows it: Profile → Sign in → Checkout changes, and "Why am I seeing this?" names the bucket.

---

## Rollouts and targeting together

Targeting decides who is eligible; the rollout picks a share **of the eligible**:

```json
{ "key": "new_checkout", "rollout": 25,
  "rules": [{ "attribute": "country", "operator": "in", "values": ["PK"] }] }
```

A user outside Pakistan gets `targetingMiss` and is never bucketed; a user in Pakistan is bucketed, and gets `targetingMatch` inside the 25 % or `rolloutExcluded` outside it.

---

## Safe deployments

1. **Ship dark:** the flag at 0 % (or switched off). The code is in the build, nobody sees it.
2. **Test it yourself:** a local override on your device (the Dashboard's flag page), or "Try a user" to find an id inside a small rollout.
3. **Ramp:** 1 % → 5 % → 25 % → 50 % → 100 %. Monotonic buckets mean each step only adds users: nobody flips back and forth.
4. **Watch** the crash rate and the metrics at each step, for the people who have it versus those who don't.
5. **Kill switch:** if anything goes wrong, switch the flag off. It wins over the rollout for everyone at the next refresh (on resume, on reconnect, or at the interval).
6. **Clean up:** at 100 % for long enough, delete the flag and the old code path.

## Testing your app with rollouts

A random install id puts your test user in a random bucket. Name it:

```dart
FlagKitTesting.useAnonymousId('test-install'); // bucket 4486 for new_checkout: outside 25 %
```

The sample's harness does this, so its flows know which checkout to expect, and signs in as `maya` (bucket 404) to test the other side.
