import 'package:flagkit_sample/core/common/time_text.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/core/navigation/app_routes.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/network/device_network.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:flagkit_sample/features/dashboard/cubit/server_console_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/try_user_cubit.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_words.dart';
import 'package:flagkit_sample/features/dashboard/widgets/reading_tile.dart';
import 'package:flagkit_sample/features/dashboard/widgets/server_console_section.dart';
import 'package:flagkit_sample/features/dashboard/widgets/stats_section.dart';
import 'package:flagkit_sample/features/dashboard/widgets/try_user_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Dashboard: what the SDK knows, and the demo's controls. The cache
/// and its actions, the network, every flag (tap one for its detail and an
/// override), another user's flags, the server's console, the refresh log
/// and the counts.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => getIt<DashboardCubit>()),
      BlocProvider(create: (_) => getIt<TryUserCubit>()),
      BlocProvider(create: (_) => getIt<ServerConsoleCubit>()),
    ],
    child: const DashboardView(),
  );
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;
    final cubit = context.read<DashboardCubit>();
    final cache = state.cache;
    final refreshing = state.refreshing || (cache?.refreshing ?? false);
    return BlocListener<DashboardCubit, DashboardState>(
      listenWhen: (before, now) => now.refreshCount > before.refreshCount,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(refreshResultWords(state.lastResult!))),
        ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.large),
          children: [
            const SectionHeader('Cache'),
            if (cache != null)
              _CacheCard(cache)
            else
              const ListTile(title: Text('Reading the cache…')),
            if (refreshing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                child: LinearProgressIndicator(
                  semanticsLabel: 'Refreshing the flags',
                ),
              ),
            _Actions(
              refreshing: state.refreshing,
              overrides: cache?.overrideCount ?? 0,
            ),
            const SectionHeader('Network'),
            if (state.network case final network?)
              _NetworkCard(network, onSimulateOffline: cubit.simulateOffline),
            const SectionHeader('Flags'),
            for (final reading in state.readings)
              ReadingTile(
                reading,
                onTap: () => FlagDetailRoute(flagKey: reading.key).go(context),
              ),
            const SectionHeader('Try a user'),
            const TryUserSection(),
            const SectionHeader('Server console'),
            const ServerConsoleSection(),
            const SectionHeader('Refresh log'),
            if (state.refreshLog.isEmpty)
              const ListTile(title: Text('No refresh yet.'))
            else
              for (final refresh in state.refreshLog)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.history),
                  title: Text(refreshLine(refresh)),
                ),
            if (cache != null) ...[
              const SectionHeader('Stats'),
              StatsSection(cache),
            ],
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text('FlagKit ${state.sdkVersion}'),
              subtitle: const Text(
                'Each flag is evaluated for you: a local override first, '
                'then the kill switch, its targeting rules and its rollout. '
                'Profile changes who you are.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Refresh, Clear cache (asks first) and Clear overrides (when there are
/// some).
class _Actions extends StatelessWidget {
  const _Actions({required this.refreshing, required this.overrides});

  final bool refreshing;
  final int overrides;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.xSmall,
      ),
      child: Wrap(
        spacing: AppSpacing.xSmall,
        runSpacing: AppSpacing.xSmall,
        children: [
          FilledButton.icon(
            onPressed: refreshing ? null : cubit.refresh,
            icon: const Icon(Icons.refresh),
            label: Text(refreshing ? 'Refreshing…' : 'Refresh'),
          ),
          OutlinedButton.icon(
            onPressed: () => _clearCache(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear cache'),
          ),
          if (overrides > 0)
            TextButton.icon(
              onPressed: cubit.clearOverrides,
              icon: const Icon(Icons.edit_off_outlined),
              label: Text(
                overrides == 1
                    ? 'Clear 1 override'
                    : 'Clear $overrides overrides',
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    final cubit = context.read<DashboardCubit>();
    final clear = await showConfirmDialog(
      context,
      title: 'Clear the cache?',
      message:
          'Every flag goes back to the app\'s default until the next '
          'refresh. Overrides and the install id stay.',
      confirmLabel: 'Clear',
      destructive: true,
    );
    if (clear) await cubit.clearCache();
  }
}

/// The device's network, and the demo's switch.
class _NetworkCard extends StatelessWidget {
  const _NetworkCard(this.network, {required this.onSimulateOffline});

  final NetworkStatus network;
  final ValueChanged<bool> onSimulateOffline;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (network) {
      NetworkStatus(online: true) => (Icons.wifi, 'Online'),
      NetworkStatus(simulatingOffline: true) => (
        Icons.wifi_off,
        'Offline (simulated)',
      ),
      _ => (Icons.wifi_off, 'Offline'),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(leading: Icon(icon), title: Text(label)),
        SwitchListTile.adaptive(
          title: const Text('Device offline'),
          subtitle: const Text(
            'For the demo: the SDK sees no network, keeps serving the cached '
            'flags, and refreshes nothing. Switch it off to see the '
            'reconnect refresh.',
          ),
          value: network.simulatingOffline,
          onChanged: onSimulateOffline,
        ),
      ],
    );
  }
}

/// The cache: how fresh, how many flags, since when, and this install's
/// id.
class _CacheCard extends StatelessWidget {
  const _CacheCard(this.cache);

  final CacheInfo cache;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = cacheStyle(cache.state, context.appColors);
    final fetchedAt = cache.fetchedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MergeSemantics(
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(label),
            subtitle: Text(cacheWords(cache.state)),
          ),
        ),
        StatRow(
          icon: Icons.layers_outlined,
          label: 'Flags cached',
          value: '${cache.flagCount}',
        ),
        StatRow(
          icon: Icons.edit_outlined,
          label: 'Overrides',
          value: '${cache.overrideCount}',
        ),
        StatRow(
          icon: Icons.tag,
          label: 'Config version',
          value: '${cache.configVersion ?? '—'}',
        ),
        StatRow(
          icon: Icons.download_outlined,
          label: 'Fetched',
          value: fetchedAt == null ? 'Never' : clockTime(fetchedAt),
        ),
        if (cache.lastRefresh case final last?)
          MergeSemantics(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Last refresh'),
              subtitle: Text(refreshLine(last)),
            ),
          ),
        MergeSemantics(
          child: ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Install id'),
            subtitle: Text(
              '${cache.installId}\nWho rollouts bucket when no one is signed '
              'in. Clearing the cache keeps it.',
            ),
          ),
        ),
      ],
    );
  }
}
