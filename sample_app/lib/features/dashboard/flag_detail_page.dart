import 'package:flagkit_sample/core/common/money.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/core/navigation/app_routes.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/features/dashboard/cubit/flag_detail_cubit.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_words.dart';
import 'package:flagkit_sample/features/dashboard/widgets/reading_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// One flag in full: what the app gets and why, the server's definition,
/// this user's bucket, each rule and whether it matches, and an override.
class FlagDetailPage extends StatelessWidget {
  const FlagDetailPage({super.key, required this.flagKey});

  final String flagKey;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<FlagDetailCubit>(param1: flagKey),
    child: const FlagDetailView(),
  );
}

class FlagDetailView extends StatelessWidget {
  const FlagDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FlagDetailCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(state.key)),
      body: switch (state.inspection) {
        null => EmptyStateView(
          icon: Icons.flag_outlined,
          title: 'Flag not found',
          message:
              'FlagKit knows no flag "${state.key}": the server may have '
              'removed it.',
          action: FilledButton.tonal(
            onPressed: () => const DashboardRoute().go(context),
            child: const Text('Back to the Dashboard'),
          ),
        ),
        final inspection => _Detail(inspection, error: state.overrideError),
      },
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.inspection, {this.error});

  final FlagInspection inspection;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final reading = inspection.reading;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
      children: [
        const SectionHeader('What you get'),
        ReadingTile(reading),
        if (inspection.defined) ...[
          const SectionHeader('On the server'),
          StatRow(
            icon: Icons.toggle_on_outlined,
            label: 'Switched',
            value: inspection.enabled! ? 'On' : 'Off',
          ),
          StatRow(
            icon: Icons.check_circle_outline,
            label: 'Value',
            value: inspection.serverValue ?? '—',
          ),
          StatRow(
            icon: Icons.remove_circle_outline,
            label: 'Off value',
            value: inspection.offValue ?? '—',
          ),
          if (reading.kind case final kind?)
            StatRow(
              icon: Icons.category_outlined,
              label: 'Kind',
              value: kindWords(kind),
            ),
          if (reading.rolloutPercent case final percent?)
            _RolloutTile(percent: percent, bucket: reading.bucket),
          const SectionHeader('Targeting'),
          if (inspection.rules.isEmpty)
            const ListTile(title: Text('No rules: everyone is eligible.'))
          else
            for (final rule in inspection.rules) _RuleTile(rule),
        ] else
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              'The server doesn\'t send this flag: only the override gives '
              'it a value.',
            ),
          ),
        const SectionHeader('Override on this device'),
        _OverrideControls(
          kind: reading.kind,
          current: inspection.overrideValue,
          error: error,
        ),
      ],
    );
  }
}

/// The rollout and where this user falls in it.
class _RolloutTile extends StatelessWidget {
  const _RolloutTile({required this.percent, this.bucket});

  final double percent;
  final int? bucket;

  @override
  Widget build(BuildContext context) {
    final threshold = (percent * 100).round();
    final where = switch (bucket) {
      final bucket? when bucket < threshold =>
        'Your bucket is $bucket of 10,000: below $threshold, so you\'re in.',
      final bucket? =>
        'Your bucket is $bucket of 10,000: not below $threshold, so you\'re '
            'out.',
      // An override or a missed rule decided first: no bucket was needed.
      null => 'No bucket: something before the rollout decided.',
    };
    return MergeSemantics(
      child: ListTile(
        leading: const Icon(Icons.pie_chart_outline),
        title: Text('Rolled out to ${formatPercent(percent)}'),
        subtitle: Text(where),
      ),
    );
  }
}

/// A rule, and whether the current user matches it: an icon and a word,
/// never the color alone.
class _RuleTile extends StatelessWidget {
  const _RuleTile(this.rule);

  final RuleCheck rule;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return MergeSemantics(
      child: ListTile(
        leading: Icon(
          rule.matched ? Icons.check_circle : Icons.cancel_outlined,
          color: rule.matched ? colors.fresh : colors.expired,
        ),
        title: Text(rule.text),
        subtitle: Text(rule.matched ? 'Matches you' : 'Doesn\'t match you'),
      ),
    );
  }
}

/// The override: On / Off for an on/off flag, a field for the rest; and
/// Clear when one is set.
class _OverrideControls extends StatefulWidget {
  const _OverrideControls({required this.kind, this.current, this.error});

  final FlagKind? kind;
  final String? current;
  final String? error;

  @override
  State<_OverrideControls> createState() => _OverrideControlsState();
}

class _OverrideControlsState extends State<_OverrideControls> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FlagDetailCubit>();
    final current = widget.current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.small,
        children: [
          Text(
            current == null
                ? 'None. An override wins over the server, the rules and the '
                      'rollout, on this device only, until you clear it.'
                : 'Overridden with $current.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (widget.kind == FlagKind.onOff)
            Wrap(
              spacing: AppSpacing.xSmall,
              runSpacing: AppSpacing.xSmall,
              children: [
                FilledButton.tonal(
                  onPressed: () => cubit.setOverride('true'),
                  child: const Text('Override: on'),
                ),
                FilledButton.tonal(
                  onPressed: () => cubit.setOverride('false'),
                  child: const Text('Override: off'),
                ),
              ],
            )
          else ...[
            TextField(
              key: const ValueKey('overrideValue'),
              controller: _text,
              decoration: InputDecoration(
                labelText: 'Override value',
                hintText: switch (widget.kind) {
                  FlagKind.wholeNumber => '30',
                  FlagKind.number => '12.5',
                  FlagKind.json => '{"banner": "Sale"}',
                  _ => 'ocean',
                },
                errorText: widget.error,
                errorMaxLines: 3,
              ),
              onSubmitted: cubit.setOverride,
            ),
            FilledButton.tonal(
              onPressed: () => cubit.setOverride(_text.text),
              child: const Text('Override'),
            ),
          ],
          if (current != null)
            OutlinedButton.icon(
              onPressed: cubit.clearOverride,
              icon: const Icon(Icons.edit_off_outlined),
              label: const Text('Clear override'),
            ),
        ],
      ),
    );
  }
}
