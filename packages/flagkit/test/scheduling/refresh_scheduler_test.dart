import 'package:fake_async/fake_async.dart';
import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/scheduling/refresh_scheduler.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:flagkit/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  // The interval timer is off for every other test (flutter_test_config);
  // these tests are about it, in fake time.
  setUp(FlagKitTesting.enableTimers);
  tearDown(FlagKitTesting.disableTimers);

  const interval = Duration(minutes: 1);

  late List<RefreshTrigger> triggers;
  late CacheStatus status;
  late Duration untilStale;
  late bool paused;
  late FakeNetworkMonitor monitor;
  late FakeAppLifecycle lifecycle;

  RefreshScheduler scheduler() => RefreshScheduler(
    refresh: (trigger) async {
      triggers.add(trigger);
      return const Updated();
    },
    status: () => status,
    untilStale: () => untilStale,
    monitor: monitor,
    lifecycle: lifecycle,
    interval: interval,
    paused: () => paused,
    logger: FlagKitLogger.silent(),
  );

  setUp(() {
    triggers = [];
    status = CacheStatus.stale;
    untilStale = Duration.zero;
    paused = false;
    monitor = FakeNetworkMonitor();
    lifecycle = FakeAppLifecycle();
  });

  test('the timer fires the moment the cache turns stale', () {
    fakeAsync((async) {
      status = CacheStatus.fresh;
      untilStale = const Duration(seconds: 25);
      scheduler().start();

      async.elapse(const Duration(seconds: 24));
      expect(triggers, isEmpty);

      status = CacheStatus.stale;
      async.elapse(const Duration(seconds: 1));
      expect(triggers, [RefreshTrigger.interval]);
    });
  });

  test('already stale: one interval, then another; never at once', () {
    fakeAsync((async) {
      scheduler().start();

      async.elapse(interval - const Duration(milliseconds: 1));
      expect(triggers, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      expect(triggers, [RefreshTrigger.interval]);

      // The (fake) refresh left it stale: the next try waits an interval.
      async.elapse(interval);
      expect(triggers, [RefreshTrigger.interval, RefreshTrigger.interval]);
      expect(async.pendingTimers, hasLength(1));
    });
  });

  test('rearm() follows the cache\'s new age', () {
    fakeAsync((async) {
      status = CacheStatus.fresh;
      untilStale = const Duration(seconds: 10);
      final s = scheduler()..start();

      // A refresh made the cache fresh for a whole interval again.
      async.elapse(const Duration(seconds: 5));
      untilStale = interval;
      s.rearm();
      async.elapse(const Duration(seconds: 10));
      expect(triggers, isEmpty, reason: 'the old moment has passed unused');

      status = CacheStatus.stale;
      async.elapse(interval - const Duration(seconds: 10));
      expect(triggers, [RefreshTrigger.interval]);
    });
  });

  test('a fresh cache: no request at all', () {
    fakeAsync((async) {
      status = CacheStatus.fresh;
      scheduler().start();

      async.elapse(interval * 3);
      lifecycle
        ..foreground = false
        ..foreground = true;
      monitor
        ..online = false
        ..online = true;
      async.flushMicrotasks();

      expect(triggers, isEmpty);
    });
  });

  test('every status but fresh refreshes', () {
    for (final s in [
      CacheStatus.stale,
      CacheStatus.expired,
      CacheStatus.empty,
    ]) {
      fakeAsync((async) {
        triggers = [];
        status = s;
        scheduler().start();
        async.elapse(interval);
        expect(triggers, [RefreshTrigger.interval], reason: '$s');
      });
    }
  });

  test('back in the foreground: a refresh, and the timer again', () {
    fakeAsync((async) {
      scheduler().start();
      lifecycle.foreground = false;
      // In the background, no timer.
      async.elapse(interval * 3);
      expect(triggers, isEmpty);

      lifecycle.foreground = true;
      async.flushMicrotasks();
      expect(triggers, [RefreshTrigger.resumed]);

      async.elapse(interval);
      expect(triggers.last, RefreshTrigger.interval);
    });
  });

  test('a reconnect refreshes; the first value of the monitor isn\'t one', () {
    fakeAsync((async) {
      scheduler().start();
      async.flushMicrotasks();
      expect(triggers, isEmpty);

      monitor
        ..online = false
        ..online = true;
      async.flushMicrotasks();

      expect(triggers, [RefreshTrigger.reconnect]);
    });
  });

  test('offline: nothing is asked', () {
    fakeAsync((async) {
      monitor.online = false;
      scheduler().start();
      async.elapse(interval * 2);

      expect(triggers, isEmpty);
    });
  });

  test('a rejected key: nothing is asked', () {
    fakeAsync((async) {
      paused = true;
      scheduler().start();
      async.elapse(interval * 2);
      lifecycle
        ..foreground = false
        ..foreground = true;
      async.flushMicrotasks();

      expect(triggers, isEmpty);
    });
  });

  test('stopped: no timer, no trigger', () {
    fakeAsync((async) {
      final s = scheduler()..start();
      s.stop();
      async.flushMicrotasks();

      async.elapse(interval * 2);
      lifecycle
        ..foreground = false
        ..foreground = true;
      async.flushMicrotasks();

      expect(triggers, isEmpty);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('with timers disabled, a host\'s test has none pending', () {
    fakeAsync((async) {
      FlagKitTesting.disableTimers();
      scheduler().start();

      expect(async.pendingTimers, isEmpty);
    });
  });
}
