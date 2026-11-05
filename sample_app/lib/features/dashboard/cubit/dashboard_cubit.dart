import 'dart:async';

import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/network/device_network.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// The Dashboard: the app's flags as the SDK evaluates them, its cache,
/// and the demo's network switch, each read again whenever it changes.
@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._debug, this._network) : super(_read(_debug)) {
    _subscriptions = [
      _debug.watch().listen(
        (_) => emit(state.copyWith(readings: _debug.readAll())),
      ),
      _debug.watchCache().listen((cache) => emit(state.copyWith(cache: cache))),
      _network.watchStatus().listen(
        (network) => emit(state.copyWith(network: network)),
      ),
    ];
  }

  final FlagsDebug _debug;
  final DeviceNetwork _network;
  late final List<StreamSubscription<Object?>> _subscriptions;

  static DashboardState _read(FlagsDebug debug) =>
      DashboardState(sdkVersion: debug.sdkVersion, readings: debug.readAll());

  /// Fetches the flags now, and tells the screen what came of it. A tap
  /// while one runs does nothing (the button says so).
  Future<void> refresh() async {
    if (state.refreshing) return;
    emit(state.copyWith(refreshing: true));
    final result = await _debug.refresh();
    if (isClosed) return;
    emit(
      state.copyWith(
        refreshing: false,
        lastResult: result,
        refreshCount: state.refreshCount + 1,
      ),
    );
  }

  /// The demo's "Device offline" switch.
  void simulateOffline(bool offline) => _network.simulateOffline(offline);

  // Together, not in turn: one cancel that never completes (a drift
  // stream's, in fake time) mustn't hold up the others (§11.94).
  @override
  Future<void> close() async {
    await Future.wait([for (final s in _subscriptions) s.cancel()]);
    return super.close();
  }
}
