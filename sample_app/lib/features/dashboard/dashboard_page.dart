import 'package:flagkit_sample/core/common/time_text.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_words.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Dashboard: what the SDK knows. For now, the app's flags with where
/// each value comes from and why; the cache, the server and the debug
/// tools arrive with the next versions.
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
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.large),
        children: [
          const SectionHeader('Cache'),
          if (state.cache case final cache?)
            _CacheCard(cache)
          else
            const ListTile(title: Text('Reading the cache…')),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: Text('FlagKit ${state.sdkVersion}'),
            subtitle: const Text(
              'The server comes in 0.3.0: until then nothing fills the cache, '
              'so every flag is the app\'s default.',
            ),
          ),
          const SectionHeader('Flags'),
          for (final reading in state.readings) _ReadingTile(reading),
        ],
      ),
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
    final details = Text('${reading.value} · ${reasonWords(reading.reason)}');
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
