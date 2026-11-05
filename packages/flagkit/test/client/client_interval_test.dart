import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/sdk.dart';

// The interval on a whole client, in fake time: the timer follows the
// cache's age, re-armed by every refresh. A periodic timer started at
// launch would tick just before the first fetch's cache turned stale and
// skip a whole period (found on a device in Phase 3).
void main() {
  setUp(FlagKitTesting.enableTimers);
  tearDown(FlagKitTesting.disableTimers);

  test(
    'the first interval refresh comes one interval after the first fetch',
    () {
      fakeAsync((async) {
        const interval = Duration(minutes: 1);
        // The server's default latency: 600 ms per fetch.
        final server = FakeRemoteConfigServer(flags: [wireFlag('a')]);
        FlagKitClientImpl? client;
        FlagKitClientImpl.open(
          testConfig(transport: server, refreshInterval: interval),
          database: FlagKitDatabase.inMemory(),
          clock: Clock(() => testNow.add(async.elapsed)),
          newId: SequentialIds().call,
          lifecycle: FakeAppLifecycle(),
        ).then((c) => client = c);
        async.elapse(const Duration(seconds: 1));
        expect(client, isNotNull);
        expect(server.stats.requests, 1, reason: 'the startup refresh');

        // The fetch finished at 0.6 s: stale at 60.6 s, not at 60 s.
        async.elapse(const Duration(seconds: 59, milliseconds: 500));
        expect(server.stats.requests, 1);
        async.elapse(const Duration(seconds: 1));
        expect(server.stats.requests, 2, reason: 'the interval, on time');
        expect(server.stats.notModified, 1);

        // And again a minute after that one.
        async.elapse(interval + const Duration(seconds: 1));
        expect(server.stats.requests, 3);

        client!.shutdown();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
      });
    },
  );
}
