import 'package:flagkit/src/model/flag_source.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:meta/meta.dart';

/// Every known definition at one moment: what reads see.
///
/// Immutable, and replaced whole: a refresh builds a new snapshot and
/// swaps one reference, so a read sees all of the old flags or all of the
/// new ones, never half of each, and never waits for the swap.
@internal
@immutable
final class FlagSnapshot {
  FlagSnapshot({
    required Map<String, FlagDefinition> flags,
    required this.source,
    this.fetchedAt,
    this.configVersion,
  }) : flags = Map.unmodifiable(flags);

  /// No definitions: a first launch, or a cleared cache.
  static final empty = FlagSnapshot(flags: const {}, source: FlagSource.cache);

  /// The definitions, by key.
  final Map<String, FlagDefinition> flags;

  /// [FlagSource.cache] when loaded from the device, [FlagSource.remote]
  /// once fetched in this session.
  final FlagSource source;

  /// When these definitions were fetched, if ever.
  final DateTime? fetchedAt;

  /// The server's version of them, if known.
  final int? configVersion;
}
