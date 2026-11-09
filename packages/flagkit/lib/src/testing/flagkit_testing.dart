import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/scheduling/refresh_scheduler.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';

/// Switches for an app's own tests (`package:flagkit/testing.dart`).
///
/// A widget test has no documents directory and no SQLite file to open. An
/// app whose tests start the real SDK (`FlagKit.initialize`) calls
/// [useInMemoryDatabase] first: each start then gets a fresh database in
/// memory, gone when the test ends.
abstract final class FlagKitTesting {
  /// Starts from now keep their flags in memory.
  static void useInMemoryDatabase() =>
      openFlagKitDatabase = FlagKitDatabase.inMemory;

  /// Starts from now use the file on the device again (the default).
  static void useDeviceDatabase() =>
      openFlagKitDatabase = FlagKitDatabase.onDevice;

  /// No interval timer: a widget test fails if a timer is still pending
  /// when it ends, and the SDK outlives the widget tree. Refreshes that
  /// follow events still run (startup, resume, a reconnect), and so does
  /// `refresh()`.
  static void disableTimers() => schedulerTimersEnabled = false;

  /// The timer again (the default).
  static void enableTimers() => schedulerTimersEnabled = true;

  /// Starts from now name a new install [id] instead of a random UUID: a
  /// signed-out user lands in a known bucket of every rollout, so a test
  /// knows which side of it the app is on. An install that already has an
  /// id keeps it.
  static void useAnonymousId(String id) => newAnonymousId = () => id;

  /// New installs get random ids again (the default).
  static void useRandomAnonymousIds() => newAnonymousId = randomAnonymousId;
}
