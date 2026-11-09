import 'package:flagkit/src/evaluation/rollout.dart';
import 'package:flagkit/src/evaluation/targeting.dart';
import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/evaluation_reason.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_source.dart';
import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:meta/meta.dart';

/// Turns a definition into a read's answer, for [context]: pure, so every
/// rule of the order is a test, and fast, since it runs on every read.
///
/// The order:
///
/// 1. a local override → the override (`override`): a debug tool, so it
///    wins over everything, definition or not; a read of another type
///    still gets the caller's default (`typeMismatch`);
/// 2. no definition → the caller's default (`flagNotFound`); a read of
///    another type → the caller's default (`typeMismatch`); `getDouble`
///    on an `int` flag is the one widening;
/// 3. switched off → the off value (`off`): the kill switch wins over
///    everything below, whoever is asking;
/// 4. rules that don't all match → the off value (`targetingMiss`);
/// 5. a rollout: [unit]'s bucket below the threshold → the value
///    (`targetingMatch` with rules, `rolloutIncluded` without); else the
///    off value (`rolloutExcluded`);
/// 6. otherwise → the value (`targetingMatch` with rules, `fallthrough`
///    without).
///
/// **Targeting decides who is eligible; the rollout decides what share of
/// the eligible get it**, as in Unleash and LaunchDarkly. A 25 % rollout to
/// Pakistan means a quarter of the users in Pakistan, not a quarter of
/// everyone who then happen to be in Pakistan.
@internal
FlagDetail evaluateFlag({
  required String key,
  required FlagDefinition? definition,
  required FlagSource source,
  required FlagType? requested,
  required EvaluationContext context,
  required String unit,
  FlagValue? override,
}) {
  if (override != null) {
    if (requested != null && !_readableAs(override.type, requested)) {
      return FlagDetail.fallback(key, EvaluationReason.typeMismatch);
    }
    return FlagDetail(
      key: key,
      value: override,
      source: FlagSource.override,
      reason: EvaluationReason.override,
    );
  }
  if (definition == null) {
    return FlagDetail.fallback(key, EvaluationReason.flagNotFound);
  }
  if (requested != null && !_readableAs(definition.type, requested)) {
    return FlagDetail.fallback(key, EvaluationReason.typeMismatch);
  }
  FlagDetail answer(EvaluationReason reason, {bool on = true, int? bucket}) =>
      FlagDetail(
        key: key,
        value: on ? definition.value : definition.offValue,
        source: source,
        reason: reason,
        bucket: bucket,
        rolloutPercent: switch (definition.rolloutBasisPoints) {
          final basisPoints? when bucket != null => basisPoints / 100,
          _ => null,
        },
      );

  if (!definition.enabled) return answer(EvaluationReason.off, on: false);
  final targeted = definition.rules.isNotEmpty;
  if (targeted && !matchesAll(definition.rules, context)) {
    return answer(EvaluationReason.targetingMiss, on: false);
  }
  if (definition.rolloutBasisPoints case final basisPoints?) {
    final bucket = bucketOf(key, unit);
    return rolloutIncludes(basisPoints, bucket)
        ? answer(
            targeted
                ? EvaluationReason.targetingMatch
                : EvaluationReason.rolloutIncluded,
            bucket: bucket,
          )
        : answer(EvaluationReason.rolloutExcluded, on: false, bucket: bucket);
  }
  return answer(
    targeted ? EvaluationReason.targetingMatch : EvaluationReason.fallthrough,
  );
}

bool _readableAs(FlagType type, FlagType requested) =>
    type == requested ||
    (requested == FlagType.decimal && type == FlagType.integer);
