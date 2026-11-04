import 'package:flagkit_sample/domain/debug/flags_debug.dart';
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
  }) = _DashboardState;
}
