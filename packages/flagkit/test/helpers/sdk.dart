import 'package:clock/clock.dart';
import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:flagkit/src/repository/flag_repository.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';

import 'log_recorder.dart';

/// The tests' "now": a Wednesday morning, UTC.
final testNow = DateTime.utc(2026, 11, 4, 9, 41);

/// Ids a test can predict: `id-1`, `id-2`, …
final class SequentialIds {
  var _next = 1;

  String call() => 'id-${_next++}';
}

/// A config for tests: the defaults, with a key.
const testConfig = FlagKitConfig(apiKey: 'demo_key');

/// A definition with sensible defaults: a boolean flag, on.
FlagDefinition definition(
  String key, {
  FlagValue value = const BoolValue(true),
  FlagValue? offValue,
  bool enabled = true,
  DateTime? updatedAt,
}) => FlagDefinition(
  key: key,
  value: value,
  offValue: offValue ?? _offFor(value),
  enabled: enabled,
  updatedAt: updatedAt ?? testNow,
);

FlagValue _offFor(FlagValue value) => switch (value) {
  BoolValue() => const BoolValue(false),
  StringValue() => const StringValue('off'),
  IntValue() => const IntValue(0),
  DoubleValue() => const DoubleValue(0),
  JsonValue() => JsonValue(const {}),
};

/// Stores [definitions] in [database], as if a refresh had fetched them at
/// [fetchedAt]: what a later start finds in the cache.
Future<void> seedCache(
  FlagKitDatabase database,
  List<FlagDefinition> definitions, {
  DateTime? fetchedAt,
  int configVersion = 1,
}) async {
  final repository = await FlagRepository.open(
    database,
    logger: FlagKitLogger.silent(),
    newId: SequentialIds().call,
  );
  await repository.replace(
    definitions: definitions,
    configVersion: configVersion,
    fetchedAt: fetchedAt ?? testNow,
  );
}

/// A client on [database] (a fresh one in memory by default), at [now].
Future<FlagKitClientImpl> openTestClient({
  FlagKitDatabase? database,
  FlagKitConfig config = testConfig,
  LogRecorder? logs,
  DateTime Function()? now,
}) => FlagKitClientImpl.open(
  config,
  database: database ?? FlagKitDatabase.inMemory(),
  logger: (logs ?? LogRecorder()).logger(),
  clock: Clock(now ?? () => testNow),
  newId: SequentialIds().call,
);
