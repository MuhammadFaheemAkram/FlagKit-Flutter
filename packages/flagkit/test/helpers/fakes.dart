import 'dart:async';

import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/scheduling/app_lifecycle.dart';

/// An app lifecycle a test moves between foreground and background.
final class FakeAppLifecycle implements AppLifecycle {
  bool _foreground = true;
  final _changes = StreamController<bool>.broadcast();
  bool disposed = false;

  @override
  bool get isForeground => _foreground;

  set foreground(bool value) {
    if (value == _foreground) return;
    _foreground = value;
    _changes.add(value);
  }

  @override
  Stream<bool> watchForeground() => _changes.stream;

  @override
  void dispose() {
    disposed = true;
    unawaited(_changes.close());
  }
}

/// A transport that answers each fetch with the next scripted outcome (a
/// [FetchResponse], or an exception to throw), and remembers every request.
/// Past the script, it answers with [config].
final class ScriptedTransport implements RemoteConfigTransport {
  ScriptedTransport([List<Object> script = const []])
    : _script = List.of(script);

  final List<Object> _script;
  final List<FetchRequest> requests = [];

  /// What a fetch past the script returns.
  Map<String, Object?> config = const {'version': 1, 'flags': <Object?>[]};

  /// Holds each fetch until the test completes it (to see a refresh in
  /// flight).
  Completer<void>? gate;

  void then(Object outcome) => _script.add(outcome);

  @override
  Future<FetchResponse> fetch(FetchRequest request) async {
    requests.add(request);
    if (gate case final gate?) await gate.future;
    if (_script.isNotEmpty) {
      final outcome = _script.removeAt(0);
      if (outcome is FetchResponse) return outcome;
      throw outcome;
    }
    return FetchedConfig(config);
  }
}

/// A flag in the wire format.
Map<String, Object?> wireFlag(
  String key, {
  String type = 'boolean',
  Object? value = true,
  Object? offValue = false,
  bool? enabled,
}) => {
  'key': key,
  'type': type,
  'value': value,
  'offValue': offValue,
  'enabled': ?enabled,
};

/// A config in the wire format.
Map<String, Object?> wireConfig(
  List<Map<String, Object?>> flags, {
  int version = 1,
}) => {'version': version, 'flags': flags};
