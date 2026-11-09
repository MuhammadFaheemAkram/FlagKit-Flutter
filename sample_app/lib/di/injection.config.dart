// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flagkit/flagkit.dart' as _i110;
import 'package:flagkit_sample/app/theme_cubit.dart' as _i973;
import 'package:flagkit_sample/data/context/flagkit_user_context.dart' as _i686;
import 'package:flagkit_sample/data/demo/fake_server_demo.dart' as _i944;
import 'package:flagkit_sample/data/flags/flagkit_app_flags.dart' as _i1022;
import 'package:flagkit_sample/data/flags/flagkit_flags_debug.dart' as _i469;
import 'package:flagkit_sample/data/network/demo_network_monitor.dart' as _i136;
import 'package:flagkit_sample/di/app_module.dart' as _i963;
import 'package:flagkit_sample/domain/context/user_context.dart' as _i193;
import 'package:flagkit_sample/domain/debug/flags_debug.dart' as _i760;
import 'package:flagkit_sample/domain/demo/demo_server.dart' as _i464;
import 'package:flagkit_sample/domain/flags/app_flags.dart' as _i732;
import 'package:flagkit_sample/domain/network/device_network.dart' as _i712;
import 'package:flagkit_sample/features/checkout/cubit/checkout_cubit.dart'
    as _i533;
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_cubit.dart'
    as _i770;
import 'package:flagkit_sample/features/dashboard/cubit/flag_detail_cubit.dart'
    as _i229;
import 'package:flagkit_sample/features/dashboard/cubit/server_console_cubit.dart'
    as _i884;
import 'package:flagkit_sample/features/dashboard/cubit/try_user_cubit.dart'
    as _i921;
import 'package:flagkit_sample/features/home/cubit/home_cubit.dart' as _i826;
import 'package:flagkit_sample/features/profile/cubit/profile_cubit.dart'
    as _i581;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.singletonAsync<_i110.FakeRemoteConfigServer>(
      () => appModule.server(),
      preResolve: true,
    );
    gh.lazySingleton<_i110.FlagKitClient>(() => appModule.flagKit);
    gh.lazySingleton<_i110.NetworkMonitor>(
      () => appModule.deviceMonitor(),
      instanceName: 'device',
    );
    gh.lazySingleton<_i193.UserContext>(
      () => _i686.FlagKitUserContext(gh<_i110.FlagKitClient>()),
    );
    gh.lazySingleton<_i760.FlagsDebug>(
      () => _i469.FlagKitFlagsDebug(gh<_i110.FlagKitClient>()),
    );
    gh.lazySingleton<_i464.DemoServer>(
      () => _i944.FakeServerDemo(gh<_i110.FakeRemoteConfigServer>()),
    );
    gh.lazySingleton<_i732.AppFlags>(
      () => _i1022.FlagKitAppFlags(gh<_i110.FlagKitClient>()),
    );
    gh.factory<_i921.TryUserCubit>(
      () => _i921.TryUserCubit(gh<_i760.FlagsDebug>()),
    );
    gh.factoryParam<_i229.FlagDetailCubit, String, dynamic>(
      (key, _) => _i229.FlagDetailCubit(key, gh<_i760.FlagsDebug>()),
    );
    gh.factory<_i581.ProfileCubit>(
      () => _i581.ProfileCubit(gh<_i193.UserContext>()),
    );
    gh.factory<_i973.ThemeCubit>(() => _i973.ThemeCubit(gh<_i732.AppFlags>()));
    gh.factory<_i533.CheckoutCubit>(
      () => _i533.CheckoutCubit(gh<_i732.AppFlags>()),
    );
    gh.factory<_i826.HomeCubit>(() => _i826.HomeCubit(gh<_i732.AppFlags>()));
    gh.lazySingleton<_i136.DemoNetworkMonitor>(
      () => appModule.demoNetwork(
        gh<_i110.NetworkMonitor>(instanceName: 'device'),
      ),
    );
    gh.factory<_i884.ServerConsoleCubit>(
      () => _i884.ServerConsoleCubit(gh<_i464.DemoServer>()),
    );
    gh.lazySingleton<_i712.DeviceNetwork>(
      () => appModule.deviceNetwork(gh<_i136.DemoNetworkMonitor>()),
    );
    gh.factory<_i770.DashboardCubit>(
      () => _i770.DashboardCubit(
        gh<_i760.FlagsDebug>(),
        gh<_i712.DeviceNetwork>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i963.AppModule {}
