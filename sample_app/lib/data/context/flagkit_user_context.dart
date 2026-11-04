import 'dart:async';

import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/core/common/start_with.dart';
import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:injectable/injectable.dart';

/// [UserContext] with FlagKit: every change becomes the SDK's evaluation
/// context, so targeting and rollouts follow the user at once.
///
/// The demo keeps the user in memory: a relaunch starts signed out.
@LazySingleton(as: UserContext)
class FlagKitUserContext implements UserContext {
  FlagKitUserContext(this._flags) {
    _flags.setContext(_toContext(_current));
  }

  final FlagKitClient _flags;
  AppUser _current = AppUser.initial;
  final _changes = StreamController<AppUser>.broadcast();

  @override
  AppUser get current => _current;

  @override
  Stream<AppUser> watch() => startWith(() => _current, _changes.stream);

  @override
  void signIn(String userId) {
    final id = userId.trim();
    if (id.isEmpty) return;
    _set(
      AppUser(
        userId: id,
        country: _current.country,
        appVersion: _current.appVersion,
      ),
    );
  }

  @override
  void signOut() =>
      _set(AppUser(country: _current.country, appVersion: _current.appVersion));

  @override
  void setCountry(String? country) => _set(
    AppUser(
      userId: _current.userId,
      country: country,
      appVersion: _current.appVersion,
    ),
  );

  @override
  void setAppVersion(String version) => _set(
    AppUser(
      userId: _current.userId,
      country: _current.country,
      appVersion: version,
    ),
  );

  void _set(AppUser user) {
    if (user == _current) return;
    _current = user;
    _flags.setContext(_toContext(user));
    _changes.add(user);
  }

  static EvaluationContext _toContext(AppUser user) => EvaluationContext(
    userId: user.userId,
    country: user.country,
    appVersion: user.appVersion,
  );

  /// Closes the change stream. The app never calls it (the user context
  /// lives as long as the app); tests do. Not `@disposeMethod`: on an
  /// `as:` registration, injectable would call it on the interface
  /// (conventions §11.42).
  Future<void> dispose() => _changes.close();
}
