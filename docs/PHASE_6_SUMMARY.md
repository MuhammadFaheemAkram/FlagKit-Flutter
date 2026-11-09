# Phase 6 — Documentation + CI

## Phase Goal

Finish FlagKit as a learning resource and an SDK a team could adopt:
- **the design docs:** the architecture, the SDK's design, what feature flags are for, evaluation, rollouts, targeting, the cache policy, testing, learning and interview notes, a roadmap, and screenshots;
- **the open-source files:** CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, the project's CHANGELOG, and the GitHub issue and PR templates;
- **the final READMEs:** the repository's and the SDK package's (what a host developer reads first);
- **CI confirmed current,** and simulated from a clean copy of the tree;
- **close-out:** a mutation pass of the key rules across all six phases against the finished suites, a release-build launch, screenshots, cleanup.

---

## What Was Implemented

- **Docs** (`docs/`):
  - `ARCHITECTURE.md`: the layers, the three decisions everything follows, the data flow of a read, a refresh and a change, the sample's ports;
  - `SDK_DESIGN.md`: the one rule, the facade and the client, typed values, the error table, extension points, the debug tools, dependencies, versioning, a host's setup;
  - `FEATURE_FLAGS.md`: what flags are for (deploy vs release, kill switches, staged rollouts, targeting, experiments, remote config) and what they cost (flag debt, combinations, defaults, security, consistency);
  - `EVALUATION.md`: the order, why it's in that order, every source and reason, worked examples on the demo's flags, `changes`;
  - `ROLLOUTS.md`: the bucket, FNV-1a and its vectors, the key in the hash, basis points, the unit and signing in, safe deployments;
  - `TARGETING.md`: the context, rules and operators, failing closed, versions, countries, personalization;
  - `CACHE_POLICY.md`: the four statuses, why expired values are served, offline, the triggers, the first launch, `clearCache`, the database;
  - `TESTING.md` (tests per area, every phase's mutation checks), `LEARNING_NOTES.md`, `INTERVIEW_NOTES.md`, `ROADMAP.md`, `SCREENSHOTS.md` (the three looks, a rollout, targeting, an override, the Dashboard, dark mode, offline, large text).
- **Repository files:** `CONTRIBUTING.md` (the SDK's and the sample's rules, setup, schema changes, the demo config's version, releasing), `CODE_OF_CONDUCT.md`, `SECURITY.md` (what the SDK holds and where; flags aren't access control), `CHANGELOG.md` (0.1.0–0.6.0, one release per phase), `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/{bug_report,feature_request}.md`.
- **The READMEs:** the repository's gains installation, rollouts and targeting with the evaluation diagram, offline behaviour, screenshots, and links to every doc; the SDK's gains installation (git or path) and the flag types.
- **SDK 0.6.0:** documentation only, no API or behaviour change.
- **The sample:** at large text, a stat's value goes **under** its label (see *Notes*), with two tests.
- **Cleanup:** an empty, ignored `doc/api/` left at the root by an early `dart doc` run is gone.
- **525 tests** (304 SDK, 221 sample).

---

## SDK Concepts Demonstrated

- **Documentation is part of an SDK's API**, and it's checked like code: every public member documented (`public_member_api_docs`), `dart doc --dry-run` with broken references as errors, `pub publish --dry-run` (the README, CHANGELOG and LICENSE that ship), and `version_test.dart` (code, pubspec and changelog agree).
- **Write the contract down:** the evaluation order with a reason per row, the frozen hash with its vectors, the cache statuses with their boundaries, the transport's errors. A contributor changing one knows which doc and which test go with it.
- **Determinism, seen across platforms:** a release build on Android (AOT, ARM) bucketed its install at 2378; the Dart VM on a Mac computes 2378 for the same id.
- **Versioning by what a host would notice:** 0.6.0 changes no API and no behaviour, and the changelog says so.
- **A security policy for an SDK:** what's stored, where, for how long; the context never stored or sent; the key masked; flags aren't access control.

---

## Flutter / Dart Concepts Demonstrated

- **Adaptive layout at large text:** the app's `context.prefersStackedLayout` rule (above 130 %) now also moves a `StatRow`'s value from `trailing` to `subtitle`; tests compare widget rects (`tester.getRect`) to prove *where* it is.
- **Release builds:** `flutter build apk --release` and a launch with cleared data (`pm clear`), since tree shaking only shows there (the icon font shrank by 99.6 % and every icon still rendered).
- **Screenshots from the simulator:** `simctl status_bar … override --time 9:41` for stable images, `simctl ui … content_size accessibility-extra-large` for AX3, both restored after.

---

## Flag Evaluation Flow

The finished pipeline, end to end:

```
the server (FakeRemoteConfigServer, or a host's transport)
  ── definitions: value, off value, enabled, rollout, rules ──▶
RefreshManager (single-flight · conditional · validated · atomic · logged)
  ──▶ drift (flags · meta · refreshes · overrides) ──▶ FlagSnapshot (immutable, in memory)

read(key, type) for the current EvaluationContext
  → override → not found / type → kill switch → rules (all) → rollout (FNV-1a "key:unit" % 10000) → value
  → FlagDetail(value, source, reason, bucket?)            synchronous · never throws · always a value

setContext / setOverride / a refresh / clearCache
  → values before → the change → values after → changes (the keys that differ) + a tick for the debug tools
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `docs/ARCHITECTURE.md`, `SDK_DESIGN.md` | The design |
| `docs/FEATURE_FLAGS.md`, `EVALUATION.md`, `ROLLOUTS.md`, `TARGETING.md`, `CACHE_POLICY.md` | The concepts |
| `docs/TESTING.md`, `LEARNING_NOTES.md`, `INTERVIEW_NOTES.md`, `ROADMAP.md` | How it's tested, what it taught, what's next |
| `docs/SCREENSHOTS.md`, `docs/screenshots/` | 16 screenshots |
| `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md` | The open-source set |
| `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/` | GitHub templates |
| `sample_app/test/core/design_system/widgets/stat_row_test.dart` | A stat at normal and large text |

---

## Important Types Added

None: Phase 6 changes no API. `StatRow` (sample) gains its large-text layout.

---

## Folder Structure Changes

```
FlagKit/
├── CONTRIBUTING.md  CODE_OF_CONDUCT.md  SECURITY.md  CHANGELOG.md   # new
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md                                   # new
│   └── ISSUE_TEMPLATE/{bug_report,feature_request}.md             # new
├── docs/
│   ├── ARCHITECTURE.md SDK_DESIGN.md FEATURE_FLAGS.md EVALUATION.md ROLLOUTS.md TARGETING.md
│   ├── CACHE_POLICY.md TESTING.md LEARNING_NOTES.md INTERVIEW_NOTES.md ROADMAP.md SCREENSHOTS.md
│   ├── PHASE_6_SUMMARY.md                                         # new
│   └── screenshots/                                               # new
└── doc/                                                           # removed (an empty, ignored dart doc output)
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Docs | README + docs | README + docs | + `dart doc` in CI with broken references as errors; the publish dry run checks what ships |
| Release check | a release build | an archive | `flutter build apk --release` + a launch with cleared data |
| Determinism across platforms | — | — | the same bucket (2378) from an Android release build and the Dart VM on macOS |
| Screenshots | — | — | the simulator with a fixed status bar; AX3 for large text |

---

## Interview Notes

- **"How do you keep an SDK's documentation from rotting?"** Check it like code: a lint for every public member's docs, `dart doc` in CI with broken references as errors, the publish dry run for the README and changelog that ship, a test that the version agrees across code, pubspec and changelog.
- **"What does a version bump mean if nothing changed in the code?"** 0.6.0 ships finished docs; the changelog says "no API or behaviour change", so a host knows upgrading is safe.
- **"How would you prove your rollout hash is the same on every platform?"** Golden vectors in tests, and in practice: an Android release build's bucket for an install id equals the one the Dart VM computes on a Mac.
- **"What did the screenshots find?"** A stat's label broke mid-word at large text beside a long value. The accessibility tour passed (nothing overflowed), but it read badly; a layout rule and two placement tests fixed it.

---

## Learning Checklist

- ✅ The design and concept docs, written for someone learning feature flags
- ✅ The open-source set and GitHub templates
- ✅ Final READMEs: installation, examples, offline behaviour, diagrams, screenshots
- ✅ CI confirmed current and simulated from a clean copy
- ✅ A final mutation pass of the key rules from all six phases
- ✅ A release build launched; screenshots in every theme, light, dark and large text
- ✅ **All six phases complete**

---

## Future Improvements

See [ROADMAP.md](ROADMAP.md): a real HTTP transport, streaming updates, background refresh, fetch / activate, multi-variant flags and experiments, exposure events, segments, code generation of typed flags, publishing, the web.

---

## Notes on This Phase

- **A layout fix the screenshots found:** at AX3 text, the Dashboard's "Fetched" broke mid-word (`Fetche` / `d`) beside a time. The accessibility tour passed (nothing overflowed at 200 %), but it read badly. Past 130 % a stat's value now goes under its label, and two tests check where it is.
- **Accepted at AX3:** a long flag key (`discount_percentage`) wraps inside the word, because one identifier is wider than the line at 235 %. Breaking at the underscore would need a zero-width space in every key, which changes the text tests and screen readers see; on a developer's screen, the wrap is acceptable.
- **The release build** (after the last code change) was installed with its data cleared and launched on the Pixel 10 Pro emulator (API 36):
  - the first screen showed the server's flags at once (`startupWait`): the new home, its banner and sections;
  - the icons survived tree shaking (the icon font went from 1.6 MB to 7 KB);
  - the Dashboard: fresh, 6 flags, config version 2, "At start · Updated";
  - the new install's id put it in bucket **2378** for `new_checkout` (inside 25 %: the one-page checkout, explained on Checkout). The Dart VM on the Mac computes 2378 for the same id.
- **Screenshots** on the iPhone 17 Pro simulator: the three looks (classic for no country, modern for PK, ocean through an override), a rollout, a flag's rules, an override, the Dashboard, dark mode (the console, Device offline, Try a user), and AX3. The status bar override, the text size and the appearance were restored afterwards.
- **Mutation checks:** 26 key rules, one from each corner of the SDK and the sample, each run against its package's whole suite. **All 26 caught.** Over six phases: **248 mutations, 246 caught, 2 equivalent.**
- **CI** was confirmed current (generated code, format, analyze, both suites, `pub publish --dry-run`, `dart doc --dry-run`) and simulated from a clean copy of the staged tree.
- **525 tests:** 304 SDK, 221 sample.
