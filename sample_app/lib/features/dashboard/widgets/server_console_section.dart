import 'package:flagkit_sample/core/common/money.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/demo/demo_server.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/features/dashboard/cubit/server_console_cubit.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_words.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The demo server's console: what an admin would change on a real
/// backend. Nothing changes in the app until a refresh brings it.
class ServerConsoleSection extends StatelessWidget {
  const ServerConsoleSection({super.key});

  /// The rollouts the console offers.
  static const rollouts = <double>[0, 10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ServerConsoleCubit>().state;
    final cubit = context.read<ServerConsoleCubit>();
    final small = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: Text(
            'The server, as an admin sees it. A change reaches the app at '
            'the next refresh: tap Refresh above.',
            style: small,
          ),
        ),
        for (final flag in state.flags) ...[
          SwitchListTile.adaptive(
            title: Text(flag.key),
            subtitle: Text(
              [
                flag.value,
                if (flag.rolloutPercent case final percent?)
                  'rolled out to ${formatPercent(percent)}',
              ].join(' · '),
            ),
            value: flag.enabled,
            onChanged: (enabled) => cubit.setEnabled(flag.key, enabled),
          ),
          if (flag.rolloutPercent case final percent?)
            _Choice(
              label: 'Rollout of ${flag.key}',
              child: SegmentedChoice<double>(
                values: rollouts,
                labelOf: formatPercent,
                selected: percent,
                onSelected: (value) => cubit.setRollout(flag.key, value),
              ),
            ),
          if (flag.isTheme)
            _Choice(
              label: 'Look the server serves',
              child: SegmentedChoice<String>(
                values: [
                  for (final choice in AppThemeChoice.values) choice.name,
                ],
                labelOf: (name) => name,
                selected: flag.value.replaceAll('"', ''),
                onSelected: cubit.setTheme,
              ),
            ),
        ],
        _Choice(
          label: 'Failed answers',
          child: SegmentedChoice<ServerFailures>(
            values: ServerFailures.values,
            labelOf: failuresWords,
            selected: state.knobs.failures,
            onSelected: cubit.setFailures,
          ),
        ),
        _Choice(
          label: 'Answer time',
          child: SegmentedChoice<ServerSpeed>(
            values: ServerSpeed.values,
            labelOf: speedWords,
            selected: state.knobs.speed,
            onSelected: cubit.setSpeed,
          ),
        ),
      ],
    );
  }
}

/// A labelled choice: the label as text above, so it reads at any size.
class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.medium,
      AppSpacing.xSmall,
      AppSpacing.medium,
      AppSpacing.small,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xSmall),
        child,
      ],
    ),
  );
}
