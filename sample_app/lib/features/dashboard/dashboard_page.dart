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
          const SectionHeader('SDK'),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: Text('FlagKit ${state.sdkVersion}'),
            subtitle: const Text(
              'No flags yet: they come from the device\'s cache (0.2.0) and '
              'the server (0.3.0). Until then every flag is the app\'s '
              'default.',
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
