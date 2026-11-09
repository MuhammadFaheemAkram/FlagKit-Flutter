import 'dart:async';

import 'package:flagkit_sample/core/common/start_with.dart';
import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/demo/demo_server.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/domain/flags/home_config.dart';
import 'package:flagkit_sample/domain/network/device_network.dart';

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

  /// What [explain] says for each flag; an app default when not set.
  final readings = <AppFlag, FlagReading>{};

  @override
  FlagReading explain(AppFlag flag) =>
      readings[flag] ??
      FlagReading(
        key: flag.name,
        value: '—',
        source: ReadingSource.appDefault,
        reason: ReadingReason.unknownFlag,
      );

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
  final _installIds = StreamController<String>.broadcast();

  /// Sends [id] as the install's anonymous id.
  void installId(String id) => _installIds.add(id);

  @override
  Stream<String> watchInstallId() => _installIds.stream;

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

  Future<void> close() async {
    await _changes.close();
    await _installIds.close();
  }
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

  /// What [refresh] returns; hold it with [refreshGate].
  RefreshSummary refreshResult = const RefreshSummary(RefreshKind.upToDate);
  Completer<void>? refreshGate;
  int refreshes = 0;

  @override
  Future<RefreshSummary> refresh() async {
    refreshes++;
    await refreshGate?.future;
    return refreshResult;
  }

  /// The refresh log a test sends.
  final _log = StreamController<List<LastRefresh>>.broadcast();
  void log(List<LastRefresh> refreshes) => _log.add(refreshes);

  @override
  Stream<List<LastRefresh>> watchRefreshLog() => _log.stream;

  int cacheClears = 0;

  @override
  Future<void> clearCache() async => cacheClears++;

  /// What [inspect] says, by key; `null` for a flag not in it.
  final inspections = <String, FlagInspection>{};

  @override
  FlagInspection? inspect(String key) => inspections[key];

  /// What [readFor] returns, and every id it was asked.
  List<FlagReading> readForResult = const [];
  final triedUsers = <String>[];

  @override
  List<FlagReading> readFor(String userId) {
    triedUsers.add(userId);
    return readForResult;
  }

  /// The overrides set (key → text); [overrideError] makes them fail.
  final overrides = <String, String>{};
  String? overrideError;

  @override
  Future<String?> setOverride(String key, String text) async {
    if (overrideError case final error?) return error;
    overrides[key] = text;
    return null;
  }

  @override
  Future<void> clearOverride(String key) async => overrides.remove(key);

  int overrideClears = 0;

  @override
  Future<void> clearOverrides() async {
    overrideClears++;
    overrides.clear();
  }

  Future<void> close() async {
    await _changes.close();
    await _cache.close();
    await _log.close();
  }
}

/// [DemoServer] in memory: the flags and knobs a test sets, and the calls.
final class FakeDemoServer implements DemoServer {
  List<ServerFlag> flags = const [];
  ServerKnobs knobs = const ServerKnobs();
  final _flags = StreamController<List<ServerFlag>>.broadcast();
  final _knobs = StreamController<ServerKnobs>.broadcast();

  /// Every console call, in words: "enabled new_checkout false".
  final calls = <String>[];

  void sendFlags(List<ServerFlag> value) => _flags.add(flags = value);

  @override
  Stream<List<ServerFlag>> watchFlags() =>
      startWith(() => flags, _flags.stream);

  @override
  Stream<ServerKnobs> watchKnobs() => startWith(() => knobs, _knobs.stream);

  @override
  void setEnabled(String key, bool enabled) =>
      calls.add('enabled $key $enabled');

  @override
  void setRollout(String key, double? percent) =>
      calls.add('rollout $key $percent');

  @override
  void setTheme(String theme) => calls.add('theme $theme');

  @override
  void setFailures(ServerFailures failures) {
    calls.add('failures ${failures.name}');
    _knobs.add(knobs = ServerKnobs(failures: failures, speed: knobs.speed));
  }

  @override
  void setSpeed(ServerSpeed speed) {
    calls.add('speed ${speed.name}');
    _knobs.add(knobs = ServerKnobs(failures: knobs.failures, speed: speed));
  }

  Future<void> close() async {
    await _flags.close();
    await _knobs.close();
  }
}

/// [DeviceNetwork] in memory: the status a test sets, and the switch.
final class FakeDeviceNetwork implements DeviceNetwork {
  NetworkStatus status = const NetworkStatus(deviceOnline: true);
  final _changes = StreamController<NetworkStatus>.broadcast();

  void set(NetworkStatus value) {
    status = value;
    _changes.add(value);
  }

  @override
  Stream<NetworkStatus> watchStatus() => _changes.stream;

  @override
  void simulateOffline(bool offline) =>
      set(status.copyWith(simulatingOffline: offline));

  Future<void> close() => _changes.close();
}
