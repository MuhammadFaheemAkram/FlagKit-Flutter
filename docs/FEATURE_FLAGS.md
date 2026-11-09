# Feature Flags

A **feature flag** is a value an app reads at runtime to decide what to do: show the new home or the old one, use a one-page checkout or a stepper, offer a 15 % discount or none. The value comes from a server the team controls, so it can change **without a new release**.

```dart
if (FlagKit.isEnabled('new_checkout')) {
  return const OnePageCheckout();
}
return const ClassicCheckout();
```

---

## Why they matter

### Deploy is not release

Without flags, shipping code and turning a feature on are the same event: the feature goes live when the app store approves the build, for everyone, at once. With a flag, the code ships **dark** (switched off), and the team turns it on later, when it's ready, for whom it chooses. Unfinished work can merge into the main branch behind a flag instead of living on a long branch.

### Kill switches

Every risky feature gets a flag that can switch it off in seconds. A crash in the new checkout becomes "switch `new_checkout` off on the server", not "ship a fix and wait for store review while users can't pay". In FlagKit the kill switch (`enabled: false`) wins over every rule and rollout.

### Staged rollouts

Turn a feature on for 1 % of users, watch the crash rate and the metrics, then 10 %, 25 %, 50 %, everyone. If anything goes wrong, roll back to 0 %. FlagKit's rollouts are **stable** (a user keeps their answer on every launch) and **monotonic** (raising the percentage never takes it away from anyone who had it). See [ROLLOUTS.md](ROLLOUTS.md).

### Targeting

Show something to the users it's meant for: a market (`country in [PK, AE]`), an app version that supports it (`appVersion semverAtLeast 2.0.0`), the team's own accounts (`userId endsWith @company`). See [TARGETING.md](TARGETING.md).

### Experiments

Two variants, each for half of the users, and compare a metric: an A/B test. Flags provide the stable assignment; an analytics SDK (like [TrackLite](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter)) measures the outcome. Exposure events and multi-variant flags are on the [roadmap](ROADMAP.md).

### Remote configuration

Not every flag is on/off. `feed_page_size` (an int), `discount_percentage` (a double), `home_theme` (a string) and `home_config` (JSON) tune the app without a release. FlagKit's typed reads (`getInt`, `getDouble`, `getString`, `getJson`) never convert silently: the wrong type gets the caller's default.

---

## Common use cases

| Use case | Example in the sample | Flag type |
|---|---|---|
| A new screen, released gradually | `new_checkout` at 25 % | on/off + rollout |
| A kill switch | `new_home_screen` (switch it off in the console, Refresh) | on/off |
| A market-specific look | `home_theme` "modern" for PK and AE | string + targeting |
| A feature for supported versions only | `discount_percentage` for app 2.0.0+ | double + targeting |
| Tuning without a release | `feed_page_size` 12 | int |
| Server-driven content | `home_config` (a banner and sections) | JSON |

---

## What they cost

- **Flag debt.** Every flag is a branch in the code. A flag that reached 100 % months ago is dead code with a network dependency. Remove it: delete the flag from the server and the old path from the app, in the same release.
- **Combinations.** Five independent on/off flags make 32 possible apps. Test the paths that matter (each flag on and off, the combinations that interact), and keep flags short-lived so the combinations stay few.
- **Defaults are a contract.** The caller's default is what the app does when the flag can't be read: a first launch offline, a removed flag, a typo in a key. The default should be the safe, old behaviour, so that "no flag" never means "new, untested code". The sample keeps every default in one place (`AppFlagDefaults`).
- **Flags are not security.** A flag decides what a screen shows; anything that must be enforced (a paid feature, an admin action) must be enforced on the server. Definitions on a device can be read, and overrides can change them.
- **Consistency.** A value can change while the app runs (after a refresh, a context change). A screen that re-reads mid-flow can switch styles under the user; the sample's checkout starts the order again when its style changes. "Fetch, then activate at the next launch" is on the roadmap.

---

## How FlagKit answers "is this on?"

1. The server sends **definitions** (each flag's value, off value, kill switch, rollout and rules), not answers.
2. The SDK caches them on the device and loads them into memory at start.
3. Each read **evaluates** the definition for the current user: override → kill switch → targeting → rollout → value.
4. Every answer comes with a **source** and a **reason**, so "why do I see this?" always has an answer.

Next: [EVALUATION.md](EVALUATION.md).
