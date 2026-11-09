import 'package:flagkit/flagkit.dart';
import 'package:flagkit/testing.dart';
import 'package:flagkit_sample/app/sample_flagkit_config.dart';
import 'package:flagkit_sample/app/theme_cubit.dart';
import 'package:flagkit_sample/data/context/flagkit_user_context.dart';
import 'package:flagkit_sample/data/demo/fake_server_demo.dart';
import 'package:flagkit_sample/data/flags/flagkit_app_flags.dart';
import 'package:flagkit_sample/data/flags/flagkit_flags_debug.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/demo/demo_server.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/features/checkout/cubit/checkout_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/flag_detail_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/server_console_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/try_user_cubit.dart';
import 'package:flagkit_sample/features/home/cubit/home_cubit.dart';
import 'package:flagkit_sample/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';

void main() {
  // The demo server reads its flags from an asset.
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(tearDownSample);

  test('the graph builds once the SDK has started, as in main()', () async {
    await startSample();

    expect(getIt<FlagKitClient>(), same(FlagKit.instance));
    expect(getIt<AppFlags>(), isA<FlagKitAppFlags>());
    expect(getIt<UserContext>(), isA<FlagKitUserContext>());
    expect(getIt<FlagsDebug>(), isA<FlagKitFlagsDebug>());
    expect(getIt<HomeCubit>(), isNot(same(getIt<HomeCubit>())));
    expect(getIt<CheckoutCubit>(), isA<CheckoutCubit>());
    expect(getIt<ProfileCubit>(), isA<ProfileCubit>());
    expect(getIt<DashboardCubit>(), isA<DashboardCubit>());
    expect(getIt<DemoServer>(), isA<FakeServerDemo>());
    expect(getIt<TryUserCubit>(), isA<TryUserCubit>());
    expect(getIt<ServerConsoleCubit>(), isA<ServerConsoleCubit>());
    expect(
      getIt<FlagDetailCubit>(param1: 'new_checkout').state.key,
      'new_checkout',
    );
    expect(getIt<ThemeCubit>(), isA<ThemeCubit>());
  });

  test('the bootstrap gives the SDK the starting user', () async {
    await startSample();

    expect(FlagKit.context, const EvaluationContext(appVersion: '2.1.0'));
  });

  test('the sample configures the SDK with a valid config', () {
    final server = FakeRemoteConfigServer();
    final monitor = FakeNetworkMonitor();
    final config = sampleFlagKitConfig(
      transport: server,
      networkMonitor: monitor,
    );

    expect(config.problems, isEmpty);
    expect(config.apiKey, 'demo_key');
    expect(config.refreshInterval, const Duration(minutes: 1));
    expect(config.startupWait, const Duration(seconds: 2));
    // The demo's server (for its controls) and the demo's monitor (with
    // the offline switch).
    expect(config.transport, same(server));
    expect(config.networkMonitor, same(monitor));
  });
}
