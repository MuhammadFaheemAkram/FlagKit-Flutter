import 'dart:async';
import 'dart:convert';

import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/data/network/demo_network_monitor.dart';
import 'package:flagkit_sample/domain/network/device_network.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Registrations for objects the app doesn't construct itself.
@module
abstract class AppModule {
  /// The SDK's client, started by the bootstrap with `FlagKit.initialize`
  /// before anything resolves it. Registering it lets the adapters receive
  /// it through their constructors, like any other dependency.
  @lazySingleton
  FlagKitClient get flagKit => FlagKit.instance;

  /// The demo's remote config server, holding the app's flags from its
  /// assets. The SDK uses it as its transport, and the Dashboard's demo
  /// controls turn its knobs. Resolved before the graph is built: reading
  /// an asset is asynchronous.
  @preResolve
  @singleton
  Future<FakeRemoteConfigServer> server() async =>
      FakeRemoteConfigServer.fromJson(
        jsonDecode(await rootBundle.loadString('assets/remote_config.json'))
            as Map<String, Object?>,
      );

  /// The device's real connectivity (tests register a fake under this
  /// name).
  @Named('device')
  @lazySingleton
  NetworkMonitor deviceMonitor() {
    final monitor = ConnectivityNetworkMonitor();
    unawaited(monitor.start());
    return monitor;
  }

  /// The SDK's monitor: the device's, plus the demo switch.
  @lazySingleton
  DemoNetworkMonitor demoNetwork(@Named('device') NetworkMonitor device) =>
      DemoNetworkMonitor(device)..start();

  /// The same object, as the Dashboard sees it.
  @lazySingleton
  DeviceNetwork deviceNetwork(DemoNetworkMonitor monitor) => monitor;
}
