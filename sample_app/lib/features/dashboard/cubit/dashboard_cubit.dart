import 'dart:async';

import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// The Dashboard: the app's flags as the SDK evaluates them, read again
/// whenever one changes.
@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._debug) : super(_read(_debug)) {
    _subscriptions = [
      _debug.watch().listen(
        (_) => emit(state.copyWith(readings: _debug.readAll())),
      ),
      _debug.watchCache().listen((cache) => emit(state.copyWith(cache: cache))),
    ];
  }

  final FlagsDebug _debug;
  late final List<StreamSubscription<Object?>> _subscriptions;

  static DashboardState _read(FlagsDebug debug) =>
      DashboardState(sdkVersion: debug.sdkVersion, readings: debug.readAll());

  // Together, not in turn: one cancel that never completes (a drift
  // stream's, in fake time) mustn't hold up the others (§11.94).
  @override
  Future<void> close() async {
    await Future.wait([for (final s in _subscriptions) s.cancel()]);
    return super.close();
  }
}
