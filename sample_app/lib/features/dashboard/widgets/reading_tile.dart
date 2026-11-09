import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/flags/flag_reading.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_words.dart';
import 'package:material_ui/material_ui.dart';

/// One flag: its key, the value the app gets, its kind and why, and where
/// it came from. At large text the chip goes under the words, so a long
/// key isn't squeezed into a narrow column (TrackLite's lesson). [onTap]
/// opens its detail.
class ReadingTile extends StatelessWidget {
  const ReadingTile(this.reading, {super.key, this.onTap});

  final FlagReading reading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = sourceStyle(reading.source, context.appColors);
    final chip = StatusChip(icon: icon, label: label, color: color);
    final details = Text(readingLine(reading));
    final stacked = context.prefersStackedLayout;
    return MergeSemantics(
      child: ListTile(
        title: Text(reading.key),
        subtitle: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  details,
                  const SizedBox(height: AppSpacing.xSmall),
                  chip,
                ],
              )
            : details,
        trailing: stacked
            ? (onTap == null ? null : const Icon(Icons.chevron_right))
            : chip,
        onTap: onTap,
      ),
    );
  }
}
