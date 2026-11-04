import 'package:flagkit_sample/app/theme_cubit.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/core/navigation/app_router.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: the flag-driven theme and the router.
///
/// This `State` owns the router and disposes it. The router is created once,
/// not in `build`: a new router on every rebuild would reset navigation.
/// The brightness follows the system; the look follows `home_theme`.
class FlagKitSampleApp extends StatefulWidget {
  const FlagKitSampleApp({super.key, this.initialLocation});

  /// Lets tests start on a deep link. The app itself starts on Home.
  final String? initialLocation;

  @override
  State<FlagKitSampleApp> createState() => _FlagKitSampleAppState();
}

class _FlagKitSampleAppState extends State<FlagKitSampleApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, AppThemeChoice>(
        builder: (context, choice) {
          final spec = themeSpecOf(choice);
          return MaterialApp.router(
            title: 'FlagKit',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(spec, Brightness.light),
            darkTheme: AppTheme.build(spec, Brightness.dark),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
