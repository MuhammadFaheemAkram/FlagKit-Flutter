import 'dart:async';

import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/domain/flags/home_config.dart';

/// [AppFlags] with plain values a test sets, then [changed] to tell the
/// Cubits.
final class FakeAppFlags implements AppFlags {
  @override
  bool newHomeScreen = false;
  @override
  bool newCheckout = false;
  @override
  AppThemeChoice homeTheme = AppThemeChoice.classic;
  @override
  int feedPageSize = 20;
  @override
  double discountPercentage = 0;
  @override
  HomeConfig homeConfig = HomeConfig.fallback;

  final _changes = StreamController<void>.broadcast();

  /// Tells the listeners that a value changed.
  void changed() => _changes.add(null);

  @override
  Stream<void> watch() => _changes.stream;

  Future<void> close() => _changes.close();
}

/// [UserContext] in memory, recording nothing more than its state.
final class FakeUserContext implements UserContext {
  @override
  AppUser current = AppUser.initial;

  final _changes = StreamController<AppUser>.broadcast();

  void _set(AppUser user) {
    current = user;
    _changes.add(user);
  }

  @override
  Stream<AppUser> watch() => _changes.stream;

  @override
  void signIn(String userId) => _set(
    AppUser(
      userId: userId.trim(),
      country: current.country,
      appVersion: current.appVersion,
    ),
  );

  @override
  void signOut() =>
      _set(AppUser(country: current.country, appVersion: current.appVersion));

  @override
  void setCountry(String? country) => _set(
    AppUser(
      userId: current.userId,
      country: country,
      appVersion: current.appVersion,
    ),
  );

  @override
  void setAppVersion(String version) => _set(
    AppUser(
      userId: current.userId,
      country: current.country,
      appVersion: version,
    ),
  );

  Future<void> close() => _changes.close();
}

/// [FlagsDebug] with readings a test sets.
final class FakeFlagsDebug implements FlagsDebug {
  @override
  String sdkVersion = '9.9.9';

  List<FlagReading> readings = const [];

  final _changes = StreamController<void>.broadcast();

  void changed() => _changes.add(null);

  @override
  List<FlagReading> readAll() => readings;

  @override
  Stream<void> watch() => _changes.stream;

  final _cache = StreamController<CacheInfo>.broadcast();

  /// Sends [info] as the SDK's cache.
  void cache(CacheInfo info) => _cache.add(info);

  @override
  Stream<CacheInfo> watchCache() => _cache.stream;

  Future<void> close() async {
    await _changes.close();
    await _cache.close();
  }
}
