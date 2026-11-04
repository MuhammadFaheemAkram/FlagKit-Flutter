import 'package:flagkit/src/model/cache_status.dart';
import 'package:meta/meta.dart';

/// How fresh flags fetched at [fetchedAt] are at [now].
///
/// Half-open intervals, so every instant has exactly one status, and
/// exactly at a boundary is the later one:
///
/// | Status  | Age (`now − fetchedAt`)                          |
/// |---------|--------------------------------------------------|
/// | empty   | never fetched (`fetchedAt` is `null`)            |
/// | fresh   | `< refreshInterval` (and any future `fetchedAt`) |
/// | stale   | `refreshInterval ≤ age < cacheExpiration`        |
/// | expired | `≥ cacheExpiration`                              |
///
/// A `fetchedAt` in the future (the clock moved back since) counts as
/// fresh: the flags are at least as new as the clock says now, and calling
/// them expired would refresh on every chance for no reason. A pure
/// function, so every boundary is tested.
@internal
CacheStatus cacheStatusOf({
  required DateTime? fetchedAt,
  required DateTime now,
  required Duration refreshInterval,
  required Duration cacheExpiration,
}) {
  if (fetchedAt == null) return CacheStatus.empty;
  final age = now.difference(fetchedAt);
  if (age < refreshInterval) return CacheStatus.fresh;
  if (age < cacheExpiration) return CacheStatus.stale;
  return CacheStatus.expired;
}
