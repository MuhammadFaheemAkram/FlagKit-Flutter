import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flagkit/src/model/targeting_rule.dart';
import 'package:flagkit/src/network/remote_config_transport.dart';
import 'package:flagkit/src/util/start_with.dart';
import 'package:flutter/foundation.dart';

/// A remote config server in memory: the SDK's default transport, and the
/// demo's backend.
///
/// It holds definitions in the wire format and a config [version] that
/// every change bumps, and answers like a real server would: after a delay
/// ([latency]), sometimes with an error ([failureRate]), never when
/// unreachable ([reachable]), never for a bad key, and "not modified" when
/// the client already has the current version.
///
/// Its **console** ([setFlag], [setValue], [setEnabled], [removeFlag])
/// is what an admin dashboard would do: change a flag on the server, so
/// the next refresh brings it.
class FakeRemoteConfigServer implements RemoteConfigTransport {
  /// A server holding [flags] (definitions in the wire format) at
  /// [version]. With none, it serves an empty config: every read in the
  /// app gets its default.
  FakeRemoteConfigServer({
    List<Map<String, Object?>> flags = const [],
    this._version = 1,
    this.latency = const Duration(milliseconds: 600),
    this.failureRate = 0,
    this.reachable = true,
    Random? random,
  }) : _flags = [for (final flag in flags) _copy(flag)],
       _random = random ?? Random();

  /// A server holding [config], `{"version": …, "flags": [...]}`: what the
  /// sample loads from its assets.
  factory FakeRemoteConfigServer.fromJson(
    Map<String, Object?> config, {
    Duration latency = const Duration(milliseconds: 600),
  }) => FakeRemoteConfigServer(
    flags: [
      for (final flag in config['flags']! as List<Object?>)
        flag! as Map<String, Object?>,
    ],
    version: config['version']! as int,
    latency: latency,
  );

  /// How long each answer takes.
  Duration latency;

  /// The share of fetches (0–1) that fail with a 503.
  double failureRate;

  /// `false`: every fetch fails as unreachable.
  bool reachable;

  final List<Map<String, Object?>> _flags;
  int _version;
  final Random _random;
  int _requests = 0;
  int _notModified = 0;
  int _failures = 0;
  final _statsChanges = StreamController<FakeServerStats>.broadcast();

  /// The config's version: bumped by every change.
  int get version => _version;

  /// The definitions, in the wire format (copies).
  List<Map<String, Object?>> get flags => [for (final f in _flags) _copy(f)];

  /// What the server has seen.
  FakeServerStats get stats => FakeServerStats(
    requests: _requests,
    notModified: _notModified,
    failures: _failures,
    version: _version,
  );

  /// [stats] now, then after every request and every change.
  Stream<FakeServerStats> watchStats() =>
      startWith(() => stats, _statsChanges.stream);

  @override
  Future<FetchResponse> fetch(FetchRequest request) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (!reachable) throw const ServerUnreachable();
    _requests++;
    try {
      final key = request.apiKey.trim();
      if (key.isEmpty || key.startsWith('invalid')) {
        _failures++;
        throw const ApiKeyRejected();
      }
      if (_random.nextDouble() < failureRate) {
        _failures++;
        throw const ServerFailure(503);
      }
      if (request.ifVersion == _version) {
        _notModified++;
        return const ConfigNotModified();
      }
      // Through JSON and back, as an HTTP body would be: the client gets
      // its own copy, and nothing it does reaches the server's state.
      final body = jsonDecode(
        jsonEncode({'version': _version, 'flags': _flags}),
      );
      return FetchedConfig(body as Map<String, Object?>);
    } finally {
      _statsChanges.add(stats);
    }
  }

  /// Adds the flag [definition] (wire format), or replaces the one with
  /// its key.
  void setFlag(Map<String, Object?> definition) {
    final key = definition['key'];
    final index = _flags.indexWhere((flag) => flag['key'] == key);
    if (index < 0) {
      _flags.add(_copy(definition));
    } else {
      _flags[index] = _copy(definition);
    }
    _changed();
  }

  /// Sets the flag [key]'s value (when it applies).
  void setValue(String key, Object? value) => _edit(key, 'value', value);

  /// Switches the flag [key] on or off (its kill switch).
  void setEnabled(String key, bool enabled) => _edit(key, 'enabled', enabled);

  /// Rolls the flag [key] out to [percent] of its eligible users (0–100,
  /// in steps of 0.01); `null` removes the rollout: everyone eligible.
  void setRollout(String key, double? percent) =>
      _edit(key, 'rollout', percent);

  /// Targets the flag [key] at the users matching every one of [rules];
  /// an empty list removes the targeting: everyone.
  void setRules(String key, List<TargetingRule> rules) => _edit(
    key,
    'rules',
    rules.isEmpty ? null : [for (final rule in rules) rule.toJson()],
  );

  /// Deletes the flag [key].
  void removeFlag(String key) {
    final before = _flags.length;
    _flags.removeWhere((flag) => flag['key'] == key);
    if (_flags.length != before) _changed();
  }

  void _edit(String key, String field, Object? value) {
    final flag = _flags.where((f) => f['key'] == key).firstOrNull;
    if (flag == null) throw ArgumentError.value(key, 'key', 'no such flag');
    if (value == null && field != 'value') {
      flag.remove(field);
    } else {
      flag[field] = value;
    }
    _changed();
  }

  void _changed() {
    _version++;
    _statsChanges.add(stats);
  }

  static Map<String, Object?> _copy(Map<String, Object?> flag) =>
      jsonDecode(jsonEncode(flag)) as Map<String, Object?>;
}

/// What the fake server has seen.
@immutable
final class FakeServerStats {
  /// The server's counts.
  const FakeServerStats({
    required this.requests,
    required this.notModified,
    required this.failures,
    required this.version,
  });

  /// Fetches that reached it.
  final int requests;

  /// Of those, the ones answered "not modified".
  final int notModified;

  /// Of those, the ones that failed (a 503, a rejected key).
  final int failures;

  /// The config's version now.
  final int version;

  @override
  bool operator ==(Object other) =>
      other is FakeServerStats &&
      other.requests == requests &&
      other.notModified == notModified &&
      other.failures == failures &&
      other.version == version;

  @override
  int get hashCode => Object.hash(requests, notModified, failures, version);

  @override
  String toString() =>
      'FakeServerStats($requests requests, $notModified not modified, '
      '$failures failed, version $version)';
}
