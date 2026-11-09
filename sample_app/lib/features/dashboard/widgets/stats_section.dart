import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_words.dart';
import 'package:material_ui/material_ui.dart';

/// The SDK's counts: this session's reads by source, and the refreshes on
/// this install.
class StatsSection extends StatelessWidget {
  const StatsSection(this.cache, {super.key});

  final CacheInfo cache;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final source in ReadingSource.values)
          StatRow(
            icon: sourceStyle(source, colors).$1,
            label: 'Reads: ${sourceStyle(source, colors).$2.toLowerCase()}',
            value: '${cache.reads[source] ?? 0}',
          ),
        StatRow(
          icon: Icons.sync,
          label: 'Refreshes',
          value: '${cache.refreshes}',
        ),
        StatRow(
          icon: Icons.error_outline,
          label: 'Failed refreshes',
          value: '${cache.failedRefreshes}',
        ),
        StatRow(
          icon: Icons.block,
          label: 'Invalid flags left out',
          value: '${cache.skippedDefinitions}',
        ),
      ],
    );
  }
}
