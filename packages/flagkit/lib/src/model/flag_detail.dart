import 'package:flagkit/src/model/evaluation_reason.dart';
import 'package:flagkit/src/model/flag_source.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:meta/meta.dart';

/// A read, explained: the value, where it came from and why.
///
/// `FlagKit.detail(key)` returns one for any flag; the typed reads
/// (`isEnabled`, `getString`, …) compute the same and return only the value.
@immutable
final class FlagDetail {
  /// A read's outcome.
  const FlagDetail({
    required this.key,
    required this.value,
    required this.source,
    required this.reason,
  });

  /// A read FlagKit couldn't answer: the caller's default, for [reason].
  const FlagDetail.fallback(this.key, this.reason)
    : value = null,
      source = FlagSource.defaultValue;

  /// The flag's key.
  final String key;

  /// The evaluated value, or `null` when the caller's default applies
  /// ([source] is [FlagSource.defaultValue]).
  final FlagValue? value;

  /// Where [value] came from.
  final FlagSource source;

  /// Why the flag has this value.
  final EvaluationReason reason;

  /// Whether the caller's default applies.
  bool get isDefault => source == FlagSource.defaultValue;

  @override
  bool operator ==(Object other) =>
      other is FlagDetail &&
      other.key == key &&
      other.value == value &&
      other.source == source &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(key, value, source, reason);

  @override
  String toString() =>
      'FlagDetail($key: ${value ?? 'the default'}, '
      '${source.name}, ${reason.name})';
}
