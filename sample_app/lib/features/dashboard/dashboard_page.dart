import 'package:flagkit_sample/core/common/money.dart';
import 'package:flagkit_sample/core/common/time_text.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/network/device_network.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_words.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Dashboard: what the SDK knows. The cache and a refresh, the
/// device's network with the demo's offline switch, and the app's flags
/// with where each value comes from and why.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<DashboardCubit>(),
    child: const DashboardView(),
  );
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;
    final cubit = context.read<DashboardCubit>();
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
            if (state.cache case final cache?)
              _CacheCard(cache)
            else
              const ListTile(title: Text('Reading the cache…')),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.xSmall,
              ),
              child: FilledButton.icon(
                onPressed: state.refreshing ? null : cubit.refresh,
                icon: const Icon(Icons.refresh),
                label: Text(state.refreshing ? 'Refreshing…' : 'Refresh'),
              ),
            ),
            if (state.refreshing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                child: LinearProgressIndicator(
                  semanticsLabel: 'Refreshing the flags',
                ),
              ),
            const SectionHeader('Network'),
            if (state.network case final network?)
              _NetworkCard(network, onSimulateOffline: cubit.simulateOffline),
            const SectionHeader('Flags'),
            for (final reading in state.readings) _ReadingTile(reading),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text('FlagKit ${state.sdkVersion}'),
              subtitle: const Text(
                'Each flag is evaluated for you: switched off, then its '
                'targeting rules, then its rollout. Profile changes who you '
                'are.',
              ),
            ),
          ],
        ),
      ),
    );
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

/// One flag: its key, the value the app gets and why, and where it came
/// from. At large text the chip goes under the words, so a long key isn't
/// squeezed into a narrow column (TrackLite's lesson).
class _ReadingTile extends StatelessWidget {
  const _ReadingTile(this.reading);

  final FlagReading reading;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = sourceStyle(reading.source, context.appColors);
    final chip = StatusChip(icon: icon, label: label, color: color);
    final bucket = switch (reading) {
      FlagReading(:final bucket?, :final rolloutPercent?) =>
        ' (bucket $bucket, rollout ${formatPercent(rolloutPercent)})',
      _ => '',
    };
    final details = Text(
      '${reading.value} · ${reasonWords(reading.reason)}$bucket',
    );
    return MergeSemantics(
      child: ListTile(
        title: Text(reading.key),
        subtitle: context.prefersStackedLayout
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  details,
                  const SizedBox(height: AppSpacing.xSmall),
                  chip,
                ],
              )
            : details,
        trailing: context.prefersStackedLayout ? null : chip,
      ),
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
          icon: Icons.download_outlined,
          label: 'Fetched',
          value: fetchedAt == null ? 'Never' : clockTime(fetchedAt),
        ),
        if (cache.lastRefresh case final last?)
          MergeSemantics(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Last refresh'),
              subtitle: Text(
                [
                  causeWords(last.cause),
                  kindWords(last.kind),
                  clockTime(last.at),
                  ?last.error,
                ].join(' · '),
              ),
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
