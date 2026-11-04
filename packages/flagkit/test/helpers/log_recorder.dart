import 'package:flagkit/src/util/flagkit_logger.dart';

/// Captures what the SDK logs, so a test can check a warning or a debug
/// line without reading the console.
final class LogRecorder {
  final List<(LogLevel, String)> lines = [];

  /// A logger that writes here, enabled unless [enabled] says otherwise.
  FlagKitLogger logger({bool enabled = true}) => FlagKitLogger(
    enabled: enabled,
    sink: (level, message, {error, stackTrace}) => lines.add((level, message)),
  );

  /// The messages logged at [level].
  List<String> at(LogLevel level) => [
    for (final (l, message) in lines)
      if (l == level) message,
  ];
}
