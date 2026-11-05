import 'package:flutter/foundation.dart';

/// How the SDK reaches a remote config server: its network boundary.
///
/// The SDK ships one, `FakeRemoteConfigServer`. A real backend is another
/// implementation (an HTTP `GET` with the key in a header, and
/// `If-None-Match` for [FetchRequest.ifVersion]), passed in
/// `FlagKitConfig.transport`: nothing else in the SDK changes.
abstract interface class RemoteConfigTransport {
  /// Fetches the flags' definitions. Completes with the server's answer,
  /// or throws a [TransportException] saying what went wrong.
  Future<FetchResponse> fetch(FetchRequest request);
}

/// One fetch.
@immutable
final class FetchRequest {
  /// A fetch, built by the SDK.
  const FetchRequest({
    required this.apiKey,
    required this.sdkVersion,
    this.ifVersion,
  });

  /// The app's API key (a header for a real backend).
  final String apiKey;

  /// The SDK's version (`FlagKit.version`), so the server knows which
  /// client asks, and could send it only what it understands.
  final String sdkVersion;

  /// The config version the SDK already has, or `null` with an empty
  /// cache. When it's the server's current one, the server answers
  /// [ConfigNotModified] and sends nothing: a conditional fetch.
  final int? ifVersion;

  @override
  bool operator ==(Object other) =>
      other is FetchRequest &&
      other.apiKey == apiKey &&
      other.sdkVersion == sdkVersion &&
      other.ifVersion == ifVersion;

  @override
  int get hashCode => Object.hash(apiKey, sdkVersion, ifVersion);

  // No key: a request printed in a log mustn't leak it.
  @override
  String toString() => 'FetchRequest(sdk $sdkVersion, ifVersion: $ifVersion)';
}

/// The server's answer to a [FetchRequest].
@immutable
sealed class FetchResponse {
  const FetchResponse();
}

/// The server's config: `{"version": 7, "flags": [...]}`, as decoded JSON.
///
/// The SDK validates it: a malformed body fails the refresh, and an invalid
/// flag is skipped while the rest apply.
final class FetchedConfig extends FetchResponse {
  /// The config the server sent.
  const FetchedConfig(this.json);

  /// The body, decoded.
  final Map<String, Object?> json;
}

/// The config hasn't changed since [FetchRequest.ifVersion].
final class ConfigNotModified extends FetchResponse {
  /// Nothing changed.
  const ConfigNotModified();
}

/// Why a fetch failed. Sealed: the SDK handles each kind, and so can a
/// host's own transport tests.
@immutable
sealed class TransportException implements Exception {
  const TransportException(this.message);

  /// What went wrong, in words (for the log and the refresh log).
  final String message;

  @override
  String toString() => message;
}

/// The server couldn't be reached: no route, DNS, a timeout.
final class ServerUnreachable extends TransportException {
  /// The server couldn't be reached.
  const ServerUnreachable() : super('server unreachable');
}

/// The server answered with an error (5xx).
final class ServerFailure extends TransportException {
  /// The server answered [statusCode].
  const ServerFailure(this.statusCode) : super('server error $statusCode');

  /// The HTTP status.
  final int statusCode;
}

/// The server rejected the API key (401). Automatic refreshes pause until
/// the next `initialize`: every one would be rejected the same way.
final class ApiKeyRejected extends TransportException {
  /// The key was rejected.
  const ApiKeyRejected() : super('the API key was rejected');
}
