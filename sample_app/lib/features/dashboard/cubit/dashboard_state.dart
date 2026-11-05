import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/network/device_network.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_state.freezed.dart';

/// What the Dashboard shows.
@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required String sdkVersion,
    required List<FlagReading> readings,

    /// The SDK's cache, once it has answered (a moment after the screen
    /// opens: it is a database query).
    CacheInfo? cache,

    /// The device's network and the demo switch, once known.
    NetworkStatus? network,

    /// Whether a refresh asked from here is running.
    @Default(false) bool refreshing,

    /// The latest refresh asked from here, and how many there were: a new
    /// one shows its result once.
    RefreshSummary? lastResult,
    @Default(0) int refreshCount,
  }) = _DashboardState;
}
