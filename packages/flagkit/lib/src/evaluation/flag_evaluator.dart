import 'package:flagkit/src/model/evaluation_reason.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_source.dart';
import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:meta/meta.dart';

/// Turns a definition into a read's answer: pure, so every rule of the
/// order is a test, and fast, since it runs on every read.
///
/// The order (the steps marked later arrive with their versions):
///
/// 1. no definition → the caller's default (`flagNotFound`);
/// 2. a read of another type → the caller's default (`typeMismatch`);
///    `getDouble` on an `int` flag is the one widening;
/// 3. switched off → the off value (`off`): the kill switch wins over
///    everything below;
/// 4. (0.4.0) targeting rules, then the rollout;
/// 5. otherwise → the value (`fallthrough`).
@internal
FlagDetail evaluateFlag({
  required String key,
  required FlagDefinition? definition,
  required FlagSource source,
  required FlagType? requested,
}) {
  if (definition == null) {
    return FlagDetail.fallback(key, EvaluationReason.flagNotFound);
  }
  if (requested != null && !_readableAs(definition.type, requested)) {
    return FlagDetail.fallback(key, EvaluationReason.typeMismatch);
  }
  if (!definition.enabled) {
    return FlagDetail(
      key: key,
      value: definition.offValue,
      source: source,
      reason: EvaluationReason.off,
    );
  }
  return FlagDetail(
    key: key,
    value: definition.value,
    source: source,
    reason: EvaluationReason.fallthrough,
  );
}

bool _readableAs(FlagType type, FlagType requested) =>
    type == requested ||
    (requested == FlagType.decimal && type == FlagType.integer);
