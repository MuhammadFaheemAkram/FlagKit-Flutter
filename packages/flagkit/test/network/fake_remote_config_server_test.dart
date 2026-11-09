import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flagkit/flagkit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  const request = FetchRequest(apiKey: 'demo_key', sdkVersion: '0.3.0');

  FakeRemoteConfigServer server({
    double failureRate = 0,
    List<Map<String, Object?>>? flags,
  }) => FakeRemoteConfigServer(
    latency: Duration.zero,
    failureRate: failureRate,
    random: Random(1),
    flags: flags ?? [wireFlag('new_home_screen')],
    version: 7,
  );

  test('serves its config, as JSON would carry it', () async {
    final response = await server().fetch(request);

    expect(response, isA<FetchedConfig>());
    expect((response as FetchedConfig).json, {
      'version': 7,
      'flags': [wireFlag('new_home_screen')],
    });
  });

  test('the same version: not modified, with no body', () async {
    final s = server();
    final response = await s.fetch(
      const FetchRequest(apiKey: 'demo_key', sdkVersion: '0.3.0', ifVersion: 7),
    );

    expect(response, isA<ConfigNotModified>());
    expect(s.stats.notModified, 1);
    // An older version gets the config.
    expect(
      await s.fetch(
        const FetchRequest(apiKey: 'demo_key', sdkVersion: '0', ifVersion: 6),
      ),
      isA<FetchedConfig>(),
    );
  });

  test('answers after its latency', () {
    fakeAsync((async) {
      final s = FakeRemoteConfigServer(latency: const Duration(seconds: 1));
      FetchResponse? response;
      s.fetch(request).then((r) => response = r);

      async.elapse(const Duration(milliseconds: 999));
      expect(response, isNull);
      async.elapse(const Duration(milliseconds: 1));
      expect(response, isNotNull);
    });
  });

  test('unreachable: throws, and counts no request', () async {
    final s = server()..reachable = false;

    await expectLater(s.fetch(request), throwsA(isA<ServerUnreachable>()));
    expect(s.stats.requests, 0);
  });

  test('a blank key, or one starting "invalid": rejected', () async {
    for (final key in ['', '  ', 'invalid_key']) {
      await expectLater(
        server().fetch(FetchRequest(apiKey: key, sdkVersion: '0')),
        throwsA(isA<ApiKeyRejected>()),
      );
    }
  });

  test('a failure rate of 1 always fails with a 503; 0 never', () async {
    await expectLater(
      server(failureRate: 1).fetch(request),
      throwsA(isA<ServerFailure>().having((e) => e.statusCode, 'status', 503)),
    );
    final s = server();
    for (var i = 0; i < 20; i++) {
      await s.fetch(request);
    }
    expect(s.stats.failures, 0);
  });

  test('a client\'s copy is its own', () async {
    final s = server();
    final body = (await s.fetch(request) as FetchedConfig).json;
    ((body['flags']! as List<Object?>).first!
            as Map<String, Object?>)['value'] =
        false;

    expect(s.flags.single['value'], true);
  });

  group('the console', () {
    test('every change bumps the version', () {
      final s = server()
        ..setValue('new_home_screen', false)
        ..setEnabled('new_home_screen', false)
        ..setFlag(wireFlag('new_checkout'))
        ..setFlag(wireFlag('new_checkout', value: false));

      expect(s.version, 11);
      expect(s.flags.map((f) => f['key']), ['new_home_screen', 'new_checkout']);
      expect(s.flags.first['enabled'], false);
      expect(s.flags.last['value'], false);
    });

    test('removing a flag; removing one it hasn\'t changes nothing', () {
      final s = server()..removeFlag('nope');
      expect(s.version, 7);

      s.removeFlag('new_home_screen');
      expect(s.flags, isEmpty);
      expect(s.version, 8);
    });

    test('rollouts and rules: set, then removed', () async {
      final s = server()
        ..setRollout('new_home_screen', 25)
        ..setRules('new_home_screen', [
          TargetingRule(
            attribute: 'country',
            operator: TargetingOperator.isIn,
            values: const ['PK'],
          ),
        ]);

      expect(s.version, 9);
      expect(s.flags.single['rollout'], 25);
      expect(s.flags.single['rules'], [
        {
          'attribute': 'country',
          'operator': 'in',
          'values': ['PK'],
        },
      ]);

      s
        ..setRollout('new_home_screen', null)
        ..setRules('new_home_screen', const []);
      expect(s.flags.single.containsKey('rollout'), isFalse);
      expect(s.flags.single.containsKey('rules'), isFalse);
      expect(s.version, 11);
    });

    test('editing a flag it hasn\'t is a mistake', () {
      expect(() => server().setValue('nope', 1), throwsArgumentError);
    });
  });

  test('stats: now, then after every request and change', () async {
    final s = server();
    final seen = <FakeServerStats>[];
    final subscription = s.watchStats().listen(seen.add);
    addTearDown(subscription.cancel);

    await s.fetch(request);
    s.setEnabled('new_home_screen', false);
    await pumpEventQueue();

    expect(seen, const [
      FakeServerStats(requests: 0, notModified: 0, failures: 0, version: 7),
      FakeServerStats(requests: 1, notModified: 0, failures: 0, version: 7),
      FakeServerStats(requests: 1, notModified: 0, failures: 0, version: 8),
    ]);
  });

  test('from JSON: the config an app keeps in its assets', () {
    final s = FakeRemoteConfigServer.fromJson({
      'version': 3,
      'flags': [wireFlag('a')],
    });

    expect(s.version, 3);
    expect(s.flags.single['key'], 'a');
    expect(s.latency, const Duration(milliseconds: 600));
  });
}
