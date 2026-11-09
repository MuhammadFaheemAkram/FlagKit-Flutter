import 'dart:async';
import 'dart:convert';

import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/core/common/start_with.dart';
import 'package:flagkit_sample/data/flags/app_flag_keys.dart';
import 'package:flagkit_sample/domain/demo/demo_server.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// [DemoServer] over the SDK's `FakeRemoteConfigServer`: the console edits
/// its flags (each change bumps its version), the knobs set its failure
/// rate and latency.
@LazySingleton(as: DemoServer)
class FakeServerDemo implements DemoServer {
  FakeServerDemo(this._server);

  final FakeRemoteConfigServer _server;
  final _knobChanges = StreamController<ServerKnobs>.broadcast();

  @override
  Stream<List<ServerFlag>> watchFlags() =>
      _server.watchStats().map((_) => _flags()).distinct(listEquals);

  List<ServerFlag> _flags() => [
    for (final flag in _server.flags)
      ServerFlag(
        key: flag['key']! as String,
        enabled: flag['enabled'] as bool? ?? true,
        value: jsonEncode(flag['value']),
        rolloutPercent: (flag['rollout'] as num?)?.toDouble(),
        isTheme: flag['key'] == AppFlagKeys.homeTheme,
      ),
  ];

  @override
  void setEnabled(String key, bool enabled) => _server.setEnabled(key, enabled);

  @override
  void setRollout(String key, double? percent) =>
      _server.setRollout(key, percent);

  @override
  void setTheme(String theme) => _server.setValue(AppFlagKeys.homeTheme, theme);

  ServerKnobs get _knobs => ServerKnobs(
    failures: switch (_server.failureRate) {
      <= 0 => ServerFailures.none,
      >= 1 => ServerFailures.all,
      _ => ServerFailures.half,
    },
    speed: switch (_server.latency) {
      Duration.zero => ServerSpeed.fast,
      final latency when latency <= const Duration(seconds: 1) =>
        ServerSpeed.normal,
      _ => ServerSpeed.slow,
    },
  );

  @override
  Stream<ServerKnobs> watchKnobs() =>
      startWith(() => _knobs, _knobChanges.stream);

  @override
  void setFailures(ServerFailures failures) {
    _server.failureRate = switch (failures) {
      ServerFailures.none => 0,
      ServerFailures.half => 0.5,
      ServerFailures.all => 1,
    };
    _knobChanges.add(_knobs);
  }

  @override
  void setSpeed(ServerSpeed speed) {
    _server.latency = switch (speed) {
      ServerSpeed.fast => Duration.zero,
      ServerSpeed.normal => const Duration(milliseconds: 600),
      ServerSpeed.slow => const Duration(seconds: 3),
    };
    _knobChanges.add(_knobs);
  }

  /// Closes the knob stream (tests; the app's server lives as long as it).
  Future<void> dispose() => _knobChanges.close();
}
