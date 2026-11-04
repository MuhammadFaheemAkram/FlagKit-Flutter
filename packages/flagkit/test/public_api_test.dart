import 'dart:io';

// The only imports an app has (the second in its tests). Nothing from lib/src/ here: this file sees
// the SDK exactly as a host does.
import 'package:flagkit/flagkit.dart';
import 'package:flagkit/testing.dart';
import 'package:flutter_test/flutter_test.dart';

// The public API is a promise: a name in it can't change or go without a
// new major version. This file makes the promise visible. It uses every
// exported name (so removing or renaming one fails to compile), switches
// over the sealed and enum types with no default (so adding a case fails
// to compile too), and lists the exports (so adding a name is a reviewed
// change to this test).
void main() {
  for (final (path, names) in [
    ('lib/flagkit.dart', _exported),
    ('lib/testing.dart', _testing),
  ]) {
    test('$path exports exactly these names', () {
      final library = File(path).readAsStringSync();
      final shown = RegExp(r'show\s+([^;]+);')
          .allMatches(library)
          .expand((match) => match.group(1)!.split(','))
          .map((name) => name.trim())
          .toList();

      expect(shown, unorderedEquals(names));
      expect(shown, hasLength(names.length), reason: 'no name twice');
      expect(
        RegExp(r'^export ', multiLine: true).allMatches(library).length,
        RegExp(r'show\s').allMatches(library).length,
        reason: 'every export has a show list: nothing leaks by accident',
      );
    });
  }

  test('lib/ has only the two libraries', () {
    final libraries = Directory('lib')
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last);

    expect(libraries, unorderedEquals(['flagkit.dart', 'testing.dart']));
  });

  test('every name is usable from a host', () async {
    FlagKitTesting.useInMemoryDatabase();
    addTearDown(FlagKitTesting.useDeviceDatabase);
    const config = FlagKitConfig(
      apiKey: 'demo_key',
      refreshInterval: Duration(minutes: 5),
      cacheExpiration: Duration(hours: 1),
      startupWait: Duration(seconds: 1),
    );
    await FlagKit.initialize(config);
    addTearDown(FlagKit.shutdown);

    final FlagKitClient client = FlagKit.instance;
    FlagKit.setContext(
      const EvaluationContext(
        userId: 'user_123',
        country: 'PK',
        appVersion: '2.1.0',
        attributes: {'plan': 'pro'},
      ),
    );
    expect(FlagKit.context.userId, 'user_123');
    expect(FlagKit.isEnabled('new_home_screen'), isFalse);
    expect(FlagKit.getString('home_theme', 'classic'), 'classic');
    expect(FlagKit.getInt('feed_page_size', 20), 20);
    expect(FlagKit.getDouble('discount_percentage', 0), 0);
    expect(FlagKit.getJson('home_config', const {}), isEmpty);
    expect(client.getValue('home_config'), isNull);
    final FlagDetail detail = FlagKit.detail('new_checkout');
    expect(describeSource(detail.source), isNotEmpty);
    expect(describeReason(detail.reason), isNotEmpty);
    final Stream<Set<String>> changes = FlagKit.changes;
    expect(changes.isBroadcast, isTrue);
    expect(describe(await FlagKit.refresh()), isNotEmpty);
    await FlagKit.clearCache();
    final FlagKitDebug debug = FlagKit.debug;
    final FlagKitStats stats = await debug.watchStats().first;
    expect(describeStatus(stats.cacheStatus), isNotEmpty);
    expect(stats.flagCount, 0);
    expect(stats.anonymousId, isNotEmpty);
    expect(FlagKit.version, matches(RegExp(r'^\d+\.\d+\.\d+$')));

    for (final value in <FlagValue>[
      const BoolValue(true),
      const StringValue('modern'),
      const IntValue(30),
      const DoubleValue(15.5),
      JsonValue(const {'banner': 'Sale'}),
    ]) {
      expect(read(value), isNotEmpty);
      expect(describeType(value.type), isNotEmpty);
    }
  });

  test('every RefreshResult has a meaning', () {
    for (final result in const <RefreshResult>[
      Updated(added: {'a'}, changed: {'b'}, removed: {'c'}, skipped: 1),
      NotModified(),
      Offline(),
      Failed(reason: 'server error 503'),
      Unauthorized(),
      NotInitialized(),
    ]) {
      expect(describe(result), isNotEmpty);
    }
  });
}

const _exported = [
  'FlagKit',
  'FlagKitDebug',
  'FlagKitStats',
  'CacheStatus',
  'FlagKitClient',
  'FlagKitConfig',
  'EvaluationContext',
  'EvaluationReason',
  'FlagDetail',
  'FlagSource',
  'FlagType',
  'FlagValue',
  'BoolValue',
  'StringValue',
  'IntValue',
  'DoubleValue',
  'JsonValue',
  'RefreshResult',
  'Updated',
  'NotModified',
  'Offline',
  'Failed',
  'Unauthorized',
  'NotInitialized',
];

const _testing = ['FlagKitTesting'];

// What a host might show for each. Exhaustive with no default: a new case
// is a compile error here, as it would be in every such app.

String describe(RefreshResult result) => switch (result) {
  Updated(:final added, :final changed, :final removed, :final skipped) =>
    '${added.length} new, ${changed.length} changed, ${removed.length} '
        'removed, $skipped skipped',
  NotModified() => 'Up to date',
  Offline() => 'Offline',
  Failed(:final reason) => 'Failed: $reason',
  Unauthorized() => 'Check the API key',
  NotInitialized() => 'Not running',
};

String read(FlagValue value) => switch (value) {
  BoolValue(:final value) => value ? 'on' : 'off',
  StringValue(:final value) => value,
  IntValue(:final value) => '$value',
  DoubleValue(:final value) => '$value',
  JsonValue(:final value) => '${value.length} keys',
};

String describeSource(FlagSource source) => switch (source) {
  FlagSource.override => 'overridden here',
  FlagSource.remote => 'from the server',
  FlagSource.cache => 'from the cache',
  FlagSource.defaultValue => 'the app\'s default',
};

String describeType(FlagType type) => switch (type) {
  FlagType.boolean => 'on/off',
  FlagType.string => 'text',
  FlagType.integer => 'whole number',
  FlagType.decimal => 'number',
  FlagType.json => 'JSON',
};

String describeReason(EvaluationReason reason) => switch (reason) {
  EvaluationReason.override => 'a local override',
  EvaluationReason.off => 'switched off',
  EvaluationReason.targetingMatch => 'the rules matched',
  EvaluationReason.targetingMiss => 'the rules didn\'t match',
  EvaluationReason.rolloutIncluded => 'in the rollout',
  EvaluationReason.rolloutExcluded => 'outside the rollout',
  EvaluationReason.fallthrough => 'on for everyone',
  EvaluationReason.notInitialized => 'not running',
  EvaluationReason.flagNotFound => 'unknown flag',
  EvaluationReason.typeMismatch => 'wrong type',
};

String describeStatus(CacheStatus status) => switch (status) {
  CacheStatus.fresh => 'up to date',
  CacheStatus.stale => 'due for a refresh',
  CacheStatus.expired => 'old, refreshing',
  CacheStatus.empty => 'nothing cached',
};
