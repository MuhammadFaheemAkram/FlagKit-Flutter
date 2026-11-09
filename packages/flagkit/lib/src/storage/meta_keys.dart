import 'package:meta/meta.dart';

/// The names in the `meta` table.
@internal
abstract final class MetaKeys {
  /// This install's anonymous id (a UUID), created on the first start: the
  /// rollout unit when no user is signed in.
  static const anonymousId = 'anonymous_id';

  /// When the flags were last fetched successfully (UTC ISO-8601): what the
  /// cache policy measures.
  static const fetchedAt = 'fetched_at';

  /// The server's version of the cached definitions: sent with the next
  /// fetch, so an unchanged config needs no download.
  static const configVersion = 'config_version';

  /// How many refreshes were logged, ever (the log keeps only the newest).
  static const refreshTotal = 'refresh_total';

  /// How many of them failed (an error, or a rejected key).
  static const refreshFailedTotal = 'refresh_failed_total';

  /// How many invalid definitions refreshes left out, in all.
  static const skippedTotal = 'skipped_total';
}
