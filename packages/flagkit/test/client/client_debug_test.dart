import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';

import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/evaluation/rollout.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/sdk.dart';

// The debug tools on a real client: overrides, every flag, another user,
// the stats.
void main() {
  late FlagKitDatabase db;
  late FlagKitClientImpl client;
  late FakeNetworkMonitor network;
  late ScriptedTransport transport;

  final inPakistan = TargetingRule(
    attribute: 'country',
    operator: TargetingOperator.isIn,
    values: const ['PK'],
  );

  setUp(() async {
    db = FlagKitDatabase.inMemory();
    network = FakeNetworkMonitor(online: false);
    transport = ScriptedTransport();
    await seedCache(db, [
      definition(
        'home_theme',
        value: const StringValue('modern'),
        offValue: const StringValue('classic'),
        rules: [inPakistan],
      ),
      definition('new_checkout', rolloutBasisPoints: 2500),
      definition('feed_page_size', value: const IntValue(30)),
    ]);
    client = await openTestClient(
      database: db,
      config: testConfig(transport: transport, monitor: network),
    );
  });
  tearDown(() => client.shutdown());

  FlagKitDebug debug() => client.debug;

  group('overrides', () {
    test('win over the definition: source and reason override', () async {
      final changes = <Set<String>>[];
      final subscription = client.changes.listen(changes.add);
      addTearDown(subscription.cancel);

      await debug().setOverride('feed_page_size', const IntValue(5));
      await pumpEventQueue();

      expect(client.getInt('feed_page_size', 20), 5);
      expect(
        client.detail('feed_page_size'),
        const FlagDetail(
          key: 'feed_page_size',
          value: IntValue(5),
          source: FlagSource.override,
          reason: EvaluationReason.override,
        ),
      );
      expect(changes, [
        {'feed_page_size'},
      ]);
    });

    test('win over the kill switch, the rules and the rollout', () async {
      await debug().setOverride('home_theme', const StringValue('ocean'));
      await debug().setOverride('new_checkout', const BoolValue(true));

      for (final context in [
        const EvaluationContext(country: 'GB'),
        const EvaluationContext(userId: 'anyone'),
      ]) {
        client.setContext(context);
        expect(client.getString('home_theme', 'x'), 'ocean');
        expect(client.isEnabled('new_checkout'), isTrue);
      }
    });

    test('a flag the server doesn\'t send can be overridden', () async {
      await debug().setOverride('beta_banner', const BoolValue(true));

      expect(client.isEnabled('beta_banner'), isTrue);
      expect(
        (await debug().watchFlags().first).map((d) => d.key),
        contains('beta_banner'),
      );
    });

    test('a read of another type still gets the caller\'s default', () async {
      await debug().setOverride('beta', const StringValue('yes'));

      expect(client.isEnabled('beta', true), isTrue);
      expect(client.detail('beta').source, FlagSource.override);
      expect(
        client.evaluate('beta', FlagType.boolean).reason,
        EvaluationReason.typeMismatch,
      );
    });

    test('a bad key or another type than the flag\'s is a mistake', () {
      expect(
        () => debug().setOverride('Not A Key', const BoolValue(true)),
        throwsArgumentError,
      );
      expect(
        () => debug().setOverride('feed_page_size', const StringValue('5')),
        throwsArgumentError,
      );
      expect(client.getInt('feed_page_size', 20), 30);
    });

    test('cleared one at a time, or all; changes says which', () async {
      await debug().setOverride('feed_page_size', const IntValue(5));
      await debug().setOverride('beta', const BoolValue(true));
      final changes = <Set<String>>[];
      final subscription = client.changes.listen(changes.add);
      addTearDown(subscription.cancel);

      await debug().clearOverride('feed_page_size');
      await debug().clearOverride('feed_page_size');
      await debug().clearOverrides();
      await debug().clearOverrides();
      await pumpEventQueue();

      expect(client.getInt('feed_page_size', 20), 30);
      expect(client.detail('beta').reason, EvaluationReason.flagNotFound);
      expect(changes, [
        {'feed_page_size'},
        {'beta'},
      ]);
    });

    test('an override equal to the value changes no value', () async {
      final changes = <Set<String>>[];
      final subscription = client.changes.listen(changes.add);
      addTearDown(subscription.cancel);

      await debug().setOverride('feed_page_size', const IntValue(30));
      await pumpEventQueue();

      expect(changes, isEmpty);
      expect(client.detail('feed_page_size').source, FlagSource.override);
    });

    test('are kept by clearCache, and across a restart', () async {
      final dir = await Directory.systemTemp.createTemp('flagkit');
      addTearDown(() => dir.delete(recursive: true));
      FlagKitDatabase file() =>
          FlagKitDatabase(NativeDatabase(File('${dir.path}/flagkit.sqlite')));
      final first = await openTestClient(
        database: file(),
        config: testConfig(monitor: network),
      );
      await first.debug.setOverride('feed_page_size', const IntValue(5));
      await first.clearCache();
      expect(first.getInt('feed_page_size', 20), 5);
      await first.shutdown();

      final second = await openTestClient(
        database: file(),
        config: testConfig(monitor: network),
      );
      addTearDown(second.shutdown);
      expect(second.getInt('feed_page_size', 20), 5);
      expect(second.detail('feed_page_size').source, FlagSource.override);
    });

    test('after shutdown: ignored', () async {
      await client.shutdown();
      await debug().setOverride('feed_page_size', const IntValue(5));
      await debug().clearOverrides();
    });
  });

  group('watchFlags', () {
    test('every flag for the current context, in order', () async {
      final flags = await debug().watchFlags().first;

      expect(flags.map((d) => d.key), [
        'feed_page_size',
        'home_theme',
        'new_checkout',
      ]);
      expect(flags[1].reason, EvaluationReason.targetingMiss);
    });

    test('again on a context change, even with no value changed', () async {
      final seen = <List<FlagDetail>>[];
      final subscription = debug().watchFlags().listen(seen.add);
      addTearDown(subscription.cancel);
      // Two users on the same side of new_checkout's rollout: no value
      // changes, but the bucket does.
      final units = [for (var i = 0; i < 100; i++) 'user_$i'];
      final [first, second, ...] = units
          .where((u) => bucketOf('new_checkout', u) >= 2500)
          .toList();
      client.setContext(EvaluationContext(userId: first));
      await pumpEventQueue();
      final changes = <Set<String>>[];
      final watching = client.changes.listen(changes.add);
      addTearDown(watching.cancel);

      client.setContext(EvaluationContext(userId: second));
      await pumpEventQueue();

      expect(changes, isEmpty);
      expect(seen.last[2].bucket, bucketOf('new_checkout', second));
      expect(seen, hasLength(3));
    });

    test('again after an override and a refresh', () async {
      final seen = <List<FlagDetail>>[];
      final subscription = debug().watchFlags().listen(seen.add);
      addTearDown(subscription.cancel);

      await debug().setOverride('feed_page_size', const IntValue(5));
      network.online = true;
      transport.config = wireConfig([wireFlag('only_one')]);
      await client.refresh();
      await pumpEventQueue();

      expect(seen.last.map((d) => d.key), ['feed_page_size', 'only_one']);
      expect(seen.last.first.source, FlagSource.override);
    });
  });

  group('definitions, evaluateFor and explain', () {
    test('definitions: the server\'s, in the public view', () {
      final theme = debug().definitions[1];

      expect(theme.key, 'home_theme');
      expect(theme.type, FlagType.string);
      expect(theme.value, const StringValue('modern'));
      expect(theme.offValue, const StringValue('classic'));
      expect(theme.enabled, isTrue);
      expect(theme.rules, [inPakistan]);
      expect(theme.rolloutPercent, isNull);
      expect(debug().definitions[2].rolloutPercent, 25);
    });

    test('evaluateFor: another user, the context unchanged', () {
      const user = EvaluationContext(userId: 'maya', country: 'PK');

      expect(
        debug().evaluateFor('home_theme', user).reason,
        EvaluationReason.targetingMatch,
      );
      expect(
        debug().evaluateFor('new_checkout', user).bucket,
        bucketOf('new_checkout', 'maya'),
      );
      expect(client.context, const EvaluationContext());
      expect(
        client.detail('home_theme').reason,
        EvaluationReason.targetingMiss,
      );
    });

    test('evaluateFor is not counted as the app\'s reads', () async {
      debug().evaluateFor('home_theme', const EvaluationContext());
      client.getString('home_theme', 'x');

      network.online = true;
      network.online = false;
      final stats = await debug().watchStats().first;
      expect(stats.evaluations, {FlagSource.cache: 1});
    });

    test('explain: the detail, the definition, each rule', () async {
      final explanation = debug().explain(
        'home_theme',
        context: const EvaluationContext(country: 'GB'),
      );

      expect(explanation.detail.reason, EvaluationReason.targetingMiss);
      expect(explanation.context, const EvaluationContext(country: 'GB'));
      expect(explanation.flag, debug().definitions[1]);
      expect(explanation.overrideValue, isNull);
      expect(explanation.rules, [RuleMatch(inPakistan, matched: false)]);

      client.setContext(const EvaluationContext(country: 'PK'));
      await debug().setOverride('home_theme', const StringValue('ocean'));
      final now = debug().explain('home_theme');
      expect(now.rules.single.matched, isTrue);
      expect(now.overrideValue, const StringValue('ocean'));
      expect(now.detail.source, FlagSource.override);
    });

    test('explain: an unknown flag has nothing behind it', () {
      final explanation = debug().explain('nope');

      expect(explanation.flag, isNull);
      expect(explanation.rules, isEmpty);
      expect(explanation.detail.reason, EvaluationReason.flagNotFound);
    });
  });

  group('watchStats', () {
    test('overrides, online, and the app\'s reads by source', () async {
      client
        ..getInt('feed_page_size', 20)
        ..getInt('feed_page_size', 20)
        ..isEnabled('unknown');
      await debug().setOverride('beta', const BoolValue(true));
      client.isEnabled('beta');

      final stats = await debug().watchStats().first;
      expect(stats.overrideCount, 1);
      expect(stats.online, isFalse);
      expect(stats.refreshing, isFalse);
      expect(stats.evaluations, {
        FlagSource.cache: 2,
        FlagSource.defaultValue: 1,
        FlagSource.override: 1,
      });
    });

    test('a refresh: refreshing while it runs, then counted', () async {
      network.online = true;
      final gate = transport.gate = Completer<void>();
      final seen = <FlagKitStats>[];
      final subscription = debug().watchStats().listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      final refreshing = client.refresh();
      await pumpEventQueue();
      expect(seen.last.refreshing, isTrue);

      gate.complete();
      await refreshing;
      await pumpEventQueue();
      expect(seen.last.refreshing, isFalse);
      expect(seen.last.refreshCount, 1);
      expect(seen.last.failedRefreshCount, 0);
      expect(seen.map((s) => s.online), contains(true));
    });

    test('failures and skipped definitions are counted, ever', () async {
      network.online = true;
      transport.config = wireConfig([wireFlag('a'), wireFlag('B')]);
      await client.refresh();
      transport.then(const ServerUnreachable());
      await client.refresh();

      final stats = await debug().watchStats().first;
      expect(stats.refreshCount, 2);
      expect(stats.failedRefreshCount, 1);
      expect(stats.skippedCount, 1);
    });

    test('the network going up or down is a new event', () async {
      final seen = <FlagKitStats>[];
      final subscription = debug().watchStats().listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();
      expect(seen.single.online, isFalse);

      network.online = true;
      await pumpEventQueue();

      expect(seen.map((s) => s.online), [false, true]);
    });

    test('a tick that changes nothing the stats show: no new event', () async {
      final seen = <FlagKitStats>[];
      final subscription = debug().watchStats().listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      client
        ..setContext(const EvaluationContext(country: 'PK'))
        ..setContext(const EvaluationContext(country: 'GB'));
      await pumpEventQueue();

      expect(seen, hasLength(1));
    });
  });
}
