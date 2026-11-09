import 'package:flagkit/src/model/flag_key.dart';
import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value_codec.dart';
import 'package:flagkit/src/model/targeting_rule_codec.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:meta/meta.dart';

/// A server's config, validated: the definitions this SDK can serve, and
/// what it left out.
@internal
final class ParsedConfig {
  const ParsedConfig({
    required this.version,
    required this.flags,
    required this.skipped,
  });

  final int version;
  final List<FlagDefinition> flags;

  /// Why each left-out definition was left out (`"key: reason"`).
  final List<String> skipped;
}

/// Validates the config [json] fetched at [fetchedAt].
///
/// Two levels, on purpose:
/// - **the payload** (`version` an integer, `flags` a list) must be right,
///   or nothing is applied: a [FormatException], and the cache stays as it
///   was. A broken body says nothing trustworthy about any flag.
/// - **each flag** stands alone: one this SDK can't read (an unknown type,
///   a value of another type, a bad key) is skipped and reported, and the
///   rest apply. A newer server can add a type without breaking the flags
///   an older SDK does understand.
///
/// A rollout is 0–100 % in steps of 0.01 (stored in basis points). Rules
/// must be readable as a whole (see `rulesFromJson`); a rule with an
/// operator this SDK doesn't know is kept, and never matches.
@internal
ParsedConfig parseConfig(
  Map<String, Object?> json, {
  required DateTime fetchedAt,
}) {
  final version = json['version'];
  final entries = json['flags'];
  if (version is! int) {
    throw const FormatException('the config has no integer "version"');
  }
  if (entries is! List<Object?>) {
    throw const FormatException('the config has no "flags" list');
  }

  final flags = <FlagDefinition>[];
  final skipped = <String>[];
  final seen = <String>{};
  for (final (index, entry) in entries.indexed) {
    final key = entry is Map<String, Object?> ? entry['key'] : null;
    final name = key is String ? key : '#$index';
    final problem = switch (entry) {
      final Map<String, Object?> flag => _problemWith(flag, seen),
      _ => 'not an object',
    };
    if (problem != null) {
      skipped.add('$name: $problem');
      continue;
    }
    final flag = entry! as Map<String, Object?>;
    final type = FlagType.fromWireName(flag['type']! as String)!;
    flags.add(
      FlagDefinition(
        key: name,
        value: flagValueFromJson(type, flag['value'])!,
        offValue: flagValueFromJson(type, flag['offValue'])!,
        enabled: flag['enabled'] as bool? ?? true,
        updatedAt: fetchedAt.toUtc(),
        rolloutBasisPoints: _basisPoints(flag['rollout']),
        rules: rulesFromJson(flag['rules'])!,
      ),
    );
    seen.add(name);
  }
  return ParsedConfig(version: version, flags: flags, skipped: skipped);
}

/// What's wrong with [flag], or `null` if it can be served.
String? _problemWith(Map<String, Object?> flag, Set<String> seen) {
  final key = flag['key'];
  if (key is! String || !isValidFlagKey(key)) {
    return 'a key must be 1–64 characters of a–z, 0–9, _ . -';
  }
  if (seen.contains(key)) return 'a second definition of the same key';
  final typeName = flag['type'];
  final type = typeName is String ? FlagType.fromWireName(typeName) : null;
  if (type == null) return 'an unknown type ($typeName)';
  if (flagValueFromJson(type, flag['value']) == null) {
    return 'its value is not a ${type.wireName}';
  }
  if (flagValueFromJson(type, flag['offValue']) == null) {
    return 'its offValue is not a ${type.wireName}';
  }
  final enabled = flag['enabled'];
  if (enabled != null && enabled is! bool) return '"enabled" is not a bool';
  final rollout = flag['rollout'];
  if (rollout != null && _basisPoints(rollout) == null) {
    return 'a rollout must be 0–100 in steps of 0.01 (was $rollout)';
  }
  if (rulesFromJson(flag['rules']) == null) {
    return 'its rules can\'t be read (each needs an attribute, an operator '
        'and values)';
  }
  return null;
}

/// A rollout in percent as basis points (12.5 → 1250), or `null` if it
/// isn't 0–100 in steps of 0.01 (or is absent).
int? _basisPoints(Object? percent) {
  if (percent is! num || !percent.isFinite) return null;
  if (percent < 0 || percent > 100) return null;
  final basisPoints = (percent * 100).round();
  // 12.345 % isn't a whole number of basis points: refused, not rounded,
  // so the server's number is the one that is served.
  if ((percent * 100 - basisPoints).abs() > 1e-6) return null;
  return basisPoints;
}
