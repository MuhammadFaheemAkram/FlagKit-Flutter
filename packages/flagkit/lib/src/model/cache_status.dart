/// How old the cached flags are, which decides how hard FlagKit tries to
/// refresh them. It never decides what a read returns: offline, the last
/// known flags are better than defaults.
enum CacheStatus {
  /// Fetched less than `refreshInterval` ago: no refresh needed.
  fresh,

  /// Older than `refreshInterval`: refreshed at the next chance.
  stale,

  /// Older than `cacheExpiration`: still served, refreshed at every chance.
  expired,

  /// Nothing cached (a first launch, or a cleared cache): reads return the
  /// callers' defaults.
  empty,
}
