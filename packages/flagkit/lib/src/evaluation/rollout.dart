import 'package:flagkit/src/evaluation/fnv1a.dart';
import 'package:meta/meta.dart';

/// How many buckets a rollout has: basis points, so a rollout can be 12.5 %
/// (1250 buckets), not only whole percents.
@internal
const rolloutBuckets = 10000;

/// [unit]'s bucket for the flag [flagKey]: 0–9999, the same for the same
/// pair on every device and every run.
///
/// The flag's key is in the hash so that each flag orders users
/// differently. Without it, the users in the first 10 % of one rollout
/// would be the first 10 % of every rollout: the same few people would try
/// every new feature first.
@internal
int bucketOf(String flagKey, String unit) =>
    fnv1a32('$flagKey:$unit') % rolloutBuckets;

/// Whether a rollout of [basisPoints] (0–10000) includes [bucket].
///
/// Monotonic: a bucket included at 10 % is included at 25 %, since its
/// number doesn't change and only the threshold moves. Raising a rollout
/// never takes a feature away from anyone who had it.
@internal
bool rolloutIncludes(int basisPoints, int bucket) => bucket < basisPoints;
