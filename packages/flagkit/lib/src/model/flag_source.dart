/// Where a read's value came from.
enum FlagSource {
  /// A local debug override (the dashboard's): it wins over everything.
  override,

  /// The server's definition, fetched in this session.
  remote,

  /// The server's definition from an earlier session, loaded from the
  /// device's cache and not refreshed yet.
  cache,

  /// The default the caller passed: FlagKit had no value to give.
  defaultValue,
}
