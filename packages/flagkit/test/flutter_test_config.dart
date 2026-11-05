import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flagkit/testing.dart';

/// Every SDK test starts without the interval timer: a client's periodic
/// timer would outlive its test. The scheduler's own tests turn it back
/// on, in fake time.
///
/// Tests open many databases on purpose (a client per test, a broken file
/// and its in-memory fallback): drift's warning about that is noise here.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  FlagKitTesting.disableTimers();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
