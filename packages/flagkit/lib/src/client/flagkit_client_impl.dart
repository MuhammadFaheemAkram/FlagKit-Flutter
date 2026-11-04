import 'dart:async';

import 'package:flagkit/src/client/flagkit_client.dart';
import 'package:flagkit/src/config/flagkit_config.dart';
import 'package:flagkit/src/evaluation/typed_reads.dart';
import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/evaluation_reason.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/refresh_result.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:meta/meta.dart';

/// The client behind the interface.
///
/// In this version it knows no flags yet: they arrive from the device's
/// cache (0.2.0) and the server (0.3.0). Every read already takes the path
/// it always will (evaluate, then the caller's default when there is no
/// value), so the public API is final from the start.
@internal
final class FlagKitClientImpl with TypedReads implements FlagKitClient {
  FlagKitClientImpl._(this.config, this.logger);

  /// Opens a client for [config] (already validated). [logger] is for
  /// tests.
  static Future<FlagKitClientImpl> open(
    FlagKitConfig config, {
    FlagKitLogger? logger,
  }) async => FlagKitClientImpl._(
    config,
    logger ?? FlagKitLogger(enabled: config.debugMode),
  );

  final FlagKitConfig config;
  final FlagKitLogger logger;

  EvaluationContext _context = const EvaluationContext();
  final _changes = StreamController<Set<String>>.broadcast();
  bool _closed = false;

  // A screen reads its flags on every build: one log line per unknown key
  // per session, not one per frame.
  final _reportedUnknown = <String>{};

  @override
  FlagDetail evaluate(String key, FlagType? requested) {
    if (_closed) {
      return FlagDetail.fallback(key, EvaluationReason.notInitialized);
    }
    if (_reportedUnknown.add(key)) {
      logger.debug('"$key" is not a known flag: the caller\'s default');
    }
    return FlagDetail.fallback(key, EvaluationReason.flagNotFound);
  }

  @override
  EvaluationContext get context => _context;

  @override
  void setContext(EvaluationContext context) {
    if (_closed) {
      logger.warning('setContext() after shutdown: ignored');
      return;
    }
    if (context == _context) return;
    _context = context;
    logger.debug('context: $context');
    // Every flag re-evaluates for the new context; with no flags known yet,
    // no value changes, so there is nothing to report.
  }

  @override
  Stream<Set<String>> get changes => _changes.stream;

  @override
  Future<RefreshResult> refresh() async {
    if (_closed) return const NotInitialized();
    logger.debug('refresh(): no remote config in this version (0.3.0)');
    return const Failed(reason: 'no remote config in this version');
  }

  @override
  Future<void> clearCache() async {
    if (_closed) {
      logger.warning('clearCache() after shutdown: ignored');
      return;
    }
    logger.debug('clearCache(): nothing cached in this version (0.2.0)');
  }

  @override
  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    await _changes.close();
    logger.debug('shut down');
  }
}
