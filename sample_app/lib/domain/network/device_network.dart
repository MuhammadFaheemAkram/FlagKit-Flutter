import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_network.freezed.dart';

/// The device's network as the Dashboard shows it.
@freezed
abstract class NetworkStatus with _$NetworkStatus {
  const factory NetworkStatus({
    /// Whether the device has a connection.
    required bool deviceOnline,

    /// Whether the demo switch says "offline" anyway.
    @Default(false) bool simulatingOffline,
  }) = _NetworkStatus;

  const NetworkStatus._();

  /// What the SDK sees: online only with a connection and no simulation.
  bool get online => deviceOnline && !simulatingOffline;
}

/// The demo's network switch: "Device offline" makes the SDK behave as if
/// there were no connection, to show refreshes held back and the reconnect.
abstract interface class DeviceNetwork {
  /// The status now, then after every change.
  Stream<NetworkStatus> watchStatus();

  void simulateOffline(bool offline);
}
