/// Why a read has the value it has: the answer to "why is this flag off
/// for me?".
///
/// Complete from the first version, though rules and rollouts arrive later:
/// a case added to an enum breaks every host's exhaustive `switch` over it.
enum EvaluationReason {
  /// A local debug override won.
  override,

  /// The flag is switched off on the server (its kill switch): the flag's
  /// off value, whatever the rules or the rollout say.
  off,

  /// The targeting rules matched (and the rollout, if any, included this
  /// user): the flag's value.
  targetingMatch,

  /// The targeting rules didn't match: the flag's off value.
  targetingMiss,

  /// No rules; the rollout included this user: the flag's value.
  rolloutIncluded,

  /// The rollout excluded this user: the flag's off value.
  rolloutExcluded,

  /// The flag is on for everyone (no rules, no rollout): its value.
  fallthrough,

  /// FlagKit isn't running (before `initialize`, or after `shutdown`): the
  /// caller's default.
  notInitialized,

  /// FlagKit doesn't know the flag: the caller's default.
  flagNotFound,

  /// The read asked for another type than the flag's: the caller's
  /// default.
  typeMismatch,
}
