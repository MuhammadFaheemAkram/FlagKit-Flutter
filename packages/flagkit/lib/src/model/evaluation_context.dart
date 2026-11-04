import 'package:flutter/foundation.dart';

/// Who is asking: what targeting rules and rollouts look at.
///
/// Set once (`FlagKit.setContext`), not passed to every read: a screen
/// asks `isEnabled('new_checkout')` and the answer is already for this
/// user. Change it when the user signs in or out, or their country or app
/// version is known.
///
/// Values are `String`, `num` or `bool`. The three common ones have
/// fields; anything else goes in [attributes] (a plan, a cohort, a device
/// class).
@immutable
final class EvaluationContext {
  /// A context; every part is optional.
  const EvaluationContext({
    this.userId,
    this.country,
    this.appVersion,
    this.attributes = const {},
  });

  /// The signed-in user's id, or `null` for a signed-out user. Rollouts
  /// bucket by it, else by the install's anonymous id.
  final String? userId;

  /// The user's country, an ISO 3166 code (`PK`, `GB`).
  final String? country;

  /// The app's version, as `major.minor.patch` (`2.1.0`).
  final String? appVersion;

  /// Any other attribute a rule may target, by name.
  final Map<String, Object> attributes;

  /// The value of [attribute], as a rule sees it: `userId`, `country` and
  /// `appVersion` are the fields; any other name is looked up in
  /// [attributes]. `null` when the context doesn't have it.
  Object? valueOf(String attribute) => switch (attribute) {
    'userId' => userId,
    'country' => country,
    'appVersion' => appVersion,
    _ => attributes[attribute],
  };

  @override
  bool operator ==(Object other) =>
      other is EvaluationContext &&
      other.userId == userId &&
      other.country == country &&
      other.appVersion == appVersion &&
      mapEquals(other.attributes, attributes);

  @override
  int get hashCode => Object.hash(
    userId,
    country,
    appVersion,
    Object.hashAllUnordered(
      attributes.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );

  @override
  String toString() =>
      'EvaluationContext(userId: $userId, country: $country, '
      'appVersion: $appVersion, attributes: $attributes)';
}
