/// Helpers for testing an app that uses FlagKit.
///
/// A second public library, imported only by tests, so the everyday API
/// carries nothing that exists for tests. Like `flagkit.dart`, its names
/// change only with a new major version.
library;

export 'package:flagkit/src/connectivity/network_monitor.dart'
    show FakeNetworkMonitor;
export 'package:flagkit/src/testing/flagkit_testing.dart' show FlagKitTesting;
