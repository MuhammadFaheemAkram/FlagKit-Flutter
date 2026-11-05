import 'package:flagkit/flagkit.dart';
import 'package:flagkit/testing.dart';
import 'package:flagkit_sample/app/bootstrap.dart';
import 'package:flagkit_sample/app/flagkit_sample_app.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'pump_app.dart';

/// Starts the whole app as `main()` does (the SDK, the graph, the user
/// context), optionally on a deep link. Pair it with
/// `tearDown(tearDownSample)`.
Future<void> pumpSample(WidgetTester tester, {String? initialLocation}) async {
  // In real time: the startup refresh writes to the cache, and initialize
  // waits for it (startupWait). In the test's fake time those writes would
  // never complete, and neither would the start (conventions §11.95).
  await tester.runAsync(startSample);
  tester.usePhoneSurface();
  await tester.pumpWidget(FlagKitSampleApp(initialLocation: initialLocation));
  await tester.pumpAndSettle();
}

/// The demo server the app's SDK talks to in tests: the app's own (its
/// flags from the asset), instant unless a test turns its knobs.
late FakeRemoteConfigServer testServer;

/// The device's network in tests: online, unless a test says otherwise.
late FakeNetworkMonitor testDevice;

/// What `main()` does before `runApp`: its own `bootstrap()`, with the
/// SDK's cache in memory (a widget test has no documents directory), no
/// interval timer (it would outlive the test), an instant server and a
/// device network the test controls.
Future<void> startSample() {
  FlagKitTesting.useInMemoryDatabase();
  FlagKitTesting.disableTimers();
  return bootstrap(
    beforeStart: () {
      testServer = getIt<FakeRemoteConfigServer>()..latency = Duration.zero;
      testDevice = FakeNetworkMonitor();
      getIt
        ..unregister<NetworkMonitor>(instanceName: 'device')
        ..registerSingleton<NetworkMonitor>(testDevice, instanceName: 'device');
    },
  );
}

/// Undoes [pumpSample]: a fresh graph, a stopped SDK and no context for
/// the next test.
Future<void> tearDownSample() async {
  await getIt.reset();
  await FlagKit.shutdown();
  FlagKit.setContext(const EvaluationContext());
  FlagKitTesting.useDeviceDatabase();
  FlagKitTesting.enableTimers();
}

/// The bottom bar's destination labelled [label] (a tab).
Finder destination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// The app bar showing [title]: which screen is on top.
Finder appBarTitled(String title) => find.widgetWithText(AppBar, title);

extension AppHarness on WidgetTester {
  /// The index of the selected tab.
  int get selectedTab =>
      widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}
