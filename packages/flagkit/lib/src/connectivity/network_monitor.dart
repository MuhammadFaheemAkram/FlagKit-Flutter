import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flagkit/src/util/start_with.dart';
import 'package:flutter/foundation.dart';

/// Whether the device has a network. The SDK asks before every refresh:
/// offline, nothing is attempted, and the cached flags keep serving reads
/// until the reconnect.
///
/// An app can pass its own (`FlagKitConfig.networkMonitor`), for example
/// one with a demo "offline" switch.
abstract interface class NetworkMonitor {
  /// Whether the device is online now.
  bool get isOnline;

  /// The current value on listen, then every change.
  Stream<bool> watch();
}

/// The default monitor: online when `connectivity_plus` reports any
/// connection (Wi-Fi, mobile, Ethernet, a VPN).
///
/// A connection isn't proof of the internet (a captive portal looks
/// online). That's fine: a refresh that can't reach the server fails as
/// "unreachable", and the cached flags stay.
class ConnectivityNetworkMonitor implements NetworkMonitor {
  /// A monitor on the device's connectivity.
  ConnectivityNetworkMonitor({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  bool _online = true;
  StreamSubscription<List<ConnectivityResult>>? _changes;
  final _controller = StreamController<bool>.broadcast();

  @override
  bool get isOnline => _online;

  /// Reads the current connectivity and starts following changes. Until
  /// then, and if the plugin can't answer, it says online: a refresh that
  /// fails then costs nothing, while a wrong "offline" would hold back
  /// every refresh for no reason.
  Future<void> start() async {
    try {
      _changes ??= _connectivity.onConnectivityChanged.listen(
        _update,
        onError: (Object _) {},
      );
      _update(await _connectivity.checkConnectivity());
    } on Object {
      // No plugin, or no binding yet (a test, an unsupported platform):
      // stay online. The SDK must never fail the host over this.
    }
  }

  void _update(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online == _online) return;
    _online = online;
    _controller.add(online);
  }

  @override
  Stream<bool> watch() => startWith(() => _online, _controller.stream);

  /// Stops following changes.
  Future<void> dispose() async {
    await _changes?.cancel();
    await _controller.close();
  }
}

/// A monitor a test (or a demo) sets by hand.
class FakeNetworkMonitor implements NetworkMonitor {
  /// Online unless [_online] is false.
  FakeNetworkMonitor({this._online = true});

  bool _online;
  final _controller = StreamController<bool>.broadcast();

  @override
  bool get isOnline => _online;

  /// Goes online or offline, telling every watcher.
  set online(bool value) {
    if (value == _online) return;
    _online = value;
    _controller.add(value);
  }

  @override
  Stream<bool> watch() => startWith(() => _online, _controller.stream);

  /// Whether anyone is watching (for tests that check a listener is gone).
  @visibleForTesting
  bool get hasListener => _controller.hasListener;
}
