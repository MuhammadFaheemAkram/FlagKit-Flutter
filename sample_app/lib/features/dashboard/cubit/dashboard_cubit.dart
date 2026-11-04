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
    _subscription = _debug.watch().listen((_) => emit(_read(_debug)));
  }

  final FlagsDebug _debug;
  late final StreamSubscription<void> _subscription;

  static DashboardState _read(FlagsDebug debug) =>
      DashboardState(sdkVersion: debug.sdkVersion, readings: debug.readAll());

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
