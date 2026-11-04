import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/log_recorder.dart';

void main() {
  late LogRecorder logs;
  late FlagKitClientImpl client;

  setUp(() async {
    logs = LogRecorder();
    client = await FlagKitClientImpl.open(
      const FlagKitConfig(apiKey: 'demo_key'),
      logger: logs.logger(),
    );
  });
  tearDown(() => client.shutdown());

  test('create() validates the config first', () {
    expect(
      () => FlagKitClient.create(const FlagKitConfig(apiKey: '')),
      throwsArgumentError,
    );
  });

  test('a flag it doesn\'t know: the caller\'s default, flagNotFound', () {
    expect(client.isEnabled('new_home_screen'), isFalse);
    expect(client.getInt('feed_page_size', 20), 20);
    expect(
      client.detail('feed_page_size'),
      const FlagDetail.fallback(
        'feed_page_size',
        EvaluationReason.flagNotFound,
      ),
    );
  });

  test('an unknown flag is logged once, not on every read', () {
    for (var i = 0; i < 5; i++) {
      client.isEnabled('new_home_screen');
    }
    client.getString('home_theme', 'classic');

    expect(logs.at(LogLevel.debug), [
      '"new_home_screen" is not a known flag: the caller\'s default',
      '"home_theme" is not a known flag: the caller\'s default',
    ]);
  });

  test('the context is kept; setting the same one again is no change', () {
    const context = EvaluationContext(userId: 'user_123', country: 'PK');
    client.setContext(context);
    client.setContext(
      const EvaluationContext(userId: 'user_123', country: 'PK'),
    );

    expect(client.context, context);
    expect(
      logs.at(LogLevel.debug).where((line) => line.startsWith('context:')),
      hasLength(1),
    );
  });

  test('refresh has nothing to fetch from yet, and says so', () async {
    expect(await client.refresh(), isA<Failed>());
  });

  test('after shutdown: defaults with notInitialized; calls ignored', () async {
    final changes = expectLater(client.changes, emitsDone);
    await client.shutdown();
    await changes;

    expect(client.getInt('feed_page_size', 20), 20);
    expect(client.detail('k').reason, EvaluationReason.notInitialized);
    expect(await client.refresh(), const NotInitialized());
    client.setContext(const EvaluationContext(userId: 'x'));
    await client.clearCache();
    expect(client.context, const EvaluationContext());
    expect(logs.at(LogLevel.warning), hasLength(2));
    // A second shutdown is harmless.
    await client.shutdown();
  });
}
