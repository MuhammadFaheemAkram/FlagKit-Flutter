# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows [Conventional Commits](https://www.conventionalcommits.org/).

This is the project's changelog: the SDK, the sample app, the docs and CI, one release per build phase. The SDK package has its own, for its users: [`packages/flagkit/CHANGELOG.md`](packages/flagkit/CHANGELOG.md). Its versions match these.

## [Unreleased]

_All six build phases are complete. See [`docs/ROADMAP.md`](docs/ROADMAP.md) for what's next._

## [0.6.0] — 2026-11-10 — Phase 6: Documentation & CI

### Added
- **Docs:** ARCHITECTURE, SDK_DESIGN, FEATURE_FLAGS, EVALUATION, ROLLOUTS, TARGETING, CACHE_POLICY, TESTING, LEARNING_NOTES, INTERVIEW_NOTES, ROADMAP, SCREENSHOTS (every theme, light, dark, large text, offline, an override, a rollout); the Phase 6 summary.
- **Open-source files:** CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, this CHANGELOG, and the GitHub issue and PR templates.
- A final mutation pass of the key rules across the six phases.

### Changed
- The README and the SDK's README are final. The SDK is 0.6.0 (documentation only: no API or behaviour change).

## [0.5.0] — 2026-11-10 — Phase 5: Dashboard + SDK Features

### Added
- **Local overrides** (drift schema v3, with a migration test): persisted, first in the evaluation order, typed, kept by `clearCache`, shown as source `override`.
- **The debug tools:** `watchFlags`, `definitions` (`FeatureFlag`), `evaluateFor` another user, `explain` (`FlagExplanation`, `RuleMatch`), and stats with online, refreshing, reads by source and counters that outlive the log.
- **The sample's full Dashboard:** the cache and its actions, every flag and its page (the definition, the bucket, each rule, an override), Try a user, the demo server's console, the refresh log, the counts.

### Fixed
- `changes` missed overrides: it compared values taken after the write. They're now taken before.

## [0.4.0] — 2026-11-09 — Phase 4: Rollouts + Targeting

### Added
- **Rollouts:** FNV-1a (32-bit) buckets of `"key:unit"` mod 10,000, pinned by golden vectors; monotonic; the unit is the user id, else the install's anonymous id.
- **Targeting:** public `TargetingRule` / `TargetingOperator` with eleven typed operators (versions compared as numbers); a missing attribute or an unknown operator never matches.
- **The full evaluation order** with every reason; the bucket in `FlagDetail`; `setContext` re-evaluates every flag.
- **The sample:** the demo's targeted flags (a 25 % checkout, the look for PK and AE, the discount for app 2.0.0+), "Why am I seeing this?" on Home and Checkout, the install id on Profile.

### Fixed
- The demo config's version didn't change with its flags, so a device holding the old config got "not modified" forever. It's now version 2.

## [0.3.0] — 2026-11-06 — Phase 3: Remote Config Pipeline

### Added
- **`RemoteConfigTransport`** and a fake server with a console; conditional fetches by config version; validation in two levels; single-flight, atomic refreshes; the refresh log (schema v2, with a migration test).
- **Refresh triggers** that respect freshness: startup (with `startupWait`), staleness, resume, reconnect; a `NetworkMonitor`; a rejected key pausing automatic refreshes.
- **The sample** on the server's flags, with Refresh, the last refresh and a Device offline switch.

### Fixed
- The interval refresh skipped every first period: a periodic timer from launch ticked while the cache was still fresh. It's now armed for "fetched at + interval".

## [0.2.0] — 2026-11-04 — Phase 2: Storage + Cache Layer

### Added
- **The cache:** drift (schema v1, exported), definitions with a value and an off value, an immutable in-memory snapshot read synchronously, the anonymous id, `clearCache`.
- **The cache policy:** fresh, stale, expired (still served) and empty, with half-open boundaries.
- **Debug stats** and the sample's cache card.

## [0.1.0] — 2026-11-04 — Phase 1: SDK Foundation

### Added
- **The workspace:** the SDK package and the sample app in one pub workspace; strict analysis; CI with `pub publish --dry-run` and `dart doc --dry-run`.
- **The public API's shape:** `FlagKit`, `FlagKitClient`, `FlagKitConfig` (checked at `initialize`), sealed `FlagValue`, `FlagDetail`, `EvaluationContext`, `RefreshResult`; reads that never throw.
- **The sample:** four tabs on defaults, three themes, the `AppFlags` port with every key in one place, the accessibility tour.
