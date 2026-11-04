import 'package:flagkit/flagkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the defaults: an hour fresh, a day to expire, no startup wait', () {
    const config = FlagKitConfig(apiKey: 'demo_key');

    expect(config.refreshInterval, const Duration(hours: 1));
    expect(config.cacheExpiration, const Duration(hours: 24));
    expect(config.startupWait, Duration.zero);
    expect(config.debugMode, isFalse);
    expect(config.problems, isEmpty);
  });

  group('every rule, just inside and just outside', () {
    for (final (name, config, valid) in [
      ('a key', const FlagKitConfig(apiKey: 'k'), true),
      ('a blank key', const FlagKitConfig(apiKey: '  '), false),
      (
        'a refresh every minute',
        const FlagKitConfig(apiKey: 'k', refreshInterval: Duration(minutes: 1)),
        true,
      ),
      (
        'a refresh more often than every minute',
        const FlagKitConfig(
          apiKey: 'k',
          refreshInterval: Duration(seconds: 59),
        ),
        false,
      ),
      (
        'expiry exactly at the refresh interval',
        const FlagKitConfig(
          apiKey: 'k',
          refreshInterval: Duration(hours: 2),
          cacheExpiration: Duration(hours: 2),
        ),
        true,
      ),
      (
        'expiry before the refresh interval',
        const FlagKitConfig(
          apiKey: 'k',
          refreshInterval: Duration(hours: 2),
          cacheExpiration: Duration(minutes: 119),
        ),
        false,
      ),
      (
        'a 10-second startup wait',
        const FlagKitConfig(apiKey: 'k', startupWait: Duration(seconds: 10)),
        true,
      ),
      (
        'a longer startup wait',
        const FlagKitConfig(
          apiKey: 'k',
          startupWait: Duration(seconds: 10, milliseconds: 1),
        ),
        false,
      ),
      (
        'a negative startup wait',
        const FlagKitConfig(apiKey: 'k', startupWait: Duration(seconds: -1)),
        false,
      ),
    ]) {
      test('$name: ${valid ? 'valid' : 'refused'}', () {
        expect(config.problems, valid ? isEmpty : hasLength(1));
      });
    }
  });

  test('validate() names every broken rule in one error', () {
    const config = FlagKitConfig(
      apiKey: '',
      refreshInterval: Duration(seconds: 1),
      startupWait: Duration(minutes: 1),
    );

    expect(
      config.validate,
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('apiKey'),
            contains('refreshInterval'),
            contains('startupWait'),
          ),
        ),
      ),
    );
  });

  test('toString masks the key: a log must not leak it', () {
    expect(
      const FlagKitConfig(apiKey: 'live_secret_key').toString(),
      allOf(contains('live****'), isNot(contains('secret'))),
    );
    expect(const FlagKitConfig(apiKey: 'abc').toString(), contains('****'));
  });

  test('two configs with the same values are equal', () {
    expect(
      const FlagKitConfig(apiKey: 'k', debugMode: true),
      const FlagKitConfig(apiKey: 'k', debugMode: true),
    );
    expect(
      const FlagKitConfig(apiKey: 'k').hashCode,
      const FlagKitConfig(apiKey: 'k').hashCode,
    );
    expect(
      const FlagKitConfig(apiKey: 'k'),
      isNot(
        const FlagKitConfig(apiKey: 'k', startupWait: Duration(seconds: 1)),
      ),
    );
  });
}
