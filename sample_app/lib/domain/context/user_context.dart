import 'package:flutter/foundation.dart';

/// Who is using the app, as targeting and rollouts see it: the Profile
/// tab edits it.
abstract interface class UserContext {
  /// The current user.
  AppUser get current;

  /// Emits the current user, then each change.
  Stream<AppUser> watch();

  /// This install's anonymous id: who rollouts bucket while no one is
  /// signed in. Emits it once known.
  Stream<String> watchInstallId();

  /// Signs in as [userId] (trimmed; blank is ignored).
  void signIn(String userId);

  /// Signs out.
  void signOut();

  /// Sets the user's country (`null`: unknown).
  void setCountry(String? country);

  /// Sets the app's version, for the demo: a real app reports its own.
  void setAppVersion(String version);
}

/// The user, as the app knows them.
@immutable
final class AppUser {
  const AppUser({this.userId, this.country, required this.appVersion});

  /// The countries the demo offers (ISO 3166 codes).
  static const countries = ['PK', 'AE', 'GB', 'US', 'DE'];

  /// The app versions the demo offers.
  static const appVersions = ['1.9.0', '2.0.0', '2.1.0'];

  /// Who the app starts as: signed out, country unknown, the latest
  /// version.
  static const initial = AppUser(appVersion: '2.1.0');

  /// The signed-in user's id, or `null` when signed out.
  final String? userId;

  /// The user's country, or `null` when unknown.
  final String? country;

  /// The app's version.
  final String appVersion;

  bool get isSignedIn => userId != null;

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.userId == userId &&
      other.country == country &&
      other.appVersion == appVersion;

  @override
  int get hashCode => Object.hash(userId, country, appVersion);

  @override
  String toString() =>
      'AppUser(userId: $userId, country: $country, appVersion: $appVersion)';
}
