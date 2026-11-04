import 'dart:async';

import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// The app's look, from the `home_theme` flag: above the router, so a
/// refresh or a context change that flips the flag restyles every screen.
@injectable
class ThemeCubit extends Cubit<AppThemeChoice> {
  ThemeCubit(this._flags) : super(_flags.homeTheme) {
    _subscription = _flags.watch().listen((_) => emit(_flags.homeTheme));
  }

  final AppFlags _flags;
  late final StreamSubscription<void> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

/// The design system's spec for each of the app's looks.
AppThemeSpec themeSpecOf(AppThemeChoice choice) => switch (choice) {
  AppThemeChoice.classic => AppThemeSpec.classic,
  AppThemeChoice.modern => AppThemeSpec.modern,
  AppThemeChoice.ocean => AppThemeSpec.ocean,
};
